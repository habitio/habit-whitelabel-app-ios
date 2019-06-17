//
//  MZTopicParser.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

@objc class MZTopicInformation : NSObject
{
	var userId : String = ""
	var channelId : String = ""
	var componentId : String = ""
	var propertyId : String = ""
	
	init(_userId : String, _channelId: String, _componentId : String = "", _propertyId : String = "" )
	{
		self.userId = _userId
		self.channelId = _channelId
		self.componentId = _componentId
		self.propertyId = _propertyId
	}

	override init()
	{
		self.userId = ""
		self.channelId = ""
		self.componentId = ""
		self.propertyId = ""
	}
}

@objc class MZTopicParser : NSObject
{
	static func createSubscribeAllChannelsTopic(_ userId: String) -> String
	{
		var topic = ""
		if (userId.isEmpty)
		{
			return ""
		}
		
		topic += MZEndpoints.mqttCoreVersion()
		
		//topic += "/channels/#"
		
		topic += "/users/" + userId + "/channels/#"
		
		return topic
	}
	
	
	static func createSubscribeAllManagersTopic(_ userId: String) -> String
	{
		var topic = ""
		if (userId.isEmpty)
		{
			return ""
		}
		
		topic += MZEndpoints.mqttCoreVersion()
		
		topic += "/channels/#"
		
		//topic += "/users/" + userId + "/channels/#"
		
		return topic
	}
	
	static func createSubscribeChannelTopic(_ userId: String, channelId: String) -> String
	{
		var topic = ""
		if (userId.isEmpty)
		{
			return ""
		}
		
		topic += MZEndpoints.mqttCoreVersion()
		
		topic += "/users/" + userId + "/channels/" + channelId
		
		return topic
	}
	
	
    static func createUserGrantsSubscriptionTopic(_ userId: String) -> String
    {
        var topic = ""
        if (userId.isEmpty)
        {
            return ""
        }
        
        topic += MZEndpoints.mqttCoreVersion()
        
        topic += "/users/" + userId + "/grants/#"
        
        return topic
    }
    
    static func createApplicationGrantsSubscriptionTopic(_ clientId: String) -> String
    {
        var topic = ""
        if (clientId.isEmpty)
        {
            return ""
        }
        
        topic += MZEndpoints.mqttCoreVersion()
        
        topic += "/applications/" + clientId + "/grants/#"
        
        return topic
    }
    
    static func createPublishDeviceGrantTopic(_ deviceId: String) -> String
    {
        var topic = ""
        if (deviceId.isEmpty)
        {
            return ""
        }
        
        topic += MZEndpoints.mqttCoreVersion()
        
        topic += "/devices/" + deviceId + "/grants"
        
        return topic
    }
	
	static func createPublishTopic(_ channelId : String, componentId: String = "", propertyId: String = "") -> String
	{
		var topic = ""

		topic += MZEndpoints.mqttCoreVersion()
		
		topic += "/channels/" + channelId
		
		if !componentId.isEmpty
		{
			topic += "/components/" + componentId
		}
		
		if !propertyId.isEmpty
		{
			topic += "/properties/" + propertyId
		}
		
		topic += "/value"
		
		return topic
	}
	
	
	static func getTopicComponents(_ host: String, topic: String) -> MZTopicInformation
	{
		//dLog(topic)
		var topicInfo = MZTopicInformation()
		var _topic = topic
		if _topic.isEmpty
		{
			return topicInfo
		}

		if !_topic.hasPrefix(host)
		{
			return topicInfo
		}
		else
		{
			_topic = _topic.removeCharsAtBeginning(host.characters.count)
			
			if(_topic.hasSuffix("/#"))
			{
				_topic = _topic.removeCharsAtEnd(2)
			}
						
			let split = _topic.components(separatedBy: "/")
			if(split.count < 2)
			{
				return topicInfo
			}
			
			topicInfo.userId = split[2]
            if split.count >= 4 && split[3] == "channels"
            {
                topicInfo.channelId = split[4]
            } else if split.count >= 2 && split[1] == "channels"{
                topicInfo.channelId = split[2]
            }
            
            if split.count >= 6 && split[5] == "components"
            {
                topicInfo.componentId = split[6]
            } else if split.count >= 4 && split[3] == "components" {
                topicInfo.componentId = split[4]
            }
            
            if split.count >= 8 && split[7] == "properties"
            {
                topicInfo.propertyId = split[8]
            } else if split.count >= 6 && split[5] == "properties" {
                topicInfo.propertyId = split[6]
            }
		}
		
		return topicInfo
	}
}


