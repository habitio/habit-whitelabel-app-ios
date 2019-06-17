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
	func didSelectDevices(groupedDevices: [MZChannelProfile: [MZChannelSubscription]])
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
	
	convenience init(serviceInteractor: MZServiceInteractor, viewModel : MZServiceDevicesSelectionViewModel, deviceInteractor : MZDeviceInteractor)
	{
		self.init()
		self.interactor = serviceInteractor
		self.interactor?.delegate = self
		self.deviceInteractor = MZFoscamInteractor(otherInteractor: deviceInteractor)
		self.viewModel = viewModel // TO CHECK!!! I think this may no be being called everytime. Maybe that's why the list has more devices than it should
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
//	
//	override func viewWillDisappear(animated : Bool) {
//		super.viewWillDisappear(animated)
//		
//		if (self.isMovingFromParentViewController()){
//			// Your code...
//		}
//	}
	
	
	func setupInterface()
	{
//		let barButton: UIBarButtonItem = UIBarButtonItem()
//		barButton.title = ""
//		
//		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
		
//		self.navigationController?.navigationBar.topItem?.hidesBackButton = true

		self.uiTableView.registerNib(UINib(nibName: "MZServiceGroupedDevicesSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "MZServiceGroupedDevicesSelectionTableViewCell")

		self.uiTableView.delegate = self
		self.uiTableView.dataSource = self
		uiTableView.backgroundColor = UIColor.muzzleyDarkWhiteColorWithAlpha(1)
		
		self.title = NSLocalizedString("mobile_devices", comment: "")
		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColorWithAlpha(1)
		self.uiBtNext.setTitle(NSLocalizedString("mobile_next", comment: ""), forState: .Normal)
		
		uiLabel.text = NSLocalizedString("mobile_service_device_selection_label", comment: "")
		uiLabel.textColor = UIColor.muzzleyBlackColorWithAlpha(1)
		updateNextButton(false)
		getDevices()
	}

	
	@IBAction func uiBtNext_TouchUpInside(sender: AnyObject)
	{
<<<<<<< Updated upstream
		
//		var passwordsList = [MZChannelSubscription: String]()
//		
//		for dev in self.viewModel!.groupedDevicesByProfile
//		{
//			if(dev.profile.identifier == NSBundle.mainBundle().infoDictionary?["MUZZLEY_FOSCAM_PROFILEID"] as? String)
//			{
//				for channelSub in dev.channelsSubscriptions
//				{
//					passwordsList[channelSub]  = ""
//
//					deviceInteractor!.loginDeviceWithAdmin(channelSub.id, completion: { (error) in
//					
//						if(error == nil) // is admin so the camera password has to be set
//						{
//							
//							self.askForPassword(false, channelSub: channelSub, completion: { (cancel, password) in
//									passwordsList[channelSub]  = password
//							})
//						}
//						else
//						{
//							// Camera password is set, so the current password needs to be input
//							self.askForPassword(true, channelSub: channelSub, completion: { (cancel, password) in
//								passwordsList[channelSub]  = password
//							})
//						}
//					})
//				}
//			}
//			
//		}
//		
//		if(passwordsList.filter{ $1 ==  ""}.count == 0)
//		{
//			self.loadingView.updateLoadingStatus(true, container: self.view)
//		}
//		else
//		{
//			// Show error and cancel
//		}
		
		
		var groupedChannels = [MZChannelProfile: [MZChannelSubscription]]()
		for group in (self.viewModel?.groupedDevicesByProfile)!
		{
//			if(group.profile.identifier == NSBundle.mainBundle().infoDictionary?["MUZZLEY_FOSCAM_PROFILEID"] as? String)
//			{
//				continue
//			}
			
			var subscriptions = [MZChannelSubscription]()
			
			for sub in group.devices
			{
				if(sub.isSelected)
				{
					subscriptions.append(sub.channelSubscription!)
				}
			}
			
			if(subscriptions.count > 0)
			{
				groupedChannels[group.profile] = subscriptions
			}
		}
		
		
		self.loadingView.updateLoadingStatus(true, container: self.view)
		
		self.interactor?.addChannelsToUser(groupedChannels, completion: { (result, error) in
			if(error == nil)
			{
				self.delegate?.didSelectDevices(groupedChannels)

			}
			else
			{
				self.showError(error!)
            }
			
		})
		
		
	}
    
    func showError(error: NSError)
    {
        self.loadingView.updateLoadingStatus(false, container: self.view)

        let alertController = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            
        let okAction = UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: UIAlertActionStyle.Default) { (action) in
            //
        }
 
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true) {
        //
        }
    }
	
	
	func askForPassword(passwordIsSet: Bool, channelSub: MZChannelSubscription, completion: (success: Bool, password: String) -> Void)
	{
		let alertTitle = channelSub.content;
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
		
		let passwordAlert: UIAlertController = UIAlertController(title: alertTitle,
		                                                 message: alertMessage,
		                                                 preferredStyle: .Alert)
		passwordAlert.addTextFieldWithConfigurationHandler { (textField) in
		
		}
		
		passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .Cancel,  handler: { action in
	
			completion(success: false, password: "")
		}))
		
		
		passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .Default, handler: { action in
			
			let textField = passwordAlert.textFields?.first
			if(textField!.text!.isEmpty)
			{
				completion(success: false, password: "")
			}
			else
			{
				completion(success: true, password: textField!.text!)
			}
		}))
		
		self.presentViewController(passwordAlert, animated: true, completion: nil)
	}
	
	
