
//
//  MZServiceSelectDevicesViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 13/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift

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

@objc protocol MZDevicesSelectionViewControllerDelegate: NSObjectProtocol
{
    func didAddDevices(_ addedDevices : NSArray)
    @objc optional func didSelectDevices(_ groupedDevicesByProfile: Any)
    func didSelectRetry(channelTemplate: MZChannelTemplate)
	func devicesSelectionUnsuccess()
    func devicesSelectionPressedBackButton()
    func UDPDiscoverySuccess()
}

class MZDevicesSelectionViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, MZAddDevicesInteractorDelegate, MZServiceGroupedDevicesSelectionTableViewCellDelegate
{
	@IBOutlet weak var uiLabel: UILabel!
	@IBOutlet weak var uiBtNext: UIButton!
	@IBOutlet weak var uiTableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    fileprivate var loadingView = MZLoadingView()
	
	var delegate : MZDevicesSelectionViewControllerDelegate?
	var viewModel : MZDevicesSelectionViewModel? = nil
	
	var addDevicesInteractor : MZAddDevicesInteractor?
    var usingRecipes : Bool = false
    var recipeParameters : [String: [String: Any]]?

    convenience init(viewModel : MZDevicesSelectionViewModel, deviceInteractor : MZDeviceInteractor, usingRecipes : Bool, recipeParameters: [String: [String: Any]]? = nil)
    {
        self.init()
        self.usingRecipes = usingRecipes
        self.recipeParameters = recipeParameters
        self.addDevicesInteractor = MZAddDevicesInteractor()
        self.addDevicesInteractor?.delegate = self
        self.viewModel = viewModel
    }
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
	
	override func viewWillDisappear(_ animated : Bool)
	{
		super.viewWillDisappear(animated)
		
		if (self.isMovingFromParentViewController)
		{
			self.delegate?.devicesSelectionUnsuccess()
		}
	}
	
    func back()
    {
        self.delegate?.devicesSelectionPressedBackButton()
    }
    
