//
//  MZAddServicesInteractor
//  Muzzley-iOS
//
//  Created by Ana Figueira on 07/11/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift


let MZAddServicesErrorDomain = "MZAddServicesErrorDomain";


@objc protocol MZAddServicesInteractorDelegate: NSObjectProtocol
{
    @objc optional func channelsFilteredByProfileSuccess(_ channels: [MZChannel])
    @objc optional func channelsFilteredByProfileUnsuccess(_ profileId: String)
    
    @objc optional func channelsSubscriptionsSuccess(_ profile: MZChannelTemplate, channelsSubscriptions: [MZChannelSubscription])
    @objc optional func channelsSubscriptionsUnsuccess(_ profileId: String)
    
    @objc optional func localDiscoverySuccess(_ profileId: String, data: NSDictionary)
    @objc optional func localDiscoveryNumberOfStepsUpdate(_ profileId: String, numberOfSteps: Int)
    @objc optional func localDiscoveryStepUpdate(_ profileId: String, stepNumber: Int, stepDescription: String)
    
    @objc optional func localDiscoveryUnsuccess(_ profileId: String)
    
    @objc optional func getBundlesSuccess(_ bundles: [MZService])
    @objc optional func getBundlesUnsuccess()
    
    @objc optional func getServicesSuccess(_ services: [MZService])
    @objc optional func getServicesUnsuccess()
    
}

@objc class MZAddServicesInteractor : NSObject, MZDiscoveryRecipeInteractorOutput, MZAddDevicesInteractorDelegate
{
    func requestActivationAction(_ action: MZDiscoveryProcessAction!, callback: (([Any]?) -> Void)!) {
    
    }
    
    var delegate : MZAddServicesInteractorDelegate?
    var discoveryInteractor : MZDiscoveryRecipeInteractor?
    var currentProfileLocalDiscovery: MZChannelTemplate?
    var deviceInteractor : MZDeviceInteractor?
    var addDevicesInteractor : MZAddDevicesInteractor?
    
    let disposeBag = DisposeBag()
    
    static let key_bundles = "bundles"
    static let key_services = "services"
    
    override init()
    {
        super.init()
        self.deviceInteractor = MZDeviceInteractor()
        self.addDevicesInteractor = MZAddDevicesInteractor()
        self.addDevicesInteractor?.delegate = self
    }
    
    func getServices()
    {
        let servicesObservable = MZServicesDataManager.sharedInstance.getObservableOfAllServices()
        _ = servicesObservable.subscribe(
            onNext:{(bundlesAndServicesDic) -> Void in
                
                if let bundlesJSON = bundlesAndServicesDic[MZAddServicesInteractor.key_bundles] as? NSArray
                {
                    var bundles = [MZService]()
                    
                    for b in bundlesJSON
                    {
                        let newBundle = MZService(dictionary: b as! NSDictionary)
                        bundles.append(newBundle)
                    }
                    
                    self.delegate?.getBundlesSuccess!(bundles)
                }
                else
                {
                    self.delegate?.getBundlesUnsuccess!()
                }
                
                
                if let servicesJSON = bundlesAndServicesDic[MZAddServicesInteractor.key_services] as? NSArray
                {
                    var services = [MZService]()
                    
                    for s in servicesJSON
                    {
                        let newService = MZService(dictionary: s as! NSDictionary)
                        services.append(newService)
                    }
                    
                    
                    self.delegate?.getServicesSuccess!(services)
                    
                }
                else
                {
                    self.delegate?.getServicesUnsuccess!()
                }
                
                
        }, onError: { error in
            self.delegate?.getBundlesUnsuccess!()
            self.delegate?.getServicesUnsuccess!()
        })
    }
    
    
    func getChannelsSubscriptions(profile: MZChannelTemplate, data: NSDictionary?)
    {
        
            let channelsSubscriptionsObservable = MZServicesDataManager.sharedInstance.getObservableOfChannelsSubscriptionsByProfile(profile.identifier)
            _ = channelsSubscriptionsObservable.subscribe(
                onNext:{(results) -> Void in
                    
                    if let res = results as? [MZChannelSubscription]
                    {
                        self.delegate?.channelsSubscriptionsSuccess!(profile, channelsSubscriptions: res)
                    }
                    else
                    {
                        self.delegate?.channelsSubscriptionsUnsuccess!(profile.identifier)
                    }
            }, onError: { error in
                self.delegate?.channelsSubscriptionsUnsuccess!(profile.identifier)
            })
        
    }
    
    func addChannelsToUser(groupedChannels: [MZChannelTemplate : [MZChannelSubscription]], completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        var tasks : [Observable<AnyObject>] = []
        
        for group in groupedChannels
        {
            var channelIds = [NSDictionary]()
            
            for sub in group.1
            {
                channelIds.append(NSDictionary(object: sub.channelID, forKey: "id" as NSCopying))
            }
            
            tasks.append(MZChannelsWebService.sharedInstance.addChannelsObservable(profileId: group.0.identifier, channels: channelIds as [NSDictionary]))
        }
        
        let singleObservable: Observable<AnyObject> = Observable.from(tasks).concat()
        
        singleObservable.subscribe(onNext:
            { result in
                completion(result, nil)
        }
            , onError: { error in
                completion(nil, NSError(domain: MZAddServicesErrorDomain, code: 0, userInfo: nil))
        }, onCompleted: {}).addDisposableTo(self.disposeBag)
    }
    
    
    func foundDiscoveryProcessInfo(_ discoveryProcess: MZDiscoveryProcess!)
    {
        self.discoveryInteractor?.startCustomAuthentication()
    }
    
    func foundDiscoveryProcessStepInfo(_ discoveryProcessStep: MZDiscoveryProcessStep!)
    {
        if(self.delegate?.localDiscoveryStepUpdate != nil)
        {
            self.delegate?.localDiscoveryStepUpdate!((self.currentProfileLocalDiscovery?.identifier)!, stepNumber: discoveryProcessStep.step as Int, stepDescription: discoveryProcessStep.title)
        }
    }
    
    func authenticationFailedWithError(_ error: Error!) {
        self.delegate?.localDiscoveryUnsuccess!(self.currentProfileLocalDiscovery!.identifier)
    }
    
    
    func authenticationDidEnded(withSuccessAndData data: [AnyHashable : Any]!) {
        if(self.delegate != nil && self.delegate?.localDiscoverySuccess != nil)
        {
            self.delegate?.localDiscoverySuccess!(self.currentProfileLocalDiscovery!.identifier, data: data as! NSDictionary)
            self.addDevicesInteractor?.getChannelsSubscriptions(self.currentProfileLocalDiscovery!, data: data as! NSDictionary)
        }
    }
    
    func authenticationDidEndedWithSuccess()
    {
        self.addDevicesInteractor?.getChannelsSubscriptions(self.currentProfileLocalDiscovery!, data: nil)
    }

}
