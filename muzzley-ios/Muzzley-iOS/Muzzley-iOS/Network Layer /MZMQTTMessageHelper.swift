//
//  MZMQTTMessageHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 15/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import RxSwift

let MZMQTTMessageHelperError: String = "MZMQTTMessageHelperError"


class MZMQTTMessageHelper: NSObject {
	
    //static let disposeBag = DisposeBag()


	static func getPropertyValueViaMQTT(channelId: String, componentId: String, propertyId: String, data: NSDictionary?, completion: @escaping (_ response: AnyObject?, _ error : NSError?) -> Void)
	{
		var newMessage = MZMQTTMessage()
		var mqttPayload = NSMutableDictionary()
	
		var topic = MZTopicParser.createPublishTopic(channelId, componentId: componentId, propertyId: propertyId)
        var topicComponents = MZTopicParser.getTopicComponents(MZEndpoints.mqttCoreVersion(), topic: topic)
	
		newMessage.topic = topic
        
        let topicChannelId = topicComponents.channelId
        let topicComponentId = topicComponents.componentId
        let topicPropertyId = topicComponents.propertyId
		
        let subscription = MZMQTTConnection.sharedInstance.getSingleFilteredMessage(filterPredicate: { (mqttMessage) -> Bool in
            let mqttMessageComponents = MZTopicParser.getTopicComponents(MZEndpoints.mqttCoreVersion(), topic: mqttMessage.topic)
            if(mqttMessageComponents.channelId == topicChannelId
                && mqttMessageComponents.componentId == topicComponentId
                && mqttMessageComponents.propertyId == topicPropertyId)
            {
                if let io = mqttMessage.message["io"] as? String
                {
                    if(io.contains("i"))
                    {
                        if let data = mqttMessage.message["data"]
                        {
                            return true
                        }
                    }
                }
            }
            return false
        }, completion: { (mqttMessage) in
            if let data = mqttMessage.message["data"]
            {
                completion(data as! AnyObject, nil)
            }
        })
	
		mqttPayload.addEntries(from: ["io": "r"])
		if(data != nil)
		{
			mqttPayload.addEntries(from: ["data" : data!])
		}
		
		newMessage.message = mqttPayload
		
        MZMQTTConnection.sharedInstance.publish(newMessage.topic, jsonDict: newMessage.message, completion: { (success, error) in
        } )
    
	}
    
    static func sendPropertyValueViaMQTT(channelId: String, componentId: String, propertyId: String, data: NSDictionary?, completion: @escaping (_ error : NSError?) -> Void)
    {
//        var timeoutBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
//           completion(error: NSError(domain: MZMQTTMessageHelperError, code: 0, userInfo: nil))
//        }
//        let time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(60 * NSEC_PER_SEC))
//        dispatch_after(time, dispatch_get_main_queue(), timeoutBlock)

        var newMessage = MZMQTTMessage()
        var mqttPayload = NSMutableDictionary()
        
        var topic = MZTopicParser.createPublishTopic(channelId, componentId: componentId, propertyId: propertyId)
        var topicComponents = MZTopicParser.getTopicComponents(MZEndpoints.mqttCoreVersion(), topic: topic)
        
        newMessage.topic = topic
        
        let topicChannelId = topicComponents.channelId
        let topicComponentId = topicComponents.componentId
        let topicPropertyId = topicComponents.propertyId
        
        MZMQTTConnection.sharedInstance.listenToDidReceiveMessage { (mqttMessage) in
            let mqttMessageComponents = MZTopicParser.getTopicComponents(MZEndpoints.mqttCoreVersion(), topic: mqttMessage.topic)
            if(mqttMessageComponents.channelId == topicChannelId
                && mqttMessageComponents.componentId == topicComponentId
                && mqttMessageComponents.propertyId == topicPropertyId)
            {
                if let io = mqttMessage.message["io"] as? String
                {
                    if(io.contains("i"))
                    {
                        completion(nil)
                    }
                }
            }
        }
    
        mqttPayload.addEntries(from: ["io": "w"])
        if(data != nil)
        {
            mqttPayload.addEntries(from: ["data" : data!])
        }
        
        newMessage.message = mqttPayload
        MZMQTTConnection.sharedInstance.publish(newMessage.topic, jsonDict: newMessage.message, completion: { (success, error) in
        })
    }
    
    
    static func sendGrantAccessUserValueViaMQTT(deviceId: String, data: NSDictionary?, completion: @escaping (_ error : NSError?) -> Void)
    {
        var newMessage = MZMQTTMessage()
        var mqttPayload = NSMutableDictionary()
        
        var topic = MZTopicParser.createPublishDeviceGrantTopic(deviceId)
        newMessage.topic = topic
       
        mqttPayload.addEntries(from: ["io": "w"])
        if(data != nil)
        {
            mqttPayload.addEntries(from: ["data" : data!])
        }
        
        newMessage.message = mqttPayload
        MZMQTTConnection.sharedInstance.publish(newMessage.topic, jsonDict: newMessage.message, completion: { (success, error) in
            
        })
        
        var isFinished = false
        
        let deadlineTime = DispatchTime.now() + .seconds(60)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            if(!isFinished)
            {
                completion(NSError(domain: "MZTimeoutWaitingForResponse", code: 0, userInfo: nil))
            }
            return
        }
        
