//
//  MZCreateGroupTableViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 09/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit


@objc protocol MZCreateGroupViewControllerDelegate: NSObjectProtocol
{
	@objc optional func createGroupSuccess()
	@objc optional func createGroupCancel()
}



class MZCreateGroupViewController: BaseViewController, MZDeviceSelectionTableViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var hSeparatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var btDone: MZColorButton!
	
    fileprivate var interactor:MZDeviceTilesInteractor?
    fileprivate var wireframe: DeviceTilesWireframe!
    fileprivate var devicesList: MZDeviceSelectionTableViewController?
	var delegate: MZCreateGroupViewControllerDelegate!
    fileprivate var hasInteraction: Bool = false
	
	fileprivate var createGroupSuccess = false
	
    convenience init(withWireframe wireframe: DeviceTilesWireframe, andInteractor interactor: MZDeviceTilesInteractor) {
        self.init(nibName: "MZCreateGroupViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MZAnalyticsInteractor.groupCreateStartEvent()
        self.setupInterface()
        //self.delegate = (self.navigationController?.viewControllers.first as! MZRootViewController).wireframe.deviceTilesViewController as! MZDeviceTilesRefreshProtocol
    }
    
    fileprivate func setupInterface() {
		
		self.createGroupSuccess = false
        self.title = NSLocalizedString("mobile_account", comment: "")
        
//        let button = UIButton(type: .custom)
//        button.tintColor = UIColor.muzzleyWhiteColorWithAlpha(1.0)
//        button.bounds = CGRectMake(0, 0, 20, 20)
//        button.setImage(UIImage(named: "IconDone")?.imageWithRenderingMode(.AlwaysTemplate), forState: .normal)
//        button.addTarget(self, action: #selector(MZCreateGroupViewController.doneAction(_:)), forControlEvents: .touchUpInside)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
		
		btDone.isEnabled = false
		btDone.setTitle(NSLocalizedString("mobile_done",comment: ""), for: .normal)
		btDone.addTarget(self, action: #selector(MZCreateGroupViewController.doneAction(_:)), for: .touchUpInside)
		
        self.groupNameField.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.groupNameField.placeholder = NSLocalizedString("mobile_group_add_name", comment: "")
        self.groupNameField.delegate = self
        self.groupNameField.addTarget(self, action: #selector(MZCreateGroupViewController.textFieldValueChanged(_:)), for: .editingChanged)
        
        self.hSeparatorLineHeight.constant = 1.0 / UIScreen.main.scale
        
        self.descriptionLabel.textColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        self.descriptionLabel.text = NSLocalizedString("mobile_create_group_vc_select_devices_group", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var newFrame: CGRect = self.placeholderView!.frame
        newFrame.origin.y = 0.0
        self.devicesList = MZDeviceSelectionTableViewController(withFrame: newFrame)
        self.devicesList!.interactor = MZDeviceTilesToCreateInteractor()
        self.devicesList!.delegate = self
        self.devicesList!.emptyTextMessage =  NSLocalizedString("mobile_no_groupable_devices_text", comment: "")
        self.devicesList!.view.frame = self.placeholderView!.frame
        self.devicesList!.tableView!.keyboardDismissMode = .onDrag
        self.devicesList!.tableView!.tableFooterView = UIView()
        self.addChildViewController(self.devicesList!)
        self.view.addSubview(self.devicesList!.view)
        self.placeholderView!.removeFromSuperview()
    }

	
	override func viewWillDisappear(_ animated: Bool) {
		if(!createGroupSuccess && self.delegate != nil)
		{
			self.delegate.createGroupCancel!()
		}
	}

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == nil && !self.hasInteraction {
            MZAnalyticsInteractor.groupCreateCancelEvent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UIButtons Actions
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.interactor!.createGroupVM(self.groupNameField.text!, newTilesVM: self.devicesList!.selectedDevices, completion: { (error) -> Void in
            if error == nil {
                MZAnalyticsInteractor.groupCreateFinishEvent(nil)
				self.createGroupSuccess = true
                self.wireframe.parent?.popViewController(animated: true)
				if(self.delegate != nil)
				{
					self.delegate.createGroupSuccess!()
				}
			} else {
                MZAnalyticsInteractor.groupCreateFinishEvent(error?.localizedDescription)
                let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_group_create_error", comment: ""), preferredStyle: .alert)
                error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                self.wireframe.parent?.present(error, animated: true, completion: nil)
				if(self.delegate != nil)
				{
					self.delegate.createGroupCancel!()
				}
            }
        })
    }
    
    
    // MARK: - UITextField Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textFieldValueChanged(_ sender: AnyObject) {
        self.hasInteraction = true
        btDone.isEnabled = self.groupNameField.text! != "" && self.devicesList!.selectedDevices.count > 1
    }
    
    
    // MARK: - MZDeviceSelectionTableViewControllerDelegate
    
    func didSelectDevice(_ device: MZDeviceViewModel) {
        self.hasInteraction = true
        btDone.isEnabled = self.groupNameField.text! != "" && self.devicesList!.selectedDevices.count > 1
    }
    
    func didUnselectDevice(_ device: MZDeviceViewModel) {
        btDone.isEnabled = self.groupNameField.text! != "" && self.devicesList!.selectedDevices.count > 1
	
    }
    
    func onError() {
        self.devicesList?.view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
		btDone.isEnabled = false
	}
    
}