	func setupInterface()
	{
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = newBackButton
        
		self.uiTableView.register(UINib(nibName: "MZServiceGroupedDevicesSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "MZServiceGroupedDevicesSelectionTableViewCell")

		self.uiTableView.delegate = self
		self.uiTableView.dataSource = self
		uiTableView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		
		self.title = NSLocalizedString("mobile_devices", comment: "")
		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiBtNext.setTitle(NSLocalizedString("mobile_next", comment: ""), for: .normal)
		
		uiLabel.text = NSLocalizedString("mobile_service_device_selection_label", comment: "")
		uiLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		updateNextButton(false)
		getDevices()
	}

	
	@IBAction func uiBtNext_TouchUpInside(_ sender: AnyObject)
	{
		self.loadingView.updateLoadingStatus(true, container: self.view)
        
        if(!self.usingRecipes)
        {
            if(self.viewModel!.groupedDevicesByProfile != nil)
            {

                var tasks: [Observable<AnyObject>] = []

                for group in self.viewModel!.groupedDevicesByProfile
                {
                    tasks.append(self.addDevicesInteractor!.createChannelsWithPost(group: group))
                }

                Observable<Any>.zip(tasks) { return $0 }.subscribe(onNext:
                    { results in
                        self.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
                  
                }, onError: { error in
                    print(error)

                   self.showErrorAndGoToHome()
                    
                }, onCompleted: {})
                    .addDisposableTo(self.disposeBag)
            }
        }
        else
        {
            self.delegate?.didSelectDevices!(self.viewModel!.groupedDevicesByProfile)
        }
	}
    
    func showErrorAndGoToHome()
    {
        let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }

    
    
    
    
    func createChannelsUnsuccess(_ error : NSError)
    {
        if(error != nil)
        {
            self.showError(error as! NSError)
            return
        }
    }
   
    func createChannelsSuccess(_ results : [[NSDictionary]])
    {
        self.finishedPostChannels(result: results as! [[NSDictionary]])
    }
    
    
    func finishedPostChannels(result : [[NSDictionary]])
    {
        self.delegate?.didAddDevices(result as NSArray)
    }
    
	
    func showError(_ error: NSError)
    {
        var message = NSLocalizedString("mobile_error_text", comment: "")
        self.loadingView.updateLoadingStatus(false, container: self.view)

        let alertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: UIAlertActionStyle.default) { (action) in
            //
        }
 
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
        {
            //
        }
    }
		
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return (self.viewModel?.groupedDevicesByProfile.count)!
	}
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
		let cell : MZServiceGroupedDevicesSelectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZServiceGroupedDevicesSelectionTableViewCell", for: indexPath) as! MZServiceGroupedDevicesSelectionTableViewCell
		cell.delegate = self
		cell.setupInterface(self.viewModel!.groupedDevicesByProfile[indexPath.row])
		cell.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		
		return cell
	}

	
	func getDevices()
	{
        if !usingRecipes
        {
            for p in self.viewModel!._profiles
            {
                getChannels(p)
            }

        }
        else
        {
            if self.recipeParameters!.keys.contains("found_devices")
            {
                let foundDevices = self.recipeParameters!["found_devices"] as? [String : [NSDictionary]]
                if foundDevices != nil
                {
                    for p in self.viewModel!._profiles
                    {
                        if foundDevices!.keys.contains(p.identifier)
                        {
                            for gp in viewModel!.groupedDevicesByProfile
                            {
                                if(gp.profile.identifier == p.identifier)
                                {
                                    var chanSubs = [MZChannelSubscription]()
                                    let profileDevices = foundDevices![p.identifier]
                                    for d in profileDevices!
                                    {
                                        chanSubs.append(MZChannelSubscription(dictionary: d))
                                    }
                                    gp.updateChannelsSubscriptions(chanSubs)
                                    gp.isLoading = false
                                    break
                                }
                            }
                            self.uiTableView.reloadData()

                        }
                        else
                        {
                             getChannels(p)
                        }
                    }
                }

            }
            else
            {
                for p in self.viewModel!._profiles
                {
                    getChannels(p)
                }
            }
        }
	}
	
	func getChannels(_ profile: MZChannelTemplate)
	{
		self.addDevicesInteractor!.getChannelsSubscriptions(profile, data: nil)
	}

	// Get channels is successful
	func channelsSubscriptionsSuccess(_ profile: MZChannelTemplate, channelsSubscriptions: [MZChannelSubscription])
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
	func channelsSubscriptionsUnsuccess(_ profileId: String)
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
    
 
    
    
    func UDPDiscoveryUnsuccess(_ channelTemplateId: String)
    {
        for gp in viewModel!.groupedDevicesByProfile
        {
            if(gp.profile.identifier == channelTemplateId)
            {
                gp.updateChannelsSubscriptions([MZChannelSubscription]())
                
                gp.isLoading = false
                break
            }
        }
        self.uiTableView.reloadData()
    }
    
    func UDPDiscoverySuccess(_ channelTemplateId: String, data: NSArray)
    {
        self.delegate?.UDPDiscoverySuccess()
    }
    

    func updateTableWithChannelResults(channelTemplateId: String, data: NSArray)
    {
        var cleanedArray = self.removeDuplicates(array: data)
        
        for gp in viewModel!.groupedDevicesByProfile
        {
            if(gp.profile.identifier == channelTemplateId)
            {
                var subs = [MZChannelSubscription]()
                for  sub in (cleanedArray as! NSArray)
                {
                    var temp = MZChannelSubscription(dictionary: sub as! NSDictionary)
                }
                
                gp.updateChannelsSubscriptions(subs)
                gp.isLoading = false
                break
            }
        }
        self.uiTableView.reloadData()
    }
    
	func localDiscoverySuccess(_ profileId: String, data: NSDictionary)
	{
    }
    
    func removeDuplicates(array: NSArray) -> NSArray
    {
        let uniquearray =  Array(NSOrderedSet(array: array as! [Any]))
        return uniquearray as NSArray
    }
    
	
	func localDiscoveryNumberOfStepsUpdate(_ profileId: String, numberOfSteps: Int)
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
	
	func localDiscoveryStepUpdate(_ profileId: String, stepNumber: Int, stepDescription: String)
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
	
	func localDiscoveryUnsuccess(_ profileId: String)
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
	func tappedTryAgain(_ channelTemplate: MZChannelTemplate)
	{
		for gp in viewModel!.groupedDevicesByProfile
		{
			if(gp.profile.identifier == channelTemplate.identifier)
			{
				gp.isLoading = true
				break
			}
		}
        
        
		self.uiTableView.reloadData()
		
        if self.usingRecipes
        {
            // Retry step
            self.delegate?.didSelectRetry(channelTemplate: channelTemplate)
        }
        else
        {
            // Assume it's webview and get channels again (default)
            self.addDevicesInteractor!.getChannelsSubscriptions(channelTemplate, data: nil)
        }
	}
	
	// Validation of the groups to enable/disable the next button
	func triggerValidation()
	{
		for gp in self.viewModel!.groupedDevicesByProfile
		{
			if (!gp.isGroupValid())
			{
				updateNextButton(false)
				return
			}
		}
		
		updateNextButton(true)
	}
	
	func updateNextButton(_ enabled: Bool)
	{
		if(enabled)
		{
			self.uiBtNext.isEnabled = true
		}
		else
		{
			self.uiBtNext.isEnabled = false
		}
	}
}
