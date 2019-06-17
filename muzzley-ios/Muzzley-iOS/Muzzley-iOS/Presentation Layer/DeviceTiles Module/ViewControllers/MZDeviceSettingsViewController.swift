//
//  MZDeviceSettingsViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 14/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MZDeviceSettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
	
	@IBOutlet weak var doneButton: MZColorButton!

	

    internal var device: MZTileViewModel?
    internal var locations: [AnyObject]?
    internal var groupVM: MZTileGroupViewModel?
    internal var groupDevicesCount: Int?
    fileprivate var interactor:MZDeviceTilesInteractor?
    
    fileprivate enum Sections: Int {
        case general = 0,
        empty,
        count,
        locations
    }
    
    fileprivate enum GeneralRows: Int {
        case name = 0,
        count
    }
    fileprivate var loadingView = MZLoadingView()
    fileprivate var wireframe: DeviceTilesWireframe!
    fileprivate var selectedLocationIndex: Int = 0
    
    convenience init(withWireframe wireframe: DeviceTilesWireframe, andInteractor interactor: MZDeviceTilesInteractor) {
        self.init(nibName: "MZDeviceSettingsViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad()
	{
        super.viewDidLoad()

        self.setupInterface()

		MZAnalyticsInteractor.deviceEditStartEvent(self.device!.model as! MZTile)
    }
    
    fileprivate func setupInterface()
	{
        self.title = NSLocalizedString("mobile_device_edit", comment: "")
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        let button = UIButton(type: .custom)
        button.tintColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        button.bounds = CGRect(x: 0, y: 0, width: 14, height: 18)
		
        var deleteImage = UIImage(named: "icon_delete_agent")?.withRenderingMode(.alwaysTemplate)
        button.setImage(deleteImage, for: UIControlState())
        if #available(iOS 11, *) {
            button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        }
        
       

        
		button.addTarget(self, action: #selector(MZDeviceSettingsViewController.deleteDeviceAction(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "MZTextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "MZTextFieldTableViewCell")
        
        self.doneButton.setTitle(NSLocalizedString("mobile_done", comment: ""), for: .normal)
		//self.doneButton.addTarget(self, action: #selector(MZDeviceSettingsViewController.doneAction(_:)), forControlEvents: .touchUpInside)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.general.rawValue: return GeneralRows.count.rawValue
        case Sections.locations.rawValue: return (self.locations?.count)! + 1
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Sections.general.rawValue: return NSLocalizedString("mobile_name", comment: "")
        case Sections.locations.rawValue: return NSLocalizedString("mobile_location", comment: "")
            
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        switch indexPath.section {
        case Sections.general.rawValue:
            switch indexPath.row {
            case GeneralRows.name.rawValue:
                let aCell: MZTextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZTextFieldTableViewCell", for: indexPath) as! MZTextFieldTableViewCell
                aCell.selectionStyle = .none
                aCell.textField.text = self.device?.title
                aCell.textField.addTarget(self, action: #selector(MZDeviceSettingsViewController.textFieldValueChanged(_:)), for: .editingChanged)
                cell = aCell
                
            default: break
            }
        case Sections.locations.rawValue:
            if self.locations?.count == indexPath.row {
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "addCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
                }
                
                aCell?.textLabel?.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
                aCell?.textLabel?.text = "+ " + NSLocalizedString("mobile_device_add_location", comment: "")
                
                cell = aCell
            } else {
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "locationCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "locationCell")
                }
                
                // TODO: complete locations list
                aCell?.textLabel?.text = "Location \(indexPath.row + 1)"
                aCell?.accessoryType = indexPath.row == self.selectedLocationIndex ? .checkmark : .none
                
                cell = aCell
            }
            
        default: break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Sections.locations.rawValue:
            switch indexPath.row {
            case (self.locations?.count)!:
                // TODO: goto location picker
                break
                
            default:
                self.selectedLocationIndex = indexPath.row
                self.tableView.reloadSections(IndexSet(integer: Sections.locations.rawValue), with: .automatic)
            }
            
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - UITextField Methods
    
    @IBAction func textFieldValueChanged(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = (self.tableView.cellForRow(at: IndexPath(row: GeneralRows.name.rawValue, section: Sections.general.rawValue)) as! MZTextFieldTableViewCell).textField.text! != ""
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func deleteDeviceAction(_ sender: AnyObject) {
        self.loadingView.updateLoadingStatus(true, container: self.view)
        if self.groupDevicesCount == nil || self.groupDevicesCount > 2 {
            let alert: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_device_delete_text", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: { (action) in
                self.loadingView.updateLoadingStatus(false, container: self.view)
                MZAnalyticsInteractor.deviceEditDeleteCancelEvent(self.device!.model as! MZTile)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_delete", comment: ""), style: .destructive, handler: { (action) -> Void in
                self.interactor!.deleteDevice(self.device!, completion: { (error) -> Void in
                    if error != nil {
                        self.loadingView.updateLoadingStatus(false, container: self.view)

                        MZAnalyticsInteractor.deviceEditDeleteFinishEvent(self.device!.model as! MZTile, errorMessage: nil)
                        let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                        self.wireframe.parent?.present(error, animated: true, completion: nil)
                    } else {
                        MZAnalyticsInteractor.deviceEditDeleteFinishEvent(self.device!.model as! MZTile, errorMessage: error?.description)
						NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllTabs"), object: nil)
                        self.wireframe.parent?.popToRootViewController(animated: true)
					}
                })
            }))
            self.wireframe.parent?.present(alert, animated: true, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_device_and_group_delete_text", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_delete", comment: ""), style: .destructive, handler: { (action) -> Void in
                self.interactor!.ungroup(self.groupVM!, completion: { (error) -> Void in
                    if error != nil {
                        self.loadingView.updateLoadingStatus(false, container: self.view)

                        let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                        self.wireframe.parent?.present(error, animated: true, completion: nil)
                    } else {
                        self.interactor!.deleteDevice(self.device!, completion: { (error) -> Void in
                            if error != nil {
                                self.loadingView.updateLoadingStatus(false, container: self.view)

                                let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                                error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                                self.wireframe.parent?.present(error, animated: true, completion: nil)
                            } else {
                                self.loadingView.updateLoadingStatus(false, container: self.view)

								NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllTabs"), object: nil)
                                self.wireframe.parent?.popToRootViewController(animated: true)
                            }
                        })
                    }
                })
            }))
            self.wireframe.parent?.present(alert, animated: true, completion: nil)
        }
    }
	
	
	@IBAction func doneButtonPressed(_ sender: AnyObject) {
		self.view.endEditing(true)
		(self.tableView.cellForRow(at: IndexPath(row: GeneralRows.name.rawValue, section: Sections.general.rawValue)) as! MZTextFieldTableViewCell).textField.resignFirstResponder()
		self.device?.title = (self.tableView.cellForRow(at: IndexPath(row: GeneralRows.name.rawValue, section: Sections.general.rawValue)) as! MZTextFieldTableViewCell).textField.text!
		self.interactor!.editDeviceName(self.device!, completion: { (error) -> Void in
			if error != nil {
				let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_device_edit_text", comment: ""), preferredStyle: .alert)
				error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
				self.wireframe.parent?.present(error, animated: true, completion: nil)
			} else {
				self.wireframe.parent?.popViewController(animated: true)
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllTabs"), object: nil)
			}
		})
	}
}
