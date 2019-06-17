
//
//  MZFlowControllerAddBundle.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices

//import RxCocoa
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


@objc protocol MZFlowControllerAddServiceDelegate: NSObjectProtocol
{
	func showServices()
	func selectServiceSuccess(_ service:MZService)
	func selectServiceCancel()
	func oAuthUnsuccess(_ profileId: String)
	func oAuthSuccess(_ profileId: String)
	func tutorialFinishedSuccess()
	func tutorialGoBack()
	func summaryFinishedSuccess()
	func summaryFinishedUnsucess()
	func colorSelectionSuccess()
	func serviceGoToBeginning()
}

class MZFlowControllerAddService : MZFlowController,
								  MZServicesCollectionViewControllerDelegate,
								  MZTutorialViewControllerDelegate,
								  MZDynamicInfoScreenViewControllerDelegate,
								  MZServiceColorSelectionViewControllerDelegate,
								  MZDevicesSelectionViewControllerDelegate,
								  OAuthViewControllerDelegate,
								  MZAddServicesInteractorDelegate,
								  MZServiceActivationViewControllerDelegate,
                                  SFSafariViewControllerDelegate
{
    func didSelectRetry(channelTemplate: MZChannelTemplate) {
        
    }
    
    func UDPDiscoverySuccess() {
        
    }
    
    func devicesSelectionPressedBackButton()
    {
        serviceGoToBeginning()
    }

	
	let key_header_location = "Location"
	var interactor : MZAddServicesInteractor?
	
	var servicesVC: MZServicesCollectionViewController?
	var activationVC : MZServiceActivationViewController?

	var selectedService : MZService?
	
	var serviceProfiles = [MZChannelTemplate]()
	
	var channelsSubscriptions = [MZChannelSubscription]()
	
	var oAuthRequiredProfiles = [MZChannelTemplate]()

	
	var addedDevices = NSMutableArray()

	var deviceInteractor : MZDeviceInteractor?
	
    var oAuthVC : OAuthViewController?
    
    var isService : Bool = true

    
    
	override init()
	{
		super.init()
		self.deviceInteractor = MZDeviceInteractor()
		self.interactor = MZAddServicesInteractor()
		self.interactor?.delegate = self
		self.viewController = UINavigationControllerPortrait()
		self.viewController.navigationController?.setNavigationBarHidden(true, animated: false)
		self.servicesVC = MZServicesCollectionViewController()
		self.servicesVC?.delegate = self
		self.viewController.addChildViewController(servicesVC!)
		self.viewController.view.addSubview((servicesVC?.view)!)
		//self.resetValues()
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        //controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
	
    func applicationCalledByURLScheme()
    {
        onOAuthSuccess()
    }
    
	func resetValues()
	{
		self.selectedService = nil
		self.addedDevices = NSMutableArray()
		self.oAuthRequiredProfiles = [MZChannelTemplate]()
		self.channelsSubscriptions = [MZChannelSubscription]()
		self.serviceProfiles = [MZChannelTemplate]()
	}
	


    func fetchServices()
    {
		self.interactor?.getServices()
    }
	
	func didSelectService(_ service:MZService)
	{
        self.servicesVC?.updateLoadingStatus(true)
		self.serviceProfiles.removeAll()
		self.oAuthRequiredProfiles.removeAll()
		
		self.selectedService = service
		
        if(self.selectedService!.profiles.count > 0)
        {
            getProfiles()
        }
        else
        {
            self.pushFirstServiceView()
        }
    }
    
	
	func didFinishTutorial()
	{
		if(self.selectedService?.profiles.count > 0)
		{
			if(oAuthRequiredProfiles.count > 0)
			{
				pushDeviceOAuthView(oAuthRequiredProfiles[0])
			}
			else
			{
				pushDevicesSelectionView()
			}
		}
		else
		{
			pushLastScreen(nil, otherBulbId: nil)
		}
	}
	
	func tutorialCancel()
	{
		serviceGoToBeginning()
	}
	
	func oAuthUnsuccess(_ profileId: String)
	{
		serviceGoToBeginning()
	}
	
	func onOAuthSuccess()
	{
		if(self.oAuthRequiredProfiles.count > 0)
		{
			self.oAuthRequiredProfiles.removeFirst()
		}
		if oAuthRequiredProfiles.count > 0
		{
			self.pushDeviceOAuthView(self.oAuthRequiredProfiles[0])
		}
		else
		{
			self.pushDevicesSelectionView()
		}
	}
	
	
	func didAddDevices(_ addedDevices: NSArray)
	{
		self.addedDevices.removeAllObjects()
        
		self.addedDevices.addObjects(from: (addedDevices as! [Any]))
		
		if(self.selectedService!.id ==  Bundle.main.infoDictionary?["MUZZLEY_VODAFONE_PARENTING_BUNDLEID"] as? String )
		{
			if( addedDevices.count > 0)
			{
				var philipsHueIds = [String]()
				
				for devicesByProfile in addedDevices
				{
                    for device in devicesByProfile as! NSArray
                    {
                        if(((device as! NSDictionary).value(forKey: "profileId") as! String) == Bundle.main.infoDictionary?["MUZZLEY_PHILIPSHUE_PROFILEID"] as? String)
                        {
                            philipsHueIds.append(((device as! NSDictionary).value(forKey: "id") as! String))
                        }
                    }
				}
			
				if(philipsHueIds.count == 2)
				{
					pushColorSelectionView(Bundle.main.infoDictionary?["MUZZLEY_PHILIPSHUE_PROFILEID"] as! String , channels: philipsHueIds)
					return
				}
				
			}
		}
		
		pushLastScreen(nil, otherBulbId: nil)
	}
	
	func devicesSelectionUnsuccess()
	{
		serviceGoToBeginning()
	}
	
	func didFinishInfoScreen()
	{
		self.goToHome()
	}
    
    func didPressBackOnInfoScreen() {
        // Do nothing here
    }
	
	func goToHome()
	{
		// Go back to home and refresh devices
		self.viewController.navigationController?.popToRootViewController(animated: false)
		NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
        if self.isService
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowServicesTab"), object: nil)
        }
	}
	
	func oAuthViewControllerDidCancelAuthentication(_ oAuthViewController: OAuthViewController!)
	{
		self.serviceGoToBeginning()
	}
	
	func oAuthViewControllerDidAuthenticate(_ oAuthViewController: OAuthViewController)
	{
		onOAuthSuccess()
	}

	func oAuthViewControllerDidFailAuthentication(_ oAuthViewController: OAuthViewController)
	{
		let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_activation_error_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
		}))
		
		self.viewController.present(alert, animated: true, completion: nil)
	}
	
	func getProfiles()
	{
		serviceProfiles.removeAll()
		var tasks : [Observable<AnyObject>] = []

		for p in (self.selectedService?.profiles)!
		{
            tasks.append(MZServicesDataManager.sharedInstance.getObservableOfChannelTemplateById(p.id))
		}
		
		Observable<Any>.zip(tasks) {return $0}.subscribe(
			onNext:{
				results in
			
				if((results as! NSArray).count > 0)
				{
					for res in results as! [MZChannelTemplate]
					{
						if(res.requiredCapability == "discovery-webview")
						{
							self.oAuthRequiredProfiles.append(res)
						}
					
                        if(!self.serviceProfiles.contains(res))
                        {
                            self.serviceProfiles.append(res)
                        }
					}
				
					self.pushFirstServiceView()
				}
				else
				{
                    self.servicesVC?.updateLoadingStatus(false)
				}

			}, onError:{ error in

                self.servicesVC?.updateLoadingStatus(false)

				let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
					self.serviceGoToBeginning()
					return
				}))
				self.viewController.present(alert, animated: true, completion: nil)
			}
		)
	}
	
	
	func pushFirstServiceView()
	{
		if (selectedService!.requiredCapability.isEmpty)
		{
			if(self.selectedService?.tutorial.steps.count > 0)
			{
				self.pushTutorialView((self.selectedService?.tutorial)!)
			}
			else
			{
				if (self.selectedService?.profiles.count > 0)
				{
					self.pushDevicesSelectionView()
				}
				else
				{
					self.pushSummaryView((self.selectedService?.summary)!)
				}
			}
		}
		else
		{
			getServiceAuthorization()
		}
	}
	
	func getServiceAuthorization()
	{
		let serviceAuthorizationObservable = MZServicesDataManager.sharedInstance.getObservableOfServiceAuthorizationUrl((self.selectedService?.id)!)
		_ = serviceAuthorizationObservable.subscribe(
			onNext:{(result) -> Void in
				// Not the success case
				
			}, onError:{(error) -> Void in
				
				let authorizationUrl = (error as NSError).userInfo[self.key_header_location] as? String
				if(authorizationUrl != nil && NSURL(string: authorizationUrl!) != nil)
				{
					self.pushServiceActivationView(self.selectedService!, authorizationUrl: URL(string: authorizationUrl!))
				}
				else
				{
					let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_activation_error_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
					}))

					self.viewController.present(alert, animated: true, completion: nil)
                    self.servicesVC?.updateLoadingStatus(false)

				}
		})

	}
	
	func pushServiceActivationView(_ service: MZService, authorizationUrl: URL?)
	{
		self.activationVC = MZServiceActivationViewController()
		self.activationVC?.title = service.name
		self.activationVC?.service = service
		self.activationVC?.shopUrl = service.shopUrl
		
		var authUrl = authorizationUrl!
		
		if(authUrl.scheme == "http" || authUrl.scheme! == "https")
		{
			self.activationVC?.activationMode = MZActivationModeEnum.oAuth
		}
		
		if(authUrl.scheme == "muzdiscovery")
		{
			
			var urlComponents = URLComponents()
			urlComponents.scheme = "http"
			urlComponents.host = authUrl.host
			urlComponents.path = authUrl.path
			
			authUrl = urlComponents.url!
		}
		
		if( authUrl.scheme == "muzdiscoverys" )
		{
			var urlComponents = URLComponents()
			urlComponents.scheme = "https"
			urlComponents.host = authUrl.host
			urlComponents.path = authUrl.path
			
			authUrl = urlComponents.url!
		}
		
		self.activationVC?.authorizationUrl = authUrl
		self.activationVC?.delegate = self
		
		self.viewController.navigationController?.pushViewController(self.activationVC!, animated: false)
	}
	
	func pushDeviceOAuthView(_ profile: MZChannelTemplate)
	{
		MZChannelsWebService.sharedInstance.getProfileAuthorization(profile.identifier, completion: { (responseObject, error) in
			if (error != nil)
			{
                let err = error as! NSError
                if(err.domain == "HTTPDomain" && err.code == 303)
                {
                    let url = URL(string: err.userInfo["Location"] as! String)
                    let customHeadersStr = err.userInfo["CustomHeaders"] as? String
                    
                    if(customHeadersStr != nil && !customHeadersStr!.isEmpty)
                    {
                        self.oAuthVC =  OAuthViewController(nibName: SCREEN_ID_CHANNEL_OAUTH, bundle: Bundle.main)
                        self.oAuthVC?.delegate = self;
                        
                        self.oAuthVC?.urlHost = url;
                        if customHeadersStr != nil && !(customHeadersStr?.isEmpty)!
                        {
                            self.oAuthVC?.customHeaders = MZJsonHelper.convertStringToDictionary(text: customHeadersStr!)
                        }
                        self.oAuthVC?.title = profile.name
                        self.viewController.navigationController?.pushViewController(self.oAuthVC!, animated: false)
                    }
                    else
                    {
                        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationCalledByURLScheme), name: NSNotification.Name(rawValue: AppManagerDidReceiveMuzzleyURLSchema), object: nil)
                        
                        let safariVC = SFSafariViewController(url: url!)
                        safariVC.delegate = self
                        safariVC.title = profile.name
                        
                        self.viewController.navigationController?.pushViewController(safariVC, animated: false)
                    }
                    self.servicesVC?.updateLoadingStatus(false)

                }
                else
                {
                    let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_activation_error_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                        self.serviceGoToBeginning()
                        return
                        
                    }))
                    
                    self.viewController.present(alert, animated: true, completion: nil)
                }
			}
		})
	}
	
	func pushTutorialView(_ serviceTutorial: MZServiceTutorial)
	{
        self.servicesVC?.updateLoadingStatus(false)
        
		let tutorialVM = MZTutorialViewModel(model: serviceTutorial)
		let tutorialVC = MZTutorialViewController(tutorial: tutorialVM)
		tutorialVC.delegate = self
		self.viewController.navigationController?.pushViewController(tutorialVC, animated: false)
	}
	
	
	func pushLastScreen(_ selectedBulbId: String?, otherBulbId: String?)
	{
        self.servicesVC?.updateLoadingStatus(false)
		sendAddServicePost(self.selectedService!.id, addedDevices: self.addedDevices, selectedBulbId: selectedBulbId, otherBulbId: otherBulbId) { (success, error) in
			if(error == nil)
			{
				if(success)
				{
					self.pushSummaryView(self.selectedService!.summary)
				}
				else
				{
					let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_activation_error_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
						return
					}))
					
					self.viewController.present(alert, animated: true, completion: nil)
				}
			}
			else
			{
				var errorMessage =  NSLocalizedString("mobile_activation_error_message", comment: "")
				let xcode = ((error as! NSError).userInfo["com.alamofire.serialization.response.error.response"] as! HTTPURLResponse).allHeaderFields["X-Error"] as? String
				if(xcode != nil)
				{
					switch xcode!
					{
					case "5000":
						errorMessage =  NSLocalizedString("mobile_service_already_subscribed", comment: "")
						break
						
					default:
						break
					}
				}
				
				let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
					self.goToHome()
				}))
				
				self.viewController.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	
	func pushSummaryView(_ summary : MZServiceSummary)
	{
        self.servicesVC?.updateLoadingStatus(false)
        
        let summaryVC = MZDynamicInfoScreenViewController(screenInfo: MZDynamicInfoScreenViewModel( navigationBarTitle:  NSLocalizedString("mobile_service_summary", comment: ""), topImageUrl: summary.topUrl, bottomImageUrl: summary.botUrl, title: summary.title, text: summary.body, buttonText: NSLocalizedString("mobile_done", comment: ""), infoUrl: nil, isBackButtonEnabled: false))
        summaryVC.delegate = self
        summaryVC.showBackButton = false
        self.viewController.navigationController?.pushViewController(summaryVC, animated: false)
	}
	
	func sendAddServicePost(_ serviceId: String, addedDevices : NSArray, selectedBulbId: String?, otherBulbId : String?, completion: @escaping (_ success: Bool, _ error : NSError?) -> Void)
	{
		var payload = NSDictionary()
		switch(serviceId)
		{
			case Bundle.main.infoDictionary?["MUZZLEY_VODAFONE_PARENTING_BUNDLEID"] as! String:
			
			var cameraId = ""
			var lightBulb1 = selectedBulbId
			var lightBulb2 = otherBulbId
		
            for devicesByProfile in addedDevices
            {
                for device in devicesByProfile as! NSArray
                {
                    if(((device as! NSDictionary).value(forKey: "profileId") as! String) != Bundle.main.infoDictionary?["MUZZLEY_PHILIPSHUE_PROFILEID"] as? String)
                    {
                        cameraId = (device as! NSDictionary).value(forKey: "id") as! String
                    }
                }
            }
            
			payload = NSDictionary(dictionary: ["camera" : ["channel_id" : cameraId], "room_bulb" : ["channel_id" : lightBulb1!], "other_bulb" : ["channel_id" : lightBulb2!]])

			
			break;
			
			case Bundle.main.infoDictionary?["MUZZLEY_VODAFONE_SECURITY_BUNDLEID"] as! String:
			
				var cameraId = ""
				var lightBulb1 = ""
				var lightBulb2 = ""

                
                for devicesByProfile in addedDevices
                {
                    for device in devicesByProfile as! NSArray
                    {
                        if(((device as! NSDictionary).value(forKey: "profileId") as! String) == Bundle.main.infoDictionary?["MUZZLEY_PHILIPSHUE_PROFILEID"] as? String)
                        {
                            if(lightBulb1.isEmpty)
                            {
                                lightBulb1 = (device as! NSDictionary).value(forKey: "id") as! String
                            }
                            else if (lightBulb2.isEmpty)
                            {
                                lightBulb2 = (device as! NSDictionary).value(forKey: "id") as! String
                            }
                        }
                        else
                        {
                            cameraId = (device as! NSDictionary).value(forKey: "id") as! String
                        }
                    }
                }
                
                
				payload = NSDictionary(dictionary: ["camera" : ["channel_id" : cameraId], "room_bulb" : ["channel_id" : lightBulb1], "other_bulb" : ["channel_id" : lightBulb2]])
			break
			default:
				break
		}
		
		MZServicesDataManager.sharedInstance.subscribeToService(self.selectedService!.id, payload: payload, completion: { (result, error) in
			if(error == nil)
			{
				completion(true, nil)
			}
			else
			{
				completion(false, error)
			}
		})

}


	func pushDevicesSelectionView()
	{
        self.servicesVC?.updateLoadingStatus(false)
		// Send the channels and the profiles
        let devicesSelectionVC = MZDevicesSelectionViewController(viewModel: MZDevicesSelectionViewModel(service: selectedService!, profiles: serviceProfiles), deviceInteractor: self.deviceInteractor!, usingRecipes : false)
		devicesSelectionVC.delegate = self as! MZDevicesSelectionViewControllerDelegate
		self.viewController.navigationController?.pushViewController(devicesSelectionVC, animated: false)
	}
	
	func pushColorSelectionView(_ profile: String, channels: [String])
	{
        self.servicesVC?.updateLoadingStatus(false)
		let colorSelectionVC = MZServiceColorSelectionViewController(serviceInteractor: self.interactor!, profile: profile, channels: channels)
		colorSelectionVC.delegate = self
		self.viewController.navigationController?.pushViewController(colorSelectionVC, animated: false)
	}
	
	func activationSuccessful()
	{
        self.servicesVC?.updateLoadingStatus(false)
		if(self.selectedService?.tutorial.steps.count > 0)
		{
			self.pushTutorialView((self.selectedService?.tutorial)!)
		}
		else
		{
			if (self.selectedService?.profiles.count > 0)
			{
				self.pushDevicesSelectionView()
			}
			else
			{
				pushLastScreen(nil, otherBulbId: nil)
			}
		}
	}

	func activationUnsuccessful()
	{
        self.servicesVC?.updateLoadingStatus(false)
		self.activationVC?.delegate = nil
		serviceGoToBeginning()
		
	}
	
	func selectColorSuccess(_ selectedChannelId: String, otherChannelId: String)
	{
		
		if(self.selectedService!.id == Bundle.main.infoDictionary?["MUZZLEY_VODAFONE_PARENTING_BUNDLEID"] as? String)
		{
			self.pushLastScreen(selectedChannelId, otherBulbId: otherChannelId)
		}
		else
		{
			// SHOULDN'T Happen
		}
	}


	func selectColorUnsuccess()
	{
		self.serviceGoToBeginning()

	}
	
	func serviceGoToBeginning()
	{
        self.servicesVC?.updateLoadingStatus(false)

		//self.resetValues()
		self.viewController.navigationController?.popToViewController((self.viewController.navigationController?.viewControllers[1])!, animated: false)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
        if self.isService
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowServicesTab"), object: nil)
        }
	}
	
}
