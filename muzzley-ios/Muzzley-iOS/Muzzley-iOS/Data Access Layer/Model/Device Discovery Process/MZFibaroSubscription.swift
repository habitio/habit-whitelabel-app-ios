//
//  File.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 12/10/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZFibaroSubscriptionConverter : NSObject
{
    static let key_device_id = "device_id"
    static let key_sensor = "sensor"
    
    static let key_id = "id"
    static let key_name = "name"
    static let key_type = "type"
    
    var device_id : String = ""     // Hub ID
    var id : String = ""            // Actual sensor ID
    var name : String = ""
    var type : String = ""
    
//    static func convertToChannelSubscriptions(array : [NSDictionary], photoUrl : String) -> [MZChannelSubscription]
//    {
//        var channelSubscriptions = [MZChannelSubscription]()
//        
//        for sub in array
//        {
//            var channelSub = MZChannelSubscription()
//            
//            if let sensorDict = sub.value(forKey: self.key_sensor) as? NSDictionary
//            {
//                if let type = (sensorDict as! NSDictionary).value(forKey: key_type) as? String
//                {
//                    if !type.hasPrefix("com.fibaro")
//                    {
//                        //  Ignore and move to next
//                        continue
//                    }
//                }
//                if let _id = (sensorDict as! NSDictionary).value(forKey: key_id)
//                {
//                    channelSub.channelID = _id as! String
//                }
//                
//                if let _name = (sensorDict as! NSDictionary).value(forKey: key_name)
//                {
//                    channelSub.content = _name as! String
//                }
//                
//            }
//            
//            if let dev_id = sub.value(forKey: self.key_device_id)
//            {
//                channelSub.deviceID = dev_id as! String
//            }
//            
//            channelSub.photoUrl = photoUrl
//            
//            channelSubscriptions.append(channelSub)
//        }
//        
//        return channelSubscriptions
//    }
    
    static func convertToChannelSubscriptionsFormat(array : [NSDictionary], photoUrl : String) -> [NSDictionary]?
    {
        var channelSubscriptions = [NSMutableDictionary]()
        for sub in array
        {
            var channelSub = NSMutableDictionary()
            
            if let sensorDict = sub.value(forKey: self.key_sensor) as? NSDictionary
            {
                if let type : String? = (sensorDict as! NSDictionary).value(forKey: key_type) as? String
                {
                    
                    if !type!.hasPrefix("com.fibaro")
                    {
                        //  Ignore and move to next
                        continue
                    }
                }
                if let _id : String? = (sensorDict as! NSDictionary).value(forKey: key_id) as? String
                {
                    if _id == nil || _id!.isEmpty
                    {
                        return nil
                    }
                    
                    channelSub["id"] = _id as! String
                }
                
                if let _name : String? = (sensorDict as! NSDictionary).value(forKey: key_name) as? String
                {
                    if _name == nil || _name!.isEmpty
                    {
                        return nil
                    }
                    
                    channelSub["content"] = _name as! String
                }
                
            }
            
            if let dev_id : String? = sub.value(forKey: self.key_device_id) as? String
            {
                if dev_id == nil || dev_id!.isEmpty
                {
                    return nil
                }
                channelSub["device_id"] = dev_id as! String
            }
            
            channelSub["photoUrl"] = photoUrl
            
            channelSubscriptions.append(channelSub)
        }
        
        return channelSubscriptions
    }
}