=======
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
	
	
>>>>>>> Stashed changes
	
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
	
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	//	self.interactor?.delegate.serviceGoToBeginning()
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
		self.interactor!.getChannelsSubscriptions(profile)
	
	}
	
	func startLocalDiscovery(profile: MZChannelProfile)
	{
		self.interactor!.startLocalDiscovery(profile)
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
		triggerValidation()
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
	
	func localDiscoverySuccess(profileId: String, data: NSDictionary)
	{
		self.deviceInteractor?.setDevices(data)
	}
	
	func localDiscoveryNumberOfStepsUpdate(profileId: String, numberOfSteps: Int)
	{
		for group in (self.viewModel?.groupedDevicesByProfile)!
		{
			if(group.profile.identifier == profileId)
			{
				group.numberOfSteps = numberOfSteps
				return
			}
		}

	}
	
	func localDiscoveryStepUpdate(profileId: String, stepNumber: Int, stepDescription: String)
	{
		for group in (self.viewModel?.groupedDevicesByProfile)!
		{
			if(group.profile.identifier == profileId)
			{
				group.isLoading = true
				group.loadingTopText = String(stepNumber) + "/" + String(group.numberOfSteps)
				group.loadingTopText = stepDescription
				return
			}
		}
		
		self.uiTableView.reloadData()

	}
	
	func localDiscoveryUnsuccess(profileId: String)
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
	
	// Try getting the channels for a certain profile
	func tappedTryAgain(profile: MZChannelProfile)
	{
		for gp in viewModel!.groupedDevicesByProfile
		{
			if(gp.profile.identifier == profile.identifier)
			{
				gp.isLoading = true
				break
			}
		}
		self.uiTableView.reloadData()
		
		if(profile.requiredCapability == "discovery-webview")
		{
			self.interactor!.getChannelsSubscriptions(profile)
		}
		else
		{
			self.interactor!.startLocalDiscovery(profile)
		}
	}
	
	// Validation of the groups to enable/disable the next button
	func triggerValidation()
	{
		for gp in self.viewModel!.groupedDevicesByProfile
		{
			// TO BE REMOVED
//			if(gp.profile.identifier == NSBundle.mainBundle().infoDictionary?["MUZZLEY_FOSCAM_PROFILEID"] as? String)
//			{
//				continue
//			}
//			
			if (!gp.isGroupValid())
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
