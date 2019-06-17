//
//  MZRecipeManager.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation
import SafariServices
import RxSwift

class MZRecipesProcesses
{
    static let AddDeviceProcess = "mz_wl_add_device_process"
}   

class MZRecipesActions
{
    static let ShowInfo = "show_info"
    static let OAuth = "oauth"
    static let ListDevices = "list_devices"
    static let SendSelectedDevices = "send_selected_devices"
    static let UDP = "udp"
    static let ConvertForShow = "convert_for_show"
    static let ShowDevices = "show_devices"
    static let GrantAppAccess = "grant_access_app"
    static let GrantUserAccess = "grant_access_user"
}



@objc protocol MZRecipesFlowDelegate: NSObjectProtocol
{
    func recipeProcessError()
}


class MZRecipesFlow : MZFlowController,
    MZDynamicInfoScreenViewControllerDelegate,
    OAuthViewControllerDelegate,
    MZDevicesSelectionViewControllerDelegate,
    MZAddDevicesInteractorDelegate,
    SFSafariViewControllerDelegate
{
    func UDPDiscoverySuccess() {
        
    }
    
    func UDPDiscoverySuccess(_ channelTemplateId: String, data: NSArray) {
        self.recipeParameters!["found_devices"] = [channelTemplateId : data]
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    func UDPDiscoveryUnsuccess(_ channelTemplateId: String) {
        self.showDevicesList()
    }
    
    let disposeBag = DisposeBag()
    
    let key_channelTemplateId = "channeltemplate_id"
    let key_channelTemplate = "channel_template"

    let key_process = "process"
    let key_client_id = "client_id"
    let key_owner_id = "owner_id"
    let key_payload = "payload"
    
    var devicesSelectionVC : MZDevicesSelectionViewController?
    var addDevicesInteractor : MZAddDevicesInteractor?
    var oAuthVC : OAuthViewController?

    var groupedDevicesByProfile : [MZProfileDevicesViewModel]?
    
    var currentStep : MZRecipeStep?
    var recipeId : String?
    var recipeProcess : String?
    var recipesInteractor : MZRecipesInteractor?
    var recipeParameters : [String : [String: Any]]?
    
    init(recipeId: String, recipeProcess : String, parameters : [String : [String: Any]]?, viewController: UIViewController)
    {
        super.init()
        
        self.recipeId = recipeId
        self.recipeProcess = recipeProcess
        self.recipeParameters = parameters
        self.viewController = viewController
        
        self.recipesInteractor = MZRecipesInteractor()
        self.addDevicesInteractor = MZAddDevicesInteractor()
        self.addDevicesInteractor?.delegate = self
        self.groupedDevicesByProfile = nil
        startProcess()
    }

    func applicationCalledByURLScheme()
    {
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    func startProcess()
    {
        self.recipesInteractor?.requestRecipeMetadata(recipeId: self.recipeId!, completion: { (metadata, error) in
            if error != nil
            {
                // Show error
                return
            }
            
            if metadata != nil
            {
                self.processRecipeFirstStep(metadata: metadata as! MZRecipeMetadata)
            }
        })
    }
    
    func getMetadataVariables(metadata: MZRecipeMetadata)
    {
        
    }
    
    
    func didSelectRetry(channelTemplate: MZChannelTemplate) {
        // Repeat the last step
        self.performStep(step: self.currentStep!)
    }
    
    func processRecipeFirstStep(metadata : MZRecipeMetadata)
    {
        let channelTemplate = (self.recipeParameters!["channel_templates"] as! [String : Any]?)!.first?.value as! MZChannelTemplate
        
        var payload = NSDictionary(dictionary: [self.key_process : self.recipeProcess!,
                                                self.key_channelTemplateId : channelTemplate.identifier,
                                                self.key_client_id : MZSession.sharedInstance.authInfo!.clientId,
                                                self.key_owner_id : MZSession.sharedInstance.authInfo!.userId])
        self.recipesInteractor!.executeRecipeStep(url: metadata.nextStepMeta!.nextStepUrl!, header: nil, payload: payload, completion: { (resultStep, error) in
            if error != nil
            {
                // Show error
            }
            
            if resultStep != nil
            {
               self.performStep(step: resultStep as! MZRecipeStep)
            }
        })
    }
    
    func showErrorAndGoToHome()
    {
        let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
            self.goToTilesScreen(refreshTabs: true)
            
        }))
        self.viewController.present(alert, animated: true, completion: nil)
        return
    }
    
    func performStep(step : MZRecipeStep)
    {
        self.currentStep = step
        
        if(self.currentStep == nil || self.currentStep!.action == nil)
        {
            self.showErrorAndGoToHome()
        }

        switch self.currentStep!.action! {
            
        case MZRecipesActions.ShowInfo:
             var supportedActionVersions = ["v1", ""]
             if(!supportedActionVersions.contains(currentStep!.actionVersion!))
             {
                // Show error
                self.showErrorAndGoToHome()
                return
             }
          
             pushDynamicInfoView(MZRecipeActionShowInfo(dictionary: self.currentStep?.payload as! NSDictionary))
        
            break
    
        case MZRecipesActions.OAuth:
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            self.performOAuth(step: self.currentStep!)
            break
            
        case MZRecipesActions.ListDevices:
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            self.showDevicesList()
            break
        
        case MZRecipesActions.SendSelectedDevices:
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            self.sendSelectedDevices(actionInfo: MZRecipeActionSendSelectedDevices(dictionary: self.currentStep?.payload as! NSDictionary)) { (success, error) in
                self.processNextRecipeStep(step: self.currentStep!)
            }
            break
        
        case MZRecipesActions.UDP:
            
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            
            let recipeActionUDP = MZRecipeActionUDP(dictionary: self.currentStep!.payload as! NSDictionary)
            if recipeActionUDP != nil && (recipeActionUDP?.process == self.recipeProcess &&
                recipeActionUDP!.ownerId == MZSession.sharedInstance.authInfo!.userId &&
                recipeActionUDP!.clientId == MZSession.sharedInstance.authInfo!.clientId)
            {
                findDevicesViaUDP(channelTemplateId:  recipeActionUDP!.channelTemplateId!, actionInfo: recipeActionUDP!)
                // Show devices list and Start UDP
            }
            else
            {
                // Show error
                let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                    self.goToTilesScreen(refreshTabs: true)
                    
                }))
                self.viewController.present(alert, animated: true, completion: nil)
                return
            }

            break
            
            
        case MZRecipesActions.ConvertForShow:
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            self.convertToChannelSubscriptions(actionInfo: MZRecipeActionConvertForShow(dictionary: self.currentStep?.payload as! NSDictionary))
            break
            
        case MZRecipesActions.ShowDevices:
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            // Populate devices list screen with the obtained results
            self.showDevicesList()
            break
            
        case MZRecipesActions.GrantAppAccess:
            // Request grant app access via mqtt
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            
            var tasks: [Observable<AnyObject>] = []

            for group in groupedDevicesByProfile!
            {
                tasks.append(self.addDevicesInteractor!.requestGrantAppAccess(group: group))
            }
            
            Observable<Any>.zip(tasks) { return $0 }.subscribe(onNext:
                { results in
                    self.processNextRecipeStep(step: self.currentStep!)
            }, onError: { error in
                let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                    self.goToTilesScreen(refreshTabs: true)
                    
                }))
                self.viewController.present(alert, animated: true, completion: nil)
            }, onCompleted: {})
                .addDisposableTo(self.disposeBag)
            break
            
        case MZRecipesActions.GrantUserAccess:
            // Request grant user access via mqtt
            
            var supportedActionVersions = ["v1", ""]
            if(!supportedActionVersions.contains(currentStep!.actionVersion!))
            {
                // Show error
                self.showErrorAndGoToHome()
                return
            }
            
            var tasks: [Observable<AnyObject>] = []

            for group in groupedDevicesByProfile!
            {
                tasks.append((self.addDevicesInteractor!.requestGrantUserAccess(group: group)))
            }

            Observable<Any>.zip(tasks) { return $0 }.subscribe(onNext:
                { results in
                    self.processNextRecipeStep(step: self.currentStep!)
            }, onError: { error in
                let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                    self.goToTilesScreen(refreshTabs: true)

                }))
                self.viewController.present(alert, animated: true, completion: nil)
            }, onCompleted: {})
                .addDisposableTo(self.disposeBag)
        
            break
            
        default:
            // Show error
            self.showErrorAndGoToHome()
            return
        }
    }
    
    func convertToChannelSubscriptions(actionInfo: MZRecipeActionConvertForShow)
    {
        let channelTemplates = self.recipeParameters!["channel_templates"] as! [String : Any]
        
        print((self.recipeParameters!["found_devices"] as! [String : Any])[actionInfo.channelTemplateID!]) // as! [String : Any])[actionInfo.channelTemplateID!])
        
        let foundDevices = actionInfo.devices != nil ? actionInfo.devices : (self.recipeParameters!["found_devices"] as! [String : Any])[actionInfo.channelTemplateID!]
        
        let photoUrl = (channelTemplates[actionInfo.channelTemplateID!] as! MZChannelTemplate).photoUrl
        let chanSubs = MZFibaroSubscriptionConverter.convertToChannelSubscriptionsFormat(array: foundDevices as! [NSDictionary], photoUrl: photoUrl)
        if chanSubs == nil
        {
            let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                self.goToTilesScreen(refreshTabs: true)
            }))
            self.viewController.present(alert, animated: true, completion: nil)
            return
        }
        
        self.recipeParameters!["found_devices"]![actionInfo.channelTemplateID!] = chanSubs
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    
    func findDevicesViaUDP(channelTemplateId: String, actionInfo: MZRecipeActionUDP)
    {
        self.addDevicesInteractor?.findDevicesUDP(channelTemplateId: channelTemplateId, udpActionInfo: actionInfo)
    }
    
    func sendSelectedDevices(actionInfo: MZRecipeActionSendSelectedDevices, completion: @escaping (_ result: Bool, _ error : NSError?) -> Void)
    {
        if(self.groupedDevicesByProfile != nil)
        {
            for group in self.groupedDevicesByProfile!
            {
                var tasks: [Observable<AnyObject>] = []
                
                for group in groupedDevicesByProfile!
                {
                    tasks.append(self.addDevicesInteractor!.createChannelsWithPost(group: group))
                }
                Observable<Any>.zip(tasks) { return $0 }.subscribe(onNext:
                    { results in
                        print(results)
                        completion(true, nil)
                }, onError: { error in
                    print(error)
                    completion(false, error as! NSError)
//                    completion(false, error)
                }, onCompleted: {})
                    .addDisposableTo(self.disposeBag)
            }
        }
    }
    
    func showDevicesList()
    {
//      Send the channels and the profiles
         let channelTemplate = (self.recipeParameters!["channel_templates"] as! [String : Any]?)!.first?.value as! MZChannelTemplate
        
        self.devicesSelectionVC = MZDevicesSelectionViewController(viewModel: MZDevicesSelectionViewModel(profiles: [channelTemplate]), deviceInteractor: MZDeviceInteractor(), usingRecipes : true, recipeParameters: self.recipeParameters)
        self.devicesSelectionVC!.delegate = self
        self.viewController.navigationController?.pushViewController(self.devicesSelectionVC!, animated: false)
    }
    
    func didAddDevices(_ addedDevices : NSArray)
    {
        self.goToTilesScreen(refreshTabs: true)
    }
    
    func didSelectDevices(_ groupedDevicesByProfile: Any)
    {
        self.groupedDevicesByProfile = groupedDevicesByProfile as! [MZProfileDevicesViewModel]
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    func devicesSelectionUnsuccess()
    {
        // Go to beginning
        self.goToAddTilesScreen()
    }
    
    func devicesSelectionPressedBackButton()
    {
        self.goToAddTilesScreen()
    }
    
    func createChannelsUnsuccess(_ error : NSError)
    {
    
    }
    
    func createChannelsSuccess(_ results : [[NSDictionary]])
    {
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    func performOAuth(step: MZRecipeStep)
    {
       
        let channelTemplate = (self.recipeParameters!["channel_templates"] as! [String : Any]?)!.first?.value as! MZChannelTemplate
        
        var oAuthActionInfo = MZRecipeActionOAuth(dictionary : step.payload as! NSDictionary)
        
        var path = MZEndpoints.apiHost() + oAuthActionInfo.authorizationUrl!

        self.recipesInteractor?.getAuthorizationWithURL(url: path, completion: { (result, error) in

            // Handle error. get location and call viewcontroller
            if((error as! NSError).domain == "HTTPDomain" && (error as! NSError).code == 303)
            {
                var url = URL(string: (error as! NSError).userInfo["Location"] as! String)!
                let customHeadersStr = (error as! NSError).userInfo["CustomHeaders"] as? String

                if(customHeadersStr != nil && !customHeadersStr!.isEmpty)
                {
                    self.oAuthVC =  OAuthViewController(nibName: SCREEN_ID_CHANNEL_OAUTH, bundle: Bundle.main)
                    self.oAuthVC?.delegate = self;
                    self.oAuthVC?.urlHost = url;
                    if customHeadersStr != nil && !(customHeadersStr?.isEmpty)!
                    {
                        self.oAuthVC?.customHeaders = MZJsonHelper.convertStringToDictionary(text: customHeadersStr!)
                    }
                    self.oAuthVC?.title = channelTemplate.name
                    self.viewController.navigationController?.pushViewController(self.oAuthVC!, animated: false)
                }
                else
                {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.applicationCalledByURLScheme), name: NSNotification.Name(rawValue: AppManagerDidReceiveMuzzleyURLSchema), object: nil)
                    
                    let safariVC = SFSafariViewController(url: url)
                    safariVC.delegate = self
                    safariVC.title = channelTemplate.name
                   
                    self.viewController.navigationController?.pushViewController(safariVC, animated: false)
                }
            }
            else
            {
                let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
                    for cvc in self.viewController.childViewControllers
                    {
                        if cvc is MZChannelTemplatesCollectionViewController
                        {
                            (cvc as! MZChannelTemplatesCollectionViewController).updateLoadingStatus(false)
                        }
                    }
                    self.goToAddTilesScreen()
                    return
                }))
                
                self.viewController.present(alert, animated: true, completion: nil)
            }
        })
    }

    func safariViewControllerDidFinish(controller: SFSafariViewController) 
    {
        //controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pushDynamicInfoView(_ info: MZRecipeActionShowInfo)
    {
        var backButtonEnabled = true

        if info.cancelType == nil
        {
            backButtonEnabled = false
        }
        
        let infoVC = MZDynamicInfoScreenViewController(screenInfo: MZDynamicInfoScreenViewModel(navigationBarTitle: info.navigationBarTitle, topImageUrl: info.topImageUrl, bottomImageUrl: info.bottomImageUrl, title: info.title, text: info.message, buttonText: NSLocalizedString(info.nextLocalKey!, comment: ""), infoUrl: info.infoUrl, isBackButtonEnabled: backButtonEnabled))
        infoVC.delegate = self
        self.viewController.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    func processNextRecipeStep(step : MZRecipeStep)
    {
        
        let channelTemplate = (self.recipeParameters!["channel_templates"] as! [String : Any]?)!.first?.value as! MZChannelTemplate
        var payload = NSDictionary(dictionary: [self.key_process : self.recipeProcess!,
                                                self.key_channelTemplateId : channelTemplate.identifier,
                                                self.key_client_id : MZSession.sharedInstance.authInfo!.clientId,
                                                self.key_owner_id : MZSession.sharedInstance.authInfo!.userId])
        
        if(step.nextStep != nil)
        {
            self.recipesInteractor!.executeRecipeStep(url: step.nextStep!.nextStepUrl!, header: nil, payload: payload, completion: { (resultStep, error) in
                if error != nil
                {
                    // Show error
                }
                
                if resultStep != nil
                {
                    self.currentStep = resultStep as! MZRecipeStep
                    self.performStep(step: resultStep as! MZRecipeStep)
                }
            })
        }
        else
        {
            switch self.recipeProcess!
            {
            case MZRecipesProcesses.AddDeviceProcess:
                NotificationCenter.default.post(name: Notification.Name(rawValue: "DeviceAddedNotification"), object: nil)
               self.goToTilesScreen(refreshTabs: true)
                break
            default:
                // Show error. Can't process.
                break
            }
        }
    }
    
    func goToTilesScreen(refreshTabs : Bool)
    {
        self.viewController.navigationController?.popToRootViewController(animated: true)
        if(refreshTabs)
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
        }
    }
    
    func goToAddTilesScreen()
    {
        self.viewController.navigationController?.popToViewController((self.viewController.navigationController?.viewControllers[1])!, animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
    }
    
    
    // Delegates 
    
    /// Dynamic Info Screen
    
    func didFinishInfoScreen()
    {
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    func didPressBackOnInfoScreen()
    {
        self.goToAddTilesScreen()
    }
    
    // OAuth Delegates
    
    func oAuthViewControllerDidAuthenticate(_ oAuthViewController: OAuthViewController!)
    {
        self.processNextRecipeStep(step: self.currentStep!)
    }
    
    func oAuthViewControllerDidFailAuthentication(_ oAuthViewController: OAuthViewController!)
    {
        self.goToAddTilesScreen()
    }
    
    func oAuthViewControllerDidCancelAuthentication(_ oAuthViewController: OAuthViewController!)
    {
        self.goToAddTilesScreen()
    }
}
