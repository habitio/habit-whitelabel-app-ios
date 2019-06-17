//
//  MZChooseDeviceViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 18/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZChooseDeviceViewController:  BaseViewController, MZDeviceSelectionTableViewControllerDelegate{
    
    var wireframe: MZRootWireframe!
    var interactor: MZWorkersInteractor!
    var devicesList: MZDeviceSelectionTableViewController?
    var type:String!
    var isEdit:Bool = false
    var isUpdate:Bool = false
    var isShortcut:Bool = false
    
    var isShortcuts:Bool = false

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var triggerSearchField: UITextField!
    @IBOutlet weak var triggerMessageLabel: UILabel!
    @IBOutlet weak var devicesPlaceholderView: UIView!
    @IBOutlet weak var nextButton: MZColorButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var headerViewTop: NSLayoutConstraint!
    @IBOutlet weak var footerViewBottom: NSLayoutConstraint!
    
    var workerVM: MZWorkerViewModel?
    
    convenience init(withWireframe wireframe: MZRootWireframe, andInteractor interactor: MZWorkersInteractor) {
        self.init(nibName: "MZChooseDeviceViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupInterface()
        
        // FIXME: hidden on purpose
        self.headerViewTop.constant = -60.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.devicesPlaceholderView != nil {
            
            var excludeIds = [String]()
            if self.type == MZWorker.key_state
            {
                self.workerVM?.stateDeviceVMs.forEach({ (stateDeviceVM) -> () in
                    excludeIds.append(stateDeviceVM.model!.tile!.identifier)
                })
                
                if self.workerVM!.triggerDeviceVM != nil {
                    excludeIds.append(self.workerVM!.triggerDeviceVM!.model!.tile!.identifier)
                }
            }
            
            var newFrame: CGRect = self.devicesPlaceholderView.frame
            newFrame.origin.y = 0.0
            self.devicesList = MZDeviceSelectionTableViewController(withFrame: newFrame)
            self.devicesList!.interactor = self.interactor
            self.devicesList!.delegate = self
            self.devicesList!.filter = [MZWorkersInteractor.key_type: self.type, MZWorkersInteractor.key_exclude: excludeIds] as! AnyObject
            self.devicesList!.emptyTextMessage =  NSLocalizedString("mobile_no_devices_text", comment: "")

            if self.type == MZWorker.key_trigger
            {
                 self.devicesList!.multiSelection = false
            }
			
            self.devicesList!.view.frame = self.devicesPlaceholderView.frame
            self.devicesList?.tableView!.keyboardDismissMode = .onDrag
            self.devicesList?.tableView!.tableFooterView = UIView()
            self.addChildViewController(self.devicesList!)
            self.view.addSubview(self.devicesList!.view)
            self.devicesPlaceholderView.removeFromSuperview()

            self.view.bringSubview(toFront: self.footerView)
        }
    }
    
    fileprivate func setupInterface() {
        switch self.type {
            case MZWorker.key_trigger:
            self.title = NSLocalizedString("mobile_choose_device_vc_first_step", comment: "")
            self.triggerSearchField.placeholder = NSLocalizedString("mobile_search_trigger", comment: "")
            self.triggerMessageLabel.text = NSLocalizedString("mobile_worker_select_trigger", comment: "")
            case MZWorker.key_action:
            self.title = NSLocalizedString("mobile_choose_device_vc_second_step", comment: "")
            self.triggerSearchField.placeholder = NSLocalizedString("mobile_search_action", comment: "")
            self.triggerMessageLabel.text = NSLocalizedString(self.isShortcuts ? "mobile_devices_select" : "mobile_worker_select_action", comment: "")
            case MZWorker.key_state:
            self.title = NSLocalizedString("mobile_choose_device_vc_third_step", comment: "")
            self.triggerSearchField.placeholder = NSLocalizedString("mobile_search_state", comment: "")
            self.triggerMessageLabel.text = NSLocalizedString("mobile_worker_select_state", comment: "")
            default: break
        }
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        
        self.view.bringSubview(toFront: self.headerView)
        self.headerView.layer.shadowColor = UIColor.muzzleyGrayColor(withAlpha: 0.5).cgColor
        self.headerView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.headerView.layer.shadowOpacity = 0.7
        self.headerView.layer.shadowRadius = 3.0
        
        self.triggerSearchField.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.triggerMessageLabel.textColor = UIColor.muzzleyGrayColor(withAlpha: 0.4)
        
        self.nextButton.setTitle(NSLocalizedString("mobile_next", comment: ""), for: .normal)
        self.nextButton.isEnabled = false
        
        self.footerView.layer.shadowColor = UIColor.muzzleyWhiteColor(withAlpha: 1).cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 0, height: -20.0)
        self.footerView.layer.shadowOpacity = 1.0
        self.footerView.layer.shadowRadius = 10.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func nextAction(_ sender: AnyObject) {
        let vc:MZWorkerConfigViewController = MZWorkerConfigViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
        vc.title = self.title
        vc.deviceVMs = self.devicesList!.selectedDevices
        vc.type = self.type
        vc.isUpdate = self.isUpdate
        vc.isEdit = self.isEdit
        vc.isShortcut = self.isShortcut
        vc.workerVM = self.workerVM
        self.wireframe.pushViewController(toEnd: vc, animated: true)
    }

    
    // MARK: - MZDeviceSelectionTableViewControllerDelegate
    
    func didSelectDevice(_ device: MZDeviceViewModel)
    {
        self.nextButton.isEnabled = true
    }
    
    func didUnselectDevice(_ device: MZDeviceViewModel)
    {
        self.nextButton.isEnabled = false
    }
    
    func didOccurError() {
        self.footerViewBottom.constant = -60.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.footerView.layoutIfNeeded()
        }) 
    }
    
    func didRefreshList() {
        self.footerViewBottom.constant = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.footerView.layoutIfNeeded()
        }) 
    }
    
}
