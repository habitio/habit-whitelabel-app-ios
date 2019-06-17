//
//  MZMQTTWebviewMessageHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit


@objc class MZMQTTWebviewMessageHelper: NSObject
{

	static var ch_id = 0
	// Topic: CID
	static var subscriptions = [String]()
	

	static func sendMQTTPublish(_ message: NSDictionary, completion: @escaping (_ success: Bool, _ topic: String, _ error : NSError?) -> Void)
	{
		var mqttMessage = MZMQTTMessage()
		var mqttPayload = NSMutableDictionary()
		var topicInfo : MZTopicInformation?

//		dLog(message: "Received publish from webview: ")
		if let d = message["d"] as? NSDictionary
		{

			topicInfo = getTopicInfoFromNSDictionary(d)
			if topicInfo == nil
			{
				return
			}
			
			mqttMessage.topic = MZTopicParser.createPublishTopic(topicInfo!.channelId, componentId: topicInfo!.componentId, propertyId: topicInfo!.propertyId)
			
			// Remove channel, component and property from message
			var destructMessage = NSMutableDictionary(dictionary: (message["d"] as? NSDictionary)!)
			if(destructMessage.object(forKey: "channel") != nil)
			{
				destructMessage.removeObject(forKey: "channel")
			}
			
			if(destructMessage.object(forKey: "component") != nil)
			{
				destructMessage.removeObject(forKey: "component")
			}
			
			if(destructMessage.object(forKey: "property") != nil)
			{
				destructMessage.removeObject(forKey: "property")
			}
			
			mqttMessage.message = destructMessage
			
			MZMQTTConnection.sharedInstance.publish(mqttMessage.topic, jsonDict: mqttMessage.message, completion: { (success, error) in
				completion(success, mqttMessage.topic, error)
			})
		}
	}

	static func sendMQTTSubscribe(_ message: NSDictionary, completion: (_ success: Bool, _ subscribedChannel: String, _ error : NSError?) -> Void)
	{
		var mqttMessage = MZMQTTMessage()
		var mqttPayload = NSMutableDictionary()
		var topicInfo : MZTopicInformation?
		
//		dLog(message: "Received subscribe from webview: ")
		if let d = message["d"] as? NSDictionary
		{
		if let channel = d["channel"] as? String
		{
			if(!subscriptions.contains(channel))
			{
				subscriptions.append(channel)
			}
			completion(true, channel, nil)
			
			}
		}
		
	}
	
	static func createMessageWithHeader(_ message: MZMQTTMessage) -> MZMQTTMessage
	{
		let split = message.topic.components(separatedBy: "/")
		
		var channel = ""
		
		for (index, element) in split.enumerated()
		{
			if element == "channels"
			{
				channel = split[index+1]
				break
			}
		}
		
		
		let mutableData : NSMutableDictionary
		let components = MZTopicParser.getTopicComponents(MZEndpoints.mqttCoreVersion(), topic: message.topic)
	
		mutableData = NSMutableDictionary(dictionary: message.message)
		mutableData.addEntries(from: ["channel" : components.channelId])
		mutableData.addEntries(from: ["component" : components.componentId])
		mutableData.addEntries(from: ["property" : components.propertyId])
		
		let mutableDict = NSMutableDictionary()
		
		mutableDict.addEntries(from: ["a": "publish"])
		
		mutableDict.addEntries(from: ["h":["ch" : channel]])
		
		mutableDict.addEntries(from: ["d": mutableData])
		
		return MZMQTTMessage(topic: message.topic, message: mutableDict)
	}
	
	static func unsubscribeAll()
	{
		self.subscriptions.removeAll()
	}
	
	
	static func getTopicInfoFromNSDictionary(_ dictionary : NSDictionary) -> MZTopicInformation?
	{
		var topicInfo = MZTopicInformation()
		
		if let channelId = dictionary["channel"] as? String
		{
			topicInfo.channelId = channelId
		}
		else
		{
			return nil
		}
		
		if let componentId = dictionary["component"] as? String
		{
			topicInfo.componentId = componentId
		}
		else
		{
			topicInfo.componentId = ""
		}
		
		if let propertyId = dictionary["property"] as? String
		{
			topicInfo.propertyId = propertyId
		}
		else
		{
			topicInfo.propertyId = ""
		}
		
		
		if(topicInfo.channelId.isEmpty)
		{
			return nil
		}
		
		if(!topicInfo.componentId.isEmpty && topicInfo.propertyId.isEmpty) // Not a valid topic to be processed.
		{
			return nil
		}
		
		if(topicInfo.componentId.isEmpty && !topicInfo.propertyId.isEmpty) // Not a valid topic to be processed.
		{
			return nil
		}
		
		
		return topicInfo
	}
	

	
	static func isMessageValid(_ message : MZMQTTMessage) -> String
	{
//        dLog ("isMessageValid message \(message.message)")
        
		// Check if there is a subscription to the topic
		var isSubscribed = false
		var subscribedTopic = ""
		
		for sub in subscriptions
		{
			if(message.topic.contains(sub))
			{
				isSubscribed = true
				subscribedTopic = sub
				break
			}
		}
		
		if(!isSubscribed)
		{
			return ""
		}
		
		// Check if its "i" or o
		if let io = message.message["io"] as?  String
		{
			if !io.hasPrefix("i")
			{
//                dLog ("Response ignored - not i or ir")
				return ""
			}
		}
	
		return subscribedTopic
	}
	
}