        MZMQTTConnection.sharedInstance.listenToDidReceiveMessage { (mqttMessage) in

            if(mqttMessage.topic == MZTopicParser.createUserGrantsSubscriptionTopic(MZSession.sharedInstance.authInfo!.userId).removeCharsAtEnd(2))
            {
                if let io = mqttMessage.message["io"] as? String
                {
                    if(io.contains("iw"))
                    {
                        isFinished = true
                        completion(nil)
                    }
                }
            }
        }
    }
    
    static func sendGrantAccessUserValueViaMQTTObservable(deviceId: String, data: NSDictionary?) -> Observable<(Any)>
    {
        return Observable.create({ (observer) -> Disposable in
            if deviceId.isEmpty
            {
                observer.onError(NSError(domain: "Invalid device ID. Cannot be empty", code: 0, userInfo: nil))
                observer.onCompleted()
            }

            self.sendGrantAccessUserValueViaMQTT(deviceId: deviceId, data: data, completion: { (error) in
                if error != nil
                {
                    observer.onError(error!)
                }
                else
                {
                    observer.onNext(error)
                }
                observer.onCompleted()
            })
        
            return Disposables.create{}
        })
    }
    
    static func sendGrantAccessApplicationValueViaMQTTObservable(deviceId: String, data: NSDictionary?) -> Observable<(Any)>
    {
        return Observable.create({ (observer) -> Disposable in
            if deviceId.isEmpty
            {
                observer.onError(NSError(domain: "Invalid device ID. Cannot be empty", code: 0, userInfo: nil))
                observer.onCompleted()
            }
            self.sendGrantAccessApplicationValueViaMQTT(deviceId: deviceId, data: data, completion: { (error) in
                if error != nil
                {
                    observer.onError(error!)
                }
                else
                {
                    observer.onNext(error)
                }
                observer.onCompleted()
            })
            
            return Disposables.create{}
        })
    }
    
    static func sendGrantAccessApplicationValueViaMQTT(deviceId: String, data: NSDictionary?, completion: @escaping (_ error : NSError?) -> Void)
    {
        var newMessage = MZMQTTMessage()
        var mqttPayload = NSMutableDictionary()
        
        var topic = MZTopicParser.createPublishDeviceGrantTopic(deviceId)

        newMessage.topic = topic
        
        mqttPayload.addEntries(from: ["io": "w"])
        if(data != nil)
        {
            mqttPayload.addEntries(from: ["data" : data!])
        }
        
        newMessage.message = mqttPayload
        MZMQTTConnection.sharedInstance.publish(newMessage.topic, jsonDict: newMessage.message, completion: { (success, error) in
        } )

        var isFinished = false
        
        let deadlineTime = DispatchTime.now() + .seconds(60)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime)
        {
            if(!isFinished)
            {
                completion(NSError(domain: "MZTimeoutWaitingForResponse", code: 0, userInfo: nil))
            }
            return
        }
        
        MZMQTTConnection.sharedInstance.listenToDidReceiveMessage { (mqttMessage) in
            if(mqttMessage.topic == MZTopicParser.createApplicationGrantsSubscriptionTopic(MZSession.sharedInstance.authInfo!.clientId).removeCharsAtEnd(2))
            {
                if let io = mqttMessage.message["io"] as? String
                {
                    if(io.contains("iw"))
                    {
                        isFinished = true
                        completion(nil)
                    }
                }
            }
        }
    }
}

