//
//  MZServiceSelectDevicesViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 13/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

@objc protocol MZServiceDevicesSelectionViewControllerDelegate: NSObjectProtocol
{
	func didSelectDevices()
	func devicesSelectionError()
}

class MZServiceDevicesSelectionViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, MZServiceInteractorDelegate, MZServiceGroupedDevicesSelectionTableViewCellDelegate
{
	@IBOutlet weak var uiLabel: UILabel!
	@IBOutlet weak var uiBtNext: UIButton!
	@IBOutlet weak var uiTableView: UITableView!
    
    private var loadingView = MZLoadingView()
	
	var delegate : MZServiceDevicesSelectionViewControllerDelegate?
	var viewModel : MZServiceDevicesSelectionViewModel? = nil
	
	var interactor : MZServiceInteractor?
	var deviceInteractor : MZFoscamInteractor?
	
	convenience init(serviceInteractor: MZServiceInteractor, viewModel : MZServiceDevicesSelectionViewModel)
	{
		self.init()
		self.interactor = serviceInteractor
		self.interactor?.delegate = self
		self.viewModel = viewModel // TO CHECK!!! I think this may no be being called everytime. Maybe that's why the list has more devices than it should
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
	
	func setupInterface()
	{
		let barButton: UIBarButtonItem = UIBarButtonItem()
		barButton.title = ""
		
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
		
		self.uiTableView.registerNib(UINib(nibName: "MZServiceGroupedDevicesSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "MZServiceGroupedDevicesSelectionTableViewCell")

		self.uiTableView.delegate = self
		self.uiTableView.dataSource = self
		uiTableView.backgroundColor = UIColor.muzzleyDarkWhiteColorWithAlpha(1)
		
		self.title = NSLocalizedString("mobile_devices", comment: "")
		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColorWithAlpha(1)
		self.uiBtNext.setTitle(NSLocalizedString("next", comment: ""), forState: .Normal)
		
		uiLabel.text = NSLocalizedString("mobile_service_device_selection_label", comment: "")
		uiLabel.textColor = UIColor.muzzleyBlackColorWithAlpha(1)
		updateNextButton(false)
		getDevices()
	}

	
	@IBAction func uiBtNext_TouchUpInside(sender: AnyObject)
	{
		self.deviceInteractor = MZFoscamInteractor(otherInteractor: self.deviceInteractor!)
		
		
		for dev in self.viewModel!.groupedDevicesByProfile
		{
			if(dev.profile.identifier == NSBundle.mainBundle().infoDictionary?["MUZZLEY_FOSCAM_PROFILEID"] as? String)
			{
				for channelSub in dev.channelsSubscriptions
				{
					deviceInteractor?.loginDeviceWithAdmin(channelSub.id, completion: { (error) in
					
						if(error == nil) // is admin
						{
							self.askForPassword(false, channelId: channelSub.id)
						}
						else
						{
							self.askForPassword(true, channelId: channelSub.id)
						}
						
					
					})
					
				}
			}
		}
		
		self.loadingView.updateLoadingStatus(true, container: self.view)
		
		self.delegate!.didSelectDevices()
	}
	
	
	func askForPassword(passwordIsSet: Bool, channelId: String)
	{
		var alertMessage = "";
		
		if(passwordIsSet)
		{
			// ask for current pass
			alertMessage = NSLocalizedString("mobile_password_current_request",comment: "")
		}
		else
		{
			// create new pass
			alertMessage = NSLocalizedString("mobile_password_new_request", comment: "")
		}
		
		let passwordAlert: UIAlertController = UIAlertController(title: "",
		                                                 message: alertMessage,
		                                                 preferredStyle: .Alert)
		passwordAlert.addTextFieldWithConfigurationHandler { (textField) in
		
		}
		
		passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .Cancel, handler: nil))
		passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .Default, handler: { action in
			
			let textField = passwordAlert.textFields?.first
			if(textField!.text!.isEmpty)
			{
				textField?.placeholder = NSLocalizedString("mobile_password_new_request", comment: "")
			}
			else
			{
			}
			
		}))
		
		self.presentViewController(passwordAlert, animated: true, completion: nil)

	}
	
	
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		var height = CGFloat(((viewModel?.groupedDevicesByProfile[indexPath.row].devices.count)! * 63) + 16)
		
		// If there are terms include the height to show them
		if(self.viewModel!.groupedDevicesByProfile[indexPath.row].showTerms)
		{
			height += 44
		}
		
		// If there are more devices than the required one include the height to show the label
		if(self.viewModel?.groupedDevicesByProfile[indexPath.row].devices.count > self.viewModel?.groupedDevicesByProfile[indexPath.row].occurrences)
		{
			height += 40
		}
		
		return height
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return (self.viewModel?.groupedDevicesByProfile.count)!
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell : MZServiceGroupedDevicesSelectionTableViewCell = tableView.dequeueReusableCellWithIdentifier("MZServiceGroupedDevicesSelectionTableViewCell", forIndexPath: indexPath) as! MZServiceGroupedDevicesSelectionTableViewCell
		cell.delegate = self
		cell.setupInterface(self.viewModel!.groupedDevicesByProfile[indexPath.row])
		cell.backgroundColor = UIColor.muzzleyDarkWhiteColorWithAlpha(1)
		
		return cell
	}
	
	func getDevices()
	{
		for p in self.viewModel!._profiles
		{
			if p.requiredCapability == "discovery-webview"
			{
				getChannels(p)
			}
			else
			{
				startLocalDiscovery(p)
			}
		}
	}
	
	func getChannels(profile: MZChannelProfile)
	{
		self.interactor!.getChannels(profile)
	}
	
	func startLocalDiscovery(profile: MZChannelProfile)
	{
		//self.interactor!.startLocalDiscovery(profile)
	}

	// Get channels is successful
	func channelsSubscriptionsSuccess(profile: MZChannelProfile, channelsSubscriptions: [MZChannelSubscription])
	{
		for gp in viewModel!.groupedDevicesByProfile
		{
			if(gp.profile.identifier == profile.identifier)
			{
				gp.updateChannelsSubscriptions(channelsSubscriptions)
				gp.isLoading = false
				break
			}
		}
		self.uiTableView.reloadData()
	}
	
	// Get channels is unsuccessful
	func channelsSubscriptionsUnsuccess(profileId: String)
	{
		for gp in viewModel!.groupedDevicesByProfile
		{
			if(gp.profile.identifier == profileId)
			{
				gp.updateChannelsSubscriptions([MZChannelSubscription]())
				gp.isLoading = false
				break
			}
		}
		self.uiTableView.reloadData()
	}
	
	func localDiscoverySuccess(profileId: String, channelsSubscriptions: [MZChannelSubscription])
	{
	}
	
	func localDiscoveryUnsuccess(profileId: String)
	{
	}
	
	// Try getting the channels for a certain profile
	func tappedTryAgain(profile: MZChannelProfile)
	{
		self.interactor!.getChannels(profile)
	}
	
	// Validation of the groups to enable/disable the next button
	func triggerValidation()
	{
		for gp in self.viewModel!.groupedDevicesByProfile
		{
			if (!gp.isGroupValid)
			{
				updateNextButton(false)
				return
			}
		}
		updateNextButton(true)
		
	}
	
	func updateNextButton(enabled: Bool)
	{
		if(enabled)
		{
			self.uiBtNext.enabled = true
		}
		else
		{
			self.uiBtNext.enabled = false
		}
		
	}
}
