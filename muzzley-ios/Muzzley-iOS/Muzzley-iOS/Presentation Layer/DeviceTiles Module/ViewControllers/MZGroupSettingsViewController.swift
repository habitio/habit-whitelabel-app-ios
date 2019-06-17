//
//  MZGroupSettingsViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 02/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZGroupSettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var pencilButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var doneButton: MZColorButton!
    
    fileprivate var loadingView: UIView!
    
    internal var groupVM: MZTileGroupViewModel?
    //FIX ME why there are different?
    internal var devicesInGroup: [MZAreaChildViewModel]?
    fileprivate var devicesToAdd: [MZDeviceViewModel] = [MZDeviceViewModel]()

    fileprivate enum Sections: Int {
        case groupDevices = 0,
        devices,
        count
    }
    
    fileprivate var wireframe: DeviceTilesWireframe!
    fileprivate var interactor:MZDeviceTilesInteractor?
    fileprivate var deviceTilesDataSource: DeviceTilesDataSource!
    fileprivate var unselectedDevices: [Int] = [Int]()
    fileprivate var selectedItems: [Int] = [Int]()
    fileprivate var doneRequestsCount: Int = 3
    fileprivate var nameFieldBorder: CALayer!
    open var delegate: MZDeviceTilesRefreshProtocol!
    fileprivate var hasInteraction: Bool = false
    
    convenience init(withWireframe wireframe: DeviceTilesWireframe, andInteractor interactor: MZDeviceTilesInteractor) {
        self.init(nibName: "MZGroupSettingsViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MZAnalyticsInteractor.groupEditStartEvent()
        self.setupInterface()
        self.delegate = (self.navigationController?.viewControllers.first as! MZRootViewController).wireframe!.tilesViewController as! MZDeviceTilesRefreshProtocol
    }
    
    fileprivate func setupInterface() {
        self.title = NSLocalizedString("mobile_group_edit", comment: "")
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "MZDeviceToAddTableViewCell", bundle: nil), forCellReuseIdentifier: "MZDeviceToAddTableViewCell")
        
        self.nameLabel.text = NSLocalizedString("mobile_name", comment: "")
        self.nameLabel.font = UIFont.semiboldFontOfSize(17)
        self.nameLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        self.nameField.text = groupVM?.title
        self.nameField.addTarget(self, action: #selector(MZGroupSettingsViewController.textFieldValueChanged(_:)), for: .editingChanged)
        self.nameField.layer.masksToBounds = true
        
        let clearButton: UIButton = self.nameField.value(forKey: "_clearButton") as! UIButton
        var cframe: CGRect = clearButton.frame
        cframe.size.height = 24.0
        cframe.size.width = 24.0
        clearButton.frame = cframe
        clearButton.setImage(UIImage(named: "clearButton")!, for: UIControlState())
        
        self.nameFieldBorder = CALayer()
        self.nameFieldBorder.borderColor = UIColor.muzzleyGray3Color(withAlpha: 1.0).cgColor
        self.nameFieldBorder.frame = CGRect(x: 0.0, y: self.nameField.frame.size.height - 1.0 / UIScreen.main.scale, width: UIScreen.main.bounds.size.width - 32.0, height: 1.0 / UIScreen.main.scale)
        self.nameFieldBorder.borderWidth = 1.0 / UIScreen.main.scale
        self.nameFieldBorder.masksToBounds = false
        self.nameField.layer.masksToBounds = false
        self.nameField.layer.addSublayer(self.nameFieldBorder)
        
        self.pencilButton.setImage(UIImage(named: "IconEdit")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        self.pencilButton.tintColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)
        
        self.doneButton.setTitle(NSLocalizedString("mobile_done", comment: ""), for: .normal)
        self.doneButton.isEnabled = false
        
        self.footerView.layer.shadowColor = UIColor.muzzleyWhiteColor(withAlpha: 1).cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 0, height: -20.0)
        self.footerView.layer.shadowOpacity = 1.0
        self.footerView.layer.shadowRadius = 10.0
        
        var filter: [String:AnyObject] = [MZDeviceTilesToAddCreateInteractor.key_areaId: (groupVM!.parentViewModel as! MZTileAreaViewModel).model!.identifier as AnyObject]
        
        if !groupVM!.tilesViewModel.isEmpty
        {
            var commonClasses = Set((groupVM!.tilesViewModel[0].model! as! MZTile).componentClasses)
            for tileVM:MZTileViewModel in groupVM!.tilesViewModel as! [MZTileViewModel]
            {
                let classesSet = Set((tileVM.model as! MZTile).componentClasses)
                 commonClasses = commonClasses.intersection(classesSet)
            }
            
            filter[MZDeviceTilesToAddInteractor.key_classes] = Array(commonClasses) as AnyObject
        }
        
		MZDeviceTilesToAddInteractor().getDevicesByArea(filter as AnyObject) { (result, error) -> Void in
            if error == nil {
                let areas = result as! [MZAreaViewModel]
                if !areas.isEmpty
                {
                    let area = areas[0]
                    self.devicesToAdd = area.devicesViewModel
                }
				
                self.tableView.reloadSections(IndexSet(integer: Sections.devices.rawValue), with: .automatic)
            }
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == nil && !self.hasInteraction {
            MZAnalyticsInteractor.groupEditCancelEvent()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //TODO should it go to baseviewcontroller?
    internal func showLoadingView() {
        var lFrame: CGRect = self.view.frame
        lFrame.origin.x = 0.0
        lFrame.origin.y = 0.0
        self.loadingView = UIView(frame: lFrame)
        self.loadingView.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.2)
        
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        var frame: CGRect = self.loadingView.frame
        frame.origin.x = frame.size.width / 2.0 - loading.frame.size.width / 2.0
        frame.origin.y = frame.size.height / 2.0 - loading.frame.size.height / 2.0
        frame.size = loading.frame.size
        loading.frame = frame
        self.loadingView.addSubview(loading)
        self.loadingView.alpha = 0.0
        self.view.addSubview(self.loadingView)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.loadingView.alpha = 1.0
            loading.startAnimating()
        }) 
    }
    //TODO should it go to baseviewcontroller?
    internal func hideLoadingView() {
        if self.loadingView != nil {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.loadingView.alpha = 0.0
                }, completion: { (success) -> Void in
                    if self.loadingView != nil {
                        self.loadingView.subviews.forEach{ $0.removeFromSuperview() }
                        self.loadingView.removeFromSuperview()
                        self.loadingView = nil
                    }
            })
        }
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.groupDevices.rawValue: return (self.devicesInGroup?.count)! + 1
        case Sections.devices.rawValue: return self.devicesToAdd.count > 0 ? self.devicesToAdd.count : 1
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == Sections.devices.rawValue && self.devicesToAdd.count <= 0 ? 0.0 : 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 30.0))
        backView.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        
        let hLabel = UILabel(frame: CGRect(x: 16.0, y: 16.0, width: backView.frame.size.width - 32.0, height: backView.frame.size.height - 16.0))
        hLabel.font = UIFont.semiboldFontOfSize(17)
        hLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        
        switch section {
        case Sections.groupDevices.rawValue: hLabel.text = NSLocalizedString("mobile_devices", comment: "")
        case Sections.devices.rawValue: hLabel.text = self.devicesToAdd.count > 0 ? NSLocalizedString("mobile_group_add_devices", comment: "") : ""
            
        default: break
        }
        
        backView.addSubview(hLabel)
        
        return backView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        switch indexPath.section {
        case Sections.groupDevices.rawValue:
            if self.devicesInGroup?.count == indexPath.row {
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "addCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
                }
                
                aCell?.textLabel?.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
                aCell?.textLabel?.text = NSLocalizedString("mobile_ungroup", comment: "")
                
                cell = aCell
            } else {
                let aCell: MZDeviceToAddTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZDeviceToAddTableViewCell") as! MZDeviceToAddTableViewCell
                aCell.selectionStyle = .none
                let dev: MZTileViewModel = self.devicesInGroup![indexPath.row] as! MZTileViewModel
                aCell.devicePhoto.cancelImageDownloadTask()
                if dev.imageURL != nil {
                    aCell.devicePhoto.setImageWith(dev.imageURLAlt!)
                } else {
                    aCell.devicePhoto.image = nil
                }
                aCell.deviceName.text = dev.title
                aCell.deviceAccessory.isHidden = self.unselectedDevices.contains(indexPath.row)
                cell = aCell
            }
        case Sections.devices.rawValue:
            if self.devicesToAdd.count > 0 {
                let aCell: MZDeviceToAddTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZDeviceToAddTableViewCell") as! MZDeviceToAddTableViewCell
                aCell.selectionStyle = .none
                aCell.setViewModel(self.devicesToAdd[indexPath.row])
                aCell.deviceAccessory.isHidden = !self.selectedItems.contains(indexPath.row)
                cell = aCell
            } else {
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "loadingCell")
                }
                aCell?.selectionStyle = .none
                
                if let _: UIActivityIndicatorView = aCell?.viewWithTag(1000) as? UIActivityIndicatorView
                {
                    aCell?.subviews.forEach{ $0.removeFromSuperview() }
                } else {
                    let loading: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    loading.frame = CGRect(x: UIScreen.main.bounds.size.width / 2.0 - loading.bounds.size.width / 2.0, y: 25 - loading.bounds.size.height / 2.0, width: loading.bounds.size.width, height: loading.bounds.size.height)
                    loading.startAnimating()
                    loading.tag = 1000
                    aCell?.addSubview(loading)

                }
                
                cell = aCell
            }
            
        default: break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Sections.groupDevices.rawValue:
            switch indexPath.row {
            case (self.devicesInGroup?.count)!: self.ungroupAction(self)
                
            default:
                self.hasInteraction = true
                if !self.unselectedDevices.contains(indexPath.row) {
                    self.unselectedDevices.append(indexPath.row)
                } else {
                    self.unselectedDevices.remove(at: self.unselectedDevices.index(of: indexPath.row)!)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case Sections.devices.rawValue:
            if self.devicesToAdd.count > 0 {
                self.hasInteraction = true
                if !self.selectedItems.contains(indexPath.row) {
                    self.selectedItems.append(indexPath.row)
                } else {
                    self.selectedItems.remove(at: self.selectedItems.index(of: indexPath.row)!)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        default: break
        }
        self.doneButton.isEnabled = self.nameField.text != self.groupVM?.title || self.unselectedDevices.count > 0 || self.selectedItems.count > 0
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - UITextField Methods
    
    @IBAction func textFieldValueChanged(_ textField: UITextField) {
        self.hasInteraction = true
        self.doneButton.isEnabled = textField.text != self.groupVM?.title || self.unselectedDevices.count > 0 || self.selectedItems.count > 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pencilButton.alpha = 1.0
        self.pencilButtonWidth.constant = 0.0
        self.nameFieldBorder.borderColor = UIColor.muzzleyBlueColor(withAlpha: 1.0).cgColor
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.pencilButton.alpha = 0.0
            self.pencilButton.layoutIfNeeded()
            self.nameField.layoutIfNeeded()
            }, completion: { (success) -> Void in
                self.pencilButton.isHidden = true
        }) 
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.pencilButtonWidth.constant = 24.0
        self.pencilButton.alpha = 0.0
        self.pencilButton.isHidden = false
        self.nameFieldBorder.borderColor = UIColor.muzzleyGray3Color(withAlpha: 1.0).cgColor
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.pencilButton.alpha = 1.0
            self.pencilButton.layoutIfNeeded()
            self.nameField.layoutIfNeeded()
        })
    }
    
    @IBAction func pencilButtonAction(_ sender: AnyObject) {
        self.nameField.becomeFirstResponder()
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func ungroupAction(_ sender: AnyObject) {
        self.hasInteraction = true
        let alert: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_group_delete_text", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: { (action) in
            MZAnalyticsInteractor.groupEditUngroupCancelEvent()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ungroup", comment: ""), style: .destructive, handler: { (action) -> Void in
            self.showLoadingView()
            self.interactor!.ungroup(self.groupVM!, completion: { (error) -> Void in
                self.hideLoadingView()
                if error != nil {
                    MZAnalyticsInteractor.groupEditUngroupFinishEvent(error?.localizedDescription)
                    let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_group_delete_error_text", comment: ""), preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                    self.wireframe.parent?.present(error, animated: true, completion: nil)
                } else {
                    MZAnalyticsInteractor.groupEditUngroupFinishEvent(nil)
                    self.delegate.hideGroup!()
                    self.wireframe.parent?.popToRootViewController(animated: true)
                    self.delegate.refreshNowDeviceTiles!()
                }
            })
        }))
        self.wireframe.parent?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        if (self.devicesInGroup?.count)! - self.unselectedDevices.count + self.selectedItems.count <= 1 {
            let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_group_min_devices_text", comment: ""), preferredStyle: .alert)
            error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
            self.wireframe.parent?.present(error, animated: true, completion: nil)
        } else {
            self.doneRequestsCount = self.groupVM?.title != self.nameField.text ? 1 : 0 + self.unselectedDevices.count > 0 ? 1 : 0 + self.selectedItems.count > 0 ? 1 : 0
            if self.groupVM?.title != self.nameField.text {
                self.groupVM?.title = self.nameField.text!
                self.showLoadingView()
                self.interactor!.editGroupName(self.groupVM!, completion: { (error) -> Void in
                    self.hideLoadingView()
                    self.doneRequestsCount -= 1
                    if error != nil {
                        MZAnalyticsInteractor.groupEditFinishEvent(error?.localizedDescription)
                        let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                        self.wireframe.parent?.present(error, animated: true, completion: nil)
                    } else {
                        if self.doneRequestsCount == 0 {
                            MZAnalyticsInteractor.groupEditFinishEvent(nil)
                            self.wireframe.parent?.popViewController(animated: true)
                            self.delegate.refreshNowDeviceTiles!()
                        }
                    }
                })
            }
            
            if self.unselectedDevices.count > 0 {
                self.unselectedDevices.forEach({ (index: Int) -> () in
                    self.showLoadingView()
                    self.interactor?.removeTileFromGroup(self.groupVM!, removedTileMV: self.devicesInGroup![index] as! MZTileViewModel, completion: { (error) -> Void in
                        self.hideLoadingView()
                        self.doneRequestsCount -= 1
                        if error != nil {
                            MZAnalyticsInteractor.groupEditFinishEvent(error?.localizedDescription)
                            let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                            self.wireframe.parent?.present(error, animated: true, completion: nil)
                        } else {
                            if self.doneRequestsCount == 0 {
                                MZAnalyticsInteractor.groupEditFinishEvent(nil)
                                self.wireframe.parent?.popViewController(animated: true)
                                self.delegate.refreshNowDeviceTiles!()
                            }
                        }
                    })
                })
            }
            
            if self.selectedItems.count > 0 {
                var devices: [MZDeviceViewModel] = [MZDeviceViewModel]()
                self.selectedItems.forEach{ devices.append(self.devicesToAdd[$0]) }
                self.showLoadingView()
                self.interactor?.addTilesToGroup(self.groupVM!, newTilesVM: devices, completion: { (error) -> Void in
                    self.hideLoadingView()
                    self.doneRequestsCount -= 1
                    if error != nil {
                        MZAnalyticsInteractor.groupEditFinishEvent(error?.localizedDescription)
                        let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                        self.wireframe.parent?.present(error, animated: true, completion: nil)
                    } else {
                        if self.doneRequestsCount == 0 {
                            MZAnalyticsInteractor.groupEditFinishEvent(nil)
                            self.wireframe.parent?.popViewController(animated: true)
                            self.delegate.refreshNowDeviceTiles!()
                        }
                    }
                })
            }
        }
    }
    
}
