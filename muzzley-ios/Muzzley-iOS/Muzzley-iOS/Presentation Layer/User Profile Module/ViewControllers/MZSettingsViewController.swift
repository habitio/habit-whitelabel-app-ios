//
//  MZSettingsViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZSettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, MZTriStateToggleDelegate, MZInfoViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	var _viewModel : MZSettingsViewModel = MZSettingsViewModel()
	
	@IBOutlet weak var buttonView: UIView!
	
	let loadingView = MZLoadingView()
	
	var timeFormatToggle : MZTriStateToggle!
	var pushNotificationsToggle : MZTriStateToggle!
	var emailNotificationsToggle : MZTriStateToggle!
	var smsNotificationsToggle : MZTriStateToggle!
	
	fileprivate var infoView : MZPermissionInfoView?

	
	fileprivate enum Sections: Int {
		case units = 0,
		time,
		locations,
		notifications,
		count
	}
	
	fileprivate var wireframe: UserProfileWireframe!
	
	convenience init(withWireframe wireframe: UserProfileWireframe) {
		self.init(nibName: "MZSettingsViewController", bundle: Bundle.main)
		
		self.wireframe = wireframe
		
		MZNotifications.register(self, selector: #selector(self.updateViewModel), notificationKey: MZNotificationKeys.UserProfile.SettingsUpdated)
	}
	
	func updateViewModel()
	{
		tableView.reloadData()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupInterface()
	}
	
	fileprivate func setupInterface() {
		updateViewModel()
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 85
		self.title = NSLocalizedString("mobile_settings", comment: "")
		self.tableView.tableFooterView = UIView()
		self.tableView.register(UINib(nibName: "MZRadioTableViewCell", bundle: nil), forCellReuseIdentifier: "MZRadioTableViewCell")
		self.tableView.register(UINib(nibName: "MZSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "MZSwitchTableViewCell")
		self.tableView.register(UINib(nibName: "MZPhoneSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "MZPhoneSwitchTableViewCell")
		self.tableView.register(UINib(nibName: "MZSettingsLocationViewCell", bundle: nil), forCellReuseIdentifier: "MZSettingsLocationViewCell")
		self.tableView.register(UINib(nibName: "MZSettingsLocationUndefinedViewCell", bundle: nil), forCellReuseIdentifier: "MZSettingsLocationUndefinedViewCell")
	}
	
	
	// MARK: - UITableView DataSource
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return Sections.count.rawValue
	}
	
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		
//		
//	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch section
		{
		case Sections.units.rawValue:
			return 2
		case Sections.time.rawValue:
			return 1
		case Sections.locations.rawValue:
			
			return self._viewModel.places.count + 1
		case Sections.notifications.rawValue:
			return 1
		default:
			return 0
		}
	}
	
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	{
		return 35.0
	}
	
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
	{
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.font = UIFont(name: "SanFranciscoDisplay-Semibold", size: 13)!
		header.textLabel?.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
		
		view.tintColor = UIColor.groupTableViewBackground
	}
	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		switch section
		{
		case Sections.units.rawValue:
			return NSLocalizedString("mobile_settings_header_units", comment: "")
		case Sections.time.rawValue:
			return NSLocalizedString("mobile_settings_header_time", comment: "")
		case Sections.locations.rawValue:
			return NSLocalizedString("mobile_settings_header_locations", comment: "")
		case Sections.notifications.rawValue:
			return NSLocalizedString("mobile_settings_header_notifications", comment: "")
		default: return ""
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell? = UITableViewCell()
		
		switch indexPath.section {
			
		case Sections.units.rawValue:
			let aCell: MZRadioTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZRadioTableViewCell", for: indexPath) as! MZRadioTableViewCell
			
			switch indexPath.row
			{
			case 0:
				aCell.radioItem.text = NSLocalizedString("mobile_metric_title", comment: "")
				aCell.radioItem.subtitle = NSLocalizedString("mobile_metric_text", comment: "")
				aCell.radioItem.isSelected = self._viewModel.isMetric
				let gesture = UITapGestureRecognizer(target: self, action: #selector(MZSettingsViewController.setMetricUnits(_:)))
				aCell.addGestureRecognizer(gesture)
				break
				
			case 1:
				aCell.radioItem.text = NSLocalizedString("mobile_imperial_title", comment: "")
				aCell.radioItem.subtitle = NSLocalizedString("mobile_imperial_text", comment: "")
				aCell.radioItem.isSelected = !self._viewModel.isMetric
				let gesture = UITapGestureRecognizer(target: self, action: #selector(MZSettingsViewController.setImperialUnits(_:)))
				aCell.addGestureRecognizer(gesture)
			
			default:
				break
				
			}
			
			return aCell
			
		case Sections.time.rawValue:
			let aCell: MZSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZSwitchTableViewCell", for: indexPath) as! MZSwitchTableViewCell
			aCell.title.text = NSLocalizedString("mobile_settings_time_24h", comment: "")
			
			if(self._viewModel.is24hFormat)
			{
				self._viewModel.is24hFormat = true
				aCell.toggle.setState(MZTriStateToggleState.on, animated: false)
			}
			else
			{
				self._viewModel.is24hFormat = false
				aCell.toggle.setState(MZTriStateToggleState.off, animated: false)
			}
			
			aCell.toggle.delegate = self
			aCell.toggle.alpha = 1
			aCell.iconInfo.isHidden = true

			self.timeFormatToggle = aCell.toggle
		
			return aCell
			
		case Sections.locations.rawValue:
		
			switch indexPath.row
			{
				
			case self._viewModel.places.count:
				
				var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "addCell")
				
				if aCell == nil
				{
					aCell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
				}
				
				aCell?.textLabel?.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
				aCell?.textLabel?.text = "+ " + NSLocalizedString("mobile_location_add", comment: "")
				let gesture = UITapGestureRecognizer(target: self, action: #selector(MZSettingsViewController.addNewLocationButtonTapHandler(_:)))
				aCell!.addGestureRecognizer(gesture)
				return aCell!
 
			default:
					
					let address = self._viewModel.places[indexPath.row].address
					if(!address.isEmpty)
					{
						let aCell: MZSettingsLocationViewCell = (tableView.dequeueReusableCell(withIdentifier: "MZSettingsLocationViewCell", for: indexPath) as! MZSettingsLocationViewCell)
						
						let name = self._viewModel.places[indexPath.row].name
						
						let wifi = self._viewModel.places[indexPath.row].wifi
						
						aCell.placeVM = _viewModel.places[indexPath.row]
						
						aCell.lbName.text = !name.isEmpty ? name : ""
						aCell.lbAddress.text = !address.isEmpty ? address : NSLocalizedString("mobile_settings_locations_address_placeholder", comment: "")
						
						aCell.imgWifi.image = UIImage(named: "icon_wifi")
			
						if(wifi.ssid.isEmpty)
						{
							aCell.lbWifi.text = NSLocalizedString("mobile_settings_locations_empty_wifi", comment: "")
							aCell.lbWifi.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
						}
						else
						{
							aCell.lbWifi.text = wifi.ssid
						}
						switch self._viewModel.places[indexPath.row].id
						{
						case "home":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_home")
						case "work":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_work")
						case "gym":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_gym")
						case "school":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_school")
							
						default:
							aCell.imgPlaceIcon.image = nil
							break
						}
						
						let gesture = UITapGestureRecognizer(target: self, action: #selector(MZSettingsViewController.editLocationButtonTapHandler(_:)))
						aCell.addGestureRecognizer(gesture)
						
						return aCell
						
					}
					else
					{
						let aCell: MZSettingsLocationUndefinedViewCell = tableView.dequeueReusableCell(withIdentifier: "MZSettingsLocationUndefinedViewCell", for: indexPath) as! MZSettingsLocationUndefinedViewCell
						
						let name = self._viewModel.places[indexPath.row].name
						aCell.placeVM = _viewModel.places[indexPath.row]
						
						aCell.lbName.text = !name.isEmpty ? name : ""

						switch self._viewModel.places[indexPath.row].id
						{
						case "home":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_home")
						case "work":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_work")
						case "gym":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_gym")
						case "school":
							aCell.imgPlaceIcon.image = UIImage(named: "icon_school")
							
						default:
							break
						}

						let gesture = UITapGestureRecognizer(target: self, action: #selector(MZSettingsViewController.editLocationButtonTapHandler(_:)))
						aCell.addGestureRecognizer(gesture)
						
						return aCell
					}
			}

			
		case Sections.notifications.rawValue:
			
			switch indexPath.row {
				
			case 0:
				
				let aCell: MZSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZSwitchTableViewCell", for: indexPath) as! MZSwitchTableViewCell
				aCell.title.text = NSLocalizedString("mobile_push_notifications_title", comment: "")
				
				if !MZDeviceInfoHelper.areNotificationsEnabled()
				{
					self._viewModel.pushNotifications = false
					aCell.toggle.setState(MZTriStateToggleState.off, animated: false)
					aCell.iconInfo.isHidden = false
					let gesture = UITapGestureRecognizer(target: self, action: #selector(self.showPermissionsPopup(_:)))
					aCell.addGestureRecognizer(gesture)
			
					aCell.toggle.isUserInteractionEnabled = false
				}
				else
				{
					if _viewModel.pushNotifications
					{
						self._viewModel.pushNotifications = true
						aCell.toggle.setState(MZTriStateToggleState.on, animated: false)
						aCell.iconInfo.isHidden = true
						aCell.toggle.isUserInteractionEnabled = true
					}
					else
					{
						self._viewModel.pushNotifications = false
						aCell.toggle.setState(MZTriStateToggleState.off, animated: false)
						aCell.iconInfo.isHidden = true
						aCell.toggle.isUserInteractionEnabled = true
					}
				}
				
				aCell.toggle.delegate = self
				pushNotificationsToggle = aCell.toggle
				

				return aCell
				
//			case 1:
//				let aCell: MZSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZSwitchTableViewCell", for: indexPath) as! MZSwitchTableViewCell
//				aCell.title.text = NSLocalizedString("mobile_settings_notifications_email", comment: "")
//				if _viewModel.emailNotifications
//				{
//					self._viewModel.emailNotifications = true
//					aCell.toggle.setState(MZTriStateToggleState.on, animated: false)
//				}
//				else
//				{
//					self._viewModel.emailNotifications = false
//					aCell.toggle.setState(MZTriStateToggleState.off, animated: false)
//				}
//				aCell.toggle.delegate = self
//				aCell.toggle.alpha = 1
//				aCell.iconInfo.isHidden = true
//
//				emailNotificationsToggle = aCell.toggle
//				return aCell
			
//			case 1:
//				let aCell: MZPhoneSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZPhoneSwitchTableViewCell", for: indexPath) as! MZPhoneSwitchTableViewCell
//				aCell.title.text = NSLocalizedString("mobile_settings_notifications_sms", comment: "")
//				
//				if _viewModel.smsNotifications
//				{
//					self._viewModel.smsNotifications = true
//					aCell.toggle.setState(MZTriStateToggleState.on, animated: false)
//				}
//				else
//				{
//					self._viewModel.smsNotifications = false
//					aCell.toggle.setState(MZTriStateToggleState.off, animated: false)
//				}
//				aCell.toggle.delegate = self
//				aCell.toggle.alpha = 1
//				aCell.uiButton.setTitle(NSLocalizedString("mobile_settings_sms_add_number", comment: ""), for: .normal)
//				let currentNumber = aCell.title.text!
//				aCell.uiButton.addTarget(self, action:#selector(self.addPhoneNumber(sender:)), for: .touchUpInside)
//
//				smsNotificationsToggle = aCell.toggle
//				return aCell

				
			default:
				break
			}
			
			break
			
		default: break
		}
		return cell!
	}
	
	func addPhoneNumber(sender: UIButton)
	{
		
		let currentNumber = sender.titleLabel?.text!
		
		let addPhoneNumberVC = MZSettingsAddPhoneNumberViewController(withWireframe: self.wireframe, number: currentNumber!)
		self.wireframe.parent?.pushViewController(toEnd: addPhoneNumberVC, animated: true)
	}
	
	
	func setMetricUnits(_ sender:UITapGestureRecognizer)
	{
		self.loadingView.updateLoadingStatus(true, container: self.view)
		_viewModel.isMetric = true
		_viewModel.setUnits { (result, error) in
			self.tableView.reloadData()
			self.loadingView.updateLoadingStatus(false, container: self.view)
		}
	}
	
	func setImperialUnits(_ sender:UITapGestureRecognizer)
	{
		self.loadingView.updateLoadingStatus(true, container: self.view)
		_viewModel.isMetric = false
		
		_viewModel.setUnits { (result, error) in
			self.tableView.reloadData()
			self.loadingView.updateLoadingStatus(false, container: self.view)
		}
	}
	
	func addNewLocationButtonTapHandler(_ sender:UITapGestureRecognizer)
	{
		let addLocationVC = MZSettingsAddLocationViewController(withWireframe: self.wireframe)
		self.wireframe.parent?.pushViewController(toEnd: addLocationVC, animated: true)
	}
	
	
	func showPermissionsPopup(_ sender:UITapGestureRecognizer)
	{
		if(!(sender.view as! MZSwitchTableViewCell).iconInfo.isHidden)
		{
			self.infoView = Bundle.main.loadNibNamed("MZPermissionInfoView", owner: nil, options: nil)![0] as! MZPermissionInfoView
			self.infoView?._permissionType = MZPermissionType.notifications
			
			self.infoView!.delegate = self
            self.infoView!.show()
		}
	}

	
	func editLocationButtonTapHandler(_ sender:UITapGestureRecognizer)
	{
		if(sender.view is MZSettingsLocationUndefinedViewCell)
		{
			let cell = sender.view as! MZSettingsLocationUndefinedViewCell
			let editLocationVC = MZSettingsEditLocationViewController(withWireframe: self.wireframe, placeVM: cell.placeVM)
			self.wireframe.parent?.pushViewController(toEnd: editLocationVC, animated: true)
			return
		}
		let cell = sender.view as! MZSettingsLocationViewCell
		let editLocationVC = MZSettingsEditLocationViewController(withWireframe: self.wireframe, placeVM: cell.placeVM)
		editLocationVC.setup(cell.placeVM)
		self.wireframe.parent?.pushViewController(toEnd: editLocationVC, animated: true)
	}
    
	
	func toggle(_ toggle: MZTriStateToggle!, didChangetoState state: MZTriStateToggleState)
	{
		
		if(pushNotificationsToggle != nil && toggle == pushNotificationsToggle)
		{
			self.loadingView.updateLoadingStatus(true, container: self.view)
			_viewModel.pushNotifications = state == MZTriStateToggleState.on ? true : false
			_viewModel.setPushNotifications(_viewModel.pushNotifications)
			self.loadingView.updateLoadingStatus(false, container: self.view)

		}
		
		if(timeFormatToggle != nil && toggle == timeFormatToggle)
		{
			self.loadingView.updateLoadingStatus(true, container: self.view)
			_viewModel.is24hFormat = state == MZTriStateToggleState.on ? true : false
			_viewModel.setHourFormat({ (result, error) in
				self.tableView.reloadData()
				self.loadingView.updateLoadingStatus(false, container: self.view)
			})
		}
		
		if(emailNotificationsToggle != nil && toggle == emailNotificationsToggle)
		{
			self.loadingView.updateLoadingStatus(true, container: self.view)
			_viewModel.emailNotifications = state == MZTriStateToggleState.on ? true : false
			_viewModel.setEmailNotifications({ (result, error) in
				self.tableView.reloadData()
				self.loadingView.updateLoadingStatus(false,container: self.view)
			})

		}
		if(smsNotificationsToggle != nil && toggle == smsNotificationsToggle)
		{
			self.loadingView.updateLoadingStatus(true, container: self.view)
			_viewModel.smsNotifications = state == MZTriStateToggleState.on ? true : false
			_viewModel.setSmsNotifications({ (result, error) in
				self.tableView.reloadData()
				self.loadingView.updateLoadingStatus(false,container: self.view)
			})
			
		}
	}
}
