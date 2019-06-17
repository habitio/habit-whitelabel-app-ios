//
//  MZDeviceSelectionTableViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 26/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZDeviceSelectionTableViewControllerDelegate {
    @objc optional func didSelectDevice(_ device: MZDeviceViewModel)
    @objc optional func didUnselectDevice(_ device: MZDeviceViewModel)
    @objc optional func onDevicesSelected(_ devices : [MZDeviceViewModel], objectToUpdate : AnyObject?)
    @objc optional func onError()
}

class MZDeviceSelectionTableViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource
{
    
    var activityIndicator: UIActivityIndicatorView?
    var delegate: MZDeviceSelectionTableViewControllerDelegate?
    var interactor : MZDeviceListInteractor = MZDeviceListInteractor() //(dataManager: nil)
    var filter : AnyObject?
    //TODO think of a better solution
    var objectToUpdate : AnyObject?
    var selectedDevices: [MZDeviceViewModel] = [MZDeviceViewModel]()
    var multiSelection: Bool = true
    var offset: CGPoint?
    var tableView: UITableView?
    var tableViewFrame: CGRect?
    var emptyTextMessage: String = ""
    
    fileprivate var areasWithDevices: [MZAreaViewModel] = [MZAreaViewModel]()
    fileprivate var unFilteredAreasWithDevices: [MZAreaViewModel] = [MZAreaViewModel]()
    
    convenience init(withFrame frame: CGRect) {
        self.init()
        
        self.tableViewFrame = frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableViewFrame == nil ? self.view.frame : self.tableViewFrame!)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.showsVerticalScrollIndicator = false
        self.tableView!.tableHeaderView = UIView()
        self.tableView?.tableFooterView = UIView()
        self.tableView!.allowsSelection = true
        self.automaticallyAdjustsScrollViewInsets = true
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        self.tableView?.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        self.view.addSubview(self.tableView!)
        
        if (self.infoPlaceholderView == nil) {
            self.placeholder = MZInfoPlaceholderView()
            self.setInfoPlaceholderVisible(false)
            self.view.addSubview(self.placeholder!)
            
            self.placeholder.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["subview":self.placeholder]
            let metrics = ["topGuide": topLayoutGuide.length,"bottomGuide": bottomLayoutGuide.length]
            
            // Horizontal constraints
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|", options: NSLayoutFormatOptions.alignAllRight, metrics: metrics, views: views)
            NSLayoutConstraint.activate(horizontalConstraints)
            
            // Vertical constraints
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topGuide-[subview]-bottomGuide-|", options: NSLayoutFormatOptions.alignAllBottom, metrics: metrics, views: views)
            NSLayoutConstraint.activate(verticalConstraints)
        }
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.activityIndicator?.center = self.tableView!.center
        self.activityIndicator?.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator!)
        
        self.tableView!.register(UINib(nibName: "MZDeviceSelectionCell", bundle: Bundle.main), forCellReuseIdentifier: "deviceCell")
        
        self.offset = self.tableView!.contentOffset
        
        reloadData()
    }
    
    override func reloadData()
    {
        self.activityIndicator?.startAnimating()
        weak var weakSelf = self
        self.setInfoPlaceholderVisible(false)
        self.interactor.getDevicesByArea(filter, completion: { (result, error) -> Void in
            self.activityIndicator?.stopAnimating()
            self.setInfoPlaceholderVisible(false)
            
            if error == nil {
                self.unFilteredAreasWithDevices = result as! [MZAreaViewModel]
                self.areasWithDevices = [MZAreaViewModel](self.unFilteredAreasWithDevices)
                if (self.areasWithDevices.count == 0) {
                    self.setInfoPlaceholderVisible(true)
                    self.setGenericErrorInfoPlaceholderWithPlaceholderImageName("ohNoIcon", andDecription:self.emptyTextMessage)
                    self.delegate?.onError?()
                }
                weakSelf?.reloadView(false)
            } else {
                self.setInfoPlaceholderVisible(true)
                if error!.domain == NSURLErrorDomain &&
                    (error!.code == NSURLErrorNotConnectedToInternet ||
                        error!.code == NSURLErrorCannotFindHost) {
                    self.setNoInternetInfoPlaceholder()
                } else {
                    self.setErrorInfoPlaceholderWithPlaceholderImageName("BlankStateDevices")
                }
            }
        })
    }
    
    internal override func setInfoPlaceholderVisible(_ visible: Bool) {
		self.placeholder!.alpha = visible ? 1 : 0
        self.tableView!.alpha = !visible ? 1 : 0
    }
    
    func reloadView (_ useOffset: Bool)
    {
        self.tableView!.reloadData()
        if (useOffset) {
            self.tableView!.setContentOffset(self.offset!, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.areasWithDevices.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.areasWithDevices[section].devicesViewModel.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let area: MZAreaViewModel = self.areasWithDevices[section]
        let backView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 24.0))
        backView.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        
        let hView = UIView(frame: CGRect(x: 16.0, y: 0.0, width: backView.frame.size.width - 32.0, height: backView.frame.size.height))
        hView.backgroundColor = UIColor.groupTableViewBackground
        hView.layer.masksToBounds = true
        hView.layer.cornerRadius = 3.0
        backView.addSubview(hView)
        
        let hLabel = UILabel(frame: CGRect(x: 8.0, y: 0.0, width: hView.frame.size.width - 16.0, height: hView.frame.size.height))
        hLabel.font = UIFont.boldFontOfSize(14)
        hLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)
        hLabel.text = area.title
        hView.addSubview(hLabel)
        
        return backView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MZDeviceSelectionCell = self.tableView!.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! MZDeviceSelectionCell
        
        cell.selectionStyle = .none
        
        let device: MZDeviceViewModel = self.areasWithDevices[indexPath.section].devicesViewModel[indexPath.row]
        cell.setViewModel(device)
        
        let filteredSelected = self.selectedDevices.filter() { $0.id == device.id }
        cell.checkmark?.isHidden = filteredSelected.isEmpty
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceListArea = self.areasWithDevices[indexPath.section]
        
        let device = deviceListArea.devicesViewModel[indexPath.row]
        
        var found: Bool = false
        for (i, d) in self.selectedDevices.enumerated() {
            if d.id == device.id {
                found = true
                self.selectedDevices.remove(at: i)
                self.delegate?.didUnselectDevice?(device)
                break
            }
        }
        
        if !found {
            if self.multiSelection == false && self.selectedDevices.count == 1 {
                self.selectedDevices.removeAll()
            }
            self.selectedDevices.append(device)
            self.delegate?.didSelectDevice?(device)
            
            self.offset = self.tableView!.contentOffset
        }
        
        let cell: MZDeviceSelectionCell = tableView.cellForRow(at: indexPath) as! MZDeviceSelectionCell
        cell.checkmark!.isHidden = !cell.checkmark!.isHidden
        
        if !cell.checkmark!.isHidden
        {
            
            if let devices = self.interactor.getFilteredDevices(device, devices: self.areasWithDevices, selectedDevices: self.selectedDevices)
            {
                self.areasWithDevices = devices
            }
        } else {
            if self.selectedDevices.isEmpty
            {
                self.areasWithDevices = [MZAreaViewModel](self.unFilteredAreasWithDevices)
                self.reloadView(true)
            }
        }
        
        self.reloadView(false)
    }
}
