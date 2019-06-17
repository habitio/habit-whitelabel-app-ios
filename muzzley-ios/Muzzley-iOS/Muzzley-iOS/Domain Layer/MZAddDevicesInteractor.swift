//
//  MZAddDevicesInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/08/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
import RxSwift

@objc protocol MZAddDevicesInteractorDelegate: NSObjectProtocol
{
	@objc optional func channelsSubscriptionsSuccess(_ profile: MZChannelTemplate, channelsSubscriptions: [MZChannelSubscription])
	@objc optional func channelsSubscriptionsUnsuccess(_ channelTemplateId: String)
	
	@objc optional func localDiscoverySuccess(_ channelTemplateId: String, data: NSDictionary)
	@objc optional func localDiscoveryNumberOfStepsUpdate(_ channelTemplateId: String, numberOfSteps: Int)
	@objc optional func localDiscoveryStepUpdate(_ channelTemplateId: String, stepNumber: Int, stepDescription: String)
	@objc optional func localDiscoveryUnsuccess(_ channelTemplateId: String)
    
    @objc optional func UDPDiscoverySuccess(_ channelTemplateId: String, data: NSArray)
    @objc optional func UDPDiscoveryUnsuccess(_ channelTemplateId: String)
    
    @objc optional func createChannelsUnsuccess(_ error : NSError)
    @objc optional func createChannelsSuccess(_ results : [[NSDictionary]])
}

@objc class MZAddDevicesInteractor : NSObject, MZDiscoveryRecipeInteractorOutput
{
    func requestActivationAction(_ action: MZDiscoveryProcessAction!, callback: (([Any]?) -> Void)!) {
        
    }
    
	var delegate : MZAddDevicesInteractorDelegate?
	var discoveryInteractor : MZDiscoveryRecipeInteractor?
	var currentProfileLocalDiscovery: MZChannelTemplate?
	var deviceInteractor : MZDeviceInteractor?
    
	func getChannelsSubscriptions(_ profile: MZChannelTemplate, data: NSDictionary?)
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
    
    func requestGrantAppAccess(group : MZProfileDevicesViewModel) -> Observable<AnyObject>
    {
        return Observable.create({(observer) -> Disposable in
            MZMQTTConnection.sharedInstance.subscribe( MZTopicParser.createApplicationGrantsSubscriptionTopic(MZSession.sharedInstance.authInfo!.clientId)) { (success,topic , error) in
                
                if(success)
                {
                    if(topic == MZTopicParser.createApplicationGrantsSubscriptionTopic(MZSession.sharedInstance.authInfo!.clientId))
                    {
                        var tasks : [Observable<Any>] = []
                        
                        for device in group.devices
                        {
                            if(device.isSelected)
                            {
                                var applicationGrantDictionary : NSMutableDictionary = NSMutableDictionary()
                                applicationGrantDictionary.addEntries(from: ["client_id" : MZSession.sharedInstance.authInfo?.clientId,
                                                                             "role" : "application",
                                                                             "content" : device.channelSubscription!.content,
                                                                             "id": device.channelSubscription!.channelID])
                                
                                tasks.append(MZMQTTMessageHelper.sendGrantAccessApplicationValueViaMQTTObservable(deviceId: device.channelSubscription!.deviceID, data: applicationGrantDictionary))
                            }
                        }
                        
                        Observable<Any>.zip(tasks) { return $0 }
                            .subscribe(onNext: { (results) in
                                observer.onNext(results as AnyObject)
                                observer.onCompleted()
                                return
                            }, onError: { (error) in
                                dLog("ERROR:" + error.localizedDescription)
                                observer.onError(error)
                            }, onCompleted: {
                            }, onDisposed: {}
                        )
                    }
                }
            }
            return Disposables.create{}
        })
    }
    
    func requestGrantUserAccess(group : MZProfileDevicesViewModel) -> Observable<AnyObject>
    {
         return Observable.create({(observer) -> Disposable in MZMQTTConnection.sharedInstance.subscribe( MZTopicParser.createUserGrantsSubscriptionTopic(MZSession.sharedInstance.authInfo!.userId)) { (success, topic, error) in
                
                if(success)
                {
                    if(topic == MZTopicParser.createUserGrantsSubscriptionTopic(MZSession.sharedInstance.authInfo!.userId))
                    {
                        var tasks : [Observable<Any>] = []
                        
                        for device in group.devices
                        {
                            if(device.isSelected)
                            {
                                var userGrantDictionary : NSMutableDictionary = NSMutableDictionary()
                                userGrantDictionary.addEntries(from: ["client_id" : MZSession.sharedInstance.authInfo?.userId,
                                                                      "requesting_client_id" : MZSession.sharedInstance.authInfo?.clientId,
                                                                      "role" : "user",
                                                                      "content" : device.channelSubscription!.content,
                                                                      "id": device.channelSubscription!.channelID])
                                
                                tasks.append(MZMQTTMessageHelper.sendGrantAccessUserValueViaMQTTObservable(deviceId: device.channelSubscription!.deviceID, data: userGrantDictionary))
                            }
                        }
                        
                        Observable<Any>.zip(tasks) { return $0}
                            .subscribe(onNext: { (results) in
                                observer.onNext(results as AnyObject)
                                observer.onCompleted()
                                return
                            }, onError: { (error) in
                                dLog("ERROR:" + error.localizedDescription)
                                observer.onError(error)
                            }, onCompleted: {
                            }, onDisposed: {}
                        )
                    }
                }
            }
            return Disposables.create{}
         })
    }
    
