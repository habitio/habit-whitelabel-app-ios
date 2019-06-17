//
//  MZFlowControllerAddDevice.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 02/08/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
import SafariServices
import RxSwift

@objc protocol MZFlowControllerAddDeviceDelegate: NSObjectProtocol
{
	func getChannelTemplatesFinished()
	func getChannelTemplatesFinishedWithError()
}

class MZFlowControllerAddDevice : MZFlowController,
    OAuthViewControllerDelegate,
    MZChannelTemplatesCollectionViewControllerDelegate,
    MZDevicesSelectionViewControllerDelegate,
    MZRecipesFlowDelegate,
    SFSafariViewControllerDelegate
{
  
	var selectedChannelTemplate : MZChannelTemplate?
	var deviceInteractor : MZDeviceInteractor?
	var delegate : MZFlowControllerAddDeviceDelegate?
	var oAuthVC : OAuthViewController?
	var profilesVC : MZChannelTemplatesCollectionViewController?
    let disposeBag = DisposeBag()
    var recipesFlow : MZRecipesFlow?
	
	override  init()
	{
		super.init()
		
		self.deviceInteractor = MZDeviceInteractor()
		self.viewController = UINavigationControllerPortrait()
		self.viewController.navigationController?.setNavigationBarHidden(true, animated: false)

		self.pushProfilesSelectionView()
	}
	
    func applicationCalledByURLScheme()
    {
        self.pushDevicesSelectionView()
    }
	
    func recipeProcessError() {
        
    }
    
    func didSelectRetry(channelTemplate: MZChannelTemplate) {
        
    }
    
    func UDPDiscoverySuccess() {
        
    }
    
    
    
    func channelTemplatesViewControllerDidCancelAction(_ viewController: MZChannelTemplatesCollectionViewController) {
        
    }

    
    
    
    
    func devicesSelectionPressedBackButton()
    {
        self.goToBeginning()
    }
    
    
    func pushDevicesSelectionView()
    {
        // Send the channels and the profiles
        let devicesSelectionVC = MZDevicesSelectionViewController(viewModel: MZDevicesSelectionViewModel(profiles: [self.selectedChannelTemplate!]), deviceInteractor: self.deviceInteractor!, usingRecipes: false)
        devicesSelectionVC.delegate = self
        self.viewController.navigationController?.pushViewController(devicesSelectionVC, animated: false)
    }
    
    
    func didAddDevices(_ addedDevices: NSArray)
    {
        self.viewController.navigationController?.popToRootViewController(animated: false)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
    }
    
	func devicesSelectionUnsuccess()
	{
		// Go to beginning
		self.goToBeginning()
    }
    
    
    func oAuthViewControllerDidCancelAuthentication(_ oAuthViewController: OAuthViewController!)
    {
        self.goToBeginning()
    }
    
    func oAuthViewControllerDidAuthenticate(_ oAuthViewController: OAuthViewController)
    {
        self.pushDevicesSelectionView()
	}

    
    func oAuthViewControllerDidFailAuthentication(_ oAuthViewController: OAuthViewController!) {
        let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
        }))
        
        self.viewController.present(alert, animated: true, completion: nil)
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
				}
				else
				{
					let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_activation_error_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                        for cvc in self.viewController.childViewControllers
                        {
                            if cvc is MZChannelTemplatesCollectionViewController
                            {
                                (cvc as! MZChannelTemplatesCollectionViewController).updateLoadingStatus(false)
                            }
                        }
						self.goToBeginning()
						return
						
					}))
					
					self.viewController.present(alert, animated: true, completion: nil)
				}
			}
		})
	}
	
	func pushProfilesSelectionView()
	{
		self.profilesVC = MZChannelTemplatesCollectionViewController(nibName: "MZChannelTemplatesCollectionViewController", bundle: Bundle.main)
		self.profilesVC?.delegate = self
		self.profilesVC?.title = NSLocalizedString("mobile_new_device_title", comment: "")
     
		self.viewController.addChildViewController(self.profilesVC!)
		self.viewController.view.addSubview((self.profilesVC?.view)!)
	}
	
	func getChannelTemplatesFinished()
	{
		if(self.delegate != nil)
		{
			self.delegate?.getChannelTemplatesFinished()
		}
	}
	
	
	func getChannelTemplatesFinishedWithError()
	{
		if(self.delegate != nil)
		{
			self.delegate?.getChannelTemplatesFinishedWithError()
		}
	}
	

	
	func channelTemplatesViewController(_ viewController: MZChannelTemplatesCollectionViewController, didSelectChannelTemplate channelTemplate: MZChannelTemplate)
	{
		self.selectedChannelTemplate = channelTemplate
        
        if(self.selectedChannelTemplate?.recipeId == nil || self.selectedChannelTemplate!.recipeId.isEmpty)
        {
            if  self.selectedChannelTemplate?.requiredCapability == nil || self.selectedChannelTemplate?.requiredCapability == "discovery-recipe"
            {
                self.pushDevicesSelectionView()
            }
            else
            {
                self.pushDeviceOAuthView(self.selectedChannelTemplate!)
            }
        }
        else
        {
            var parameters = [String: [String : Any]]()
            parameters["channel_templates"] = [self.selectedChannelTemplate!.identifier : self.selectedChannelTemplate!]
            
            self.recipesFlow = MZRecipesFlow(recipeId: self.selectedChannelTemplate!.recipeId, recipeProcess: MZRecipesProcesses.AddDeviceProcess, parameters: parameters as! [String: [String : Any]]?, viewController : self.viewController)
        }
	}

	func goToBeginning()
	{
		self.viewController.navigationController?.popToViewController((self.viewController.navigationController?.viewControllers[1])!, animated: false)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
	}
}