    func createChannelsWithPost(group : MZProfileDevicesViewModel) -> Observable<AnyObject>
    {
        return Observable.create({(observer) -> Disposable in
            
            var manufacturersIds = [NSDictionary]()
            
            for sub in group.devices
            {
                if(sub.isSelected)
                {
                    manufacturersIds.append(NSDictionary(object: sub.channelSubscription?.channelID, forKey: "id" as NSCopying))
                }
            }
            
            MZChannelsWebService.sharedInstance.postChannelIds(channelsArray: manufacturersIds, profileId: group.profile.identifier, completion: { (result, error) in
                if(error == nil)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                        observer.onNext(result as! [NSDictionary] as AnyObject)
                        observer.onCompleted()
                    })
                }
                else
                {
                    observer.onError(error!)
                }
            })
            return Disposables.create{}
        })
    }
    
    func findDevicesUDP(channelTemplateId: String, udpActionInfo: MZRecipeActionUDP)
    {

        let udpClient = MZUDPClient()
        udpClient.onCompletion = { responses, error in
            if error != nil
            {
                if(self.delegate != nil)
                {
                    self.delegate!.UDPDiscoveryUnsuccess!(udpActionInfo.channelTemplateId!)
                    return
                }
            }
            
            var resultsArray = NSMutableArray()

            switch udpActionInfo.responseType {
            case "json":
                
                for res in responses as! NSArray
                {
                    do
                    {
                        let string = String(data: Data(res as! Data), encoding: String.Encoding.ascii)
                        print(string)
            
                        let obj : [String: Any]? = MZJsonHelper.convertStringToDictionary(text: string!)
                        resultsArray.add(obj)
                    }
                    catch let error as NSError
                    {
                        print(error)
                    }
                }
                
                if udpActionInfo.expectResponse! && resultsArray.count == 0
                {
                    if self.delegate != nil
                    {
                        self.delegate!.UDPDiscoveryUnsuccess!(channelTemplateId)
                        return
                    }
                }
                
                if self.delegate != nil
                {
                    self.delegate!.UDPDiscoverySuccess!(channelTemplateId, data: resultsArray)
                    return
                }
                break
            default:
                if self.delegate != nil
                {
                    self.delegate!.UDPDiscoveryUnsuccess!(channelTemplateId)
                    return
                }
                break
            }
          
        }
        
        var requestStr = ""
        var port : UInt = 0 // unassigned
        var ttl : TimeInterval = 3000 // Fibaro Default
        var expectResponse = true // Default
        
   
        if udpActionInfo.data != nil &&
            udpActionInfo.port != nil &&
            udpActionInfo.ttl != nil &&
            udpActionInfo.expectResponse != nil
        {
            requestStr = udpActionInfo.data!
            port = udpActionInfo.port!
            ttl = TimeInterval(udpActionInfo.ttl!)
            expectResponse = udpActionInfo.expectResponse!
            
            udpClient.sendData(requestStr.data(using: String.Encoding.utf8), toHost: "255.255.255.255", port: port, withTimeout: ttl, expectResponse: expectResponse)
        }
        else
        {
            self.delegate?.UDPDiscoveryUnsuccess!(channelTemplateId)
            return
        }
    }
    
    
	func findDevices(_ profile: MZChannelTemplate, url: URL)
	{
		var authUrl = url
		
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
		
		self.discoveryInteractor = MZDiscoveryRecipeInteractor(url: authUrl)
		self.discoveryInteractor?.output = self
		self.discoveryInteractor!.requestDiscoveryProcessInfo()
	}
	

	func foundDiscoveryProcessInfo(_ discoveryProcess: MZDiscoveryProcess)
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
        if(self.delegate != nil)
        {
            self.delegate?.localDiscoveryUnsuccess!(self.currentProfileLocalDiscovery!.identifier)
        }
    }
	
	func authenticationDidEnded(withSuccessAndData data: [AnyHashable : Any]!) {
		if(self.delegate != nil && self.delegate?.localDiscoverySuccess != nil)
		{
			self.delegate?.localDiscoverySuccess!(self.currentProfileLocalDiscovery!.identifier, data: data as! NSDictionary)
			self.getChannelsSubscriptions(self.currentProfileLocalDiscovery!, data: data as! NSDictionary)
		}
	}
	
	func authenticationDidEndedWithSuccess()
	{
		self.getChannelsSubscriptions(self.currentProfileLocalDiscovery!, data: nil)
	}
}
