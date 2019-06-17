 //
//  MZLocalStorageHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 30/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZLocalStorageHelper : NSObject
{
	static let key_user_info = "user_info"
	static let key_location_channel_id = "location_channel_id"
	static let key_user_preferences = "user_preferences"
	static let key_user_places = "user_places"
	static let key_push_notifications_status = "key_push_notifications_status"
	static let key_location_permission_status = "key_location_permission_status"
    static let key_unregistered_old_notifications_status = "key_unregistered_old_notifications_status"

	static let key_auth_info = "auth_info"
	static let key_last_latitude = "lastLatitude"
	static let key_last_longitude = "lastLongitude"
	static let key_version_good_until = "goodUntil"
	
	static let key_last_location = "lastLocation"
    static let key_location_latitude = "latitude"
    static let key_location_longitude = "longitude"
    static let key_location_timestamp = "timestamp"
    static let key_location_horizontal_accuracy = "horizontal_accuracy"
    static let key_location_vertical_accuracy = "vertical_accuracy"
    static let key_location_bearing = "bearing"
    static let key_location_speed = "speed"
    
    static let key_activity_history_last_date_sent = "activity_history_last_date_sent"
    
	static func requiresCleanUpOldMZSession() -> Bool
	{
		let oldSessionKeyToRemove = "MZSession"
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: oldSessionKeyToRemove)) != nil)
		{
			userDefaults.removeObject(forKey: oldSessionKeyToRemove)
			userDefaults.synchronize()
			return true
        }
		
		return false
	}
    
    static func loadActivityHistoryLastDateSent() -> Date?
    {
        let userDefaults = UserDefaults.standard;
        
        if((userDefaults.object(forKey: key_activity_history_last_date_sent)) != nil)
        {
            return userDefaults.object(forKey: key_activity_history_last_date_sent) as! Date
        }
        
        return nil
    }
    
    static func saveActivityHistoryLastDateSent(_ date : Date)
    {
        let userDefaults = UserDefaults.standard;
        
        userDefaults.set(date, forKey: key_activity_history_last_date_sent)
        
        userDefaults.synchronize()
    }
    
    static func removeActivityHistoryLastDateSentFromNSUserDefaults()
    {
        let userDefaults = UserDefaults.standard;
        
        userDefaults.removeObject(forKey: key_activity_history_last_date_sent)
        
        userDefaults.synchronize()
    }
    
    
	static func loadAuthInfoFromNSUserDefaults() -> MZUserAuthInfo?
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_auth_info)) != nil)
		{
			var authInfoDict = userDefaults.object(forKey: key_auth_info) as? NSDictionary
			if(authInfoDict == nil)
			{
				return nil
			}
			
			let authInfo = MZUserAuthInfo(dictionary: authInfoDict!)
			if( authInfo.userId.isEmpty ||
				authInfo.accessToken.isEmpty ||
				authInfo.clientId.isEmpty ||
				authInfo.httpUrl.isEmpty ||
				authInfo.mqttUrl.isEmpty)
			{
				// Should clean up
				return nil
			}
            
			return authInfo
		}
		
		return nil
	}
	

	static func saveLocationChannelIdToNSUserDefaults(_ channelId : String)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(channelId, forKey: key_location_channel_id)
		
		userDefaults.synchronize()
	}
	
	static func saveAuthInfoToNSUserDefaults(_ authInfo : NSDictionary)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(authInfo, forKey: key_auth_info)
		
		userDefaults.synchronize()
	}

	static func loadLocationChannelIdFromNSUserDefaults() -> String
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_location_channel_id)) != nil)
		{
			return userDefaults.object(forKey: key_location_channel_id) as! String
		}
		
		return ""
	}
	
	static func removeLocationChannelIdFromNSUserDefaults()
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.removeObject(forKey: key_location_channel_id)
		
		userDefaults.synchronize()
	}
	
	
	static func loadVersionGoodUntilFromNSUserDefaults() -> String?
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_version_good_until)) != nil)
		{
			return userDefaults.object(forKey: key_version_good_until) as? String
		}
		
		return nil
	}
	
	
	static func saveVersionGoodUntilToNSUserDefaults(_ goodUntil : String)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(goodUntil, forKey: key_version_good_until)
		
		userDefaults.synchronize()
	}
	
	
	static func saveUserInfoToNSUserDefaults(_ userInfo : NSDictionary)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(userInfo, forKey: key_user_info)
		
		userDefaults.synchronize()
	}
	
	static func loadUserInfoFromNSUserDefaults() -> MZUserPreferences
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_user_info)) != nil)
		{
			return MZUserPreferences(dictionary: userDefaults.object(forKey: key_user_info) as! NSDictionary)
		}
		
		return MZUserPreferences()
	}
	
	static func saveUserPreferencesToNSUserDefaults(_ preferences : NSDictionary)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(preferences, forKey: key_user_preferences)
		
		userDefaults.synchronize()
	}
	
	static func loadUserPreferencesFromNSUserDefaults() -> MZUserPreferences
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_user_preferences)) != nil)
		{
			
			return MZUserPreferences(dictionary: userDefaults.object(forKey: key_user_preferences) as! NSDictionary)
			
		}
		
		return MZUserPreferences()
	}
	
	static func saveUserPlacesToNSUserDefaults(_ places : [NSDictionary])
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(places, forKey: key_user_places)
		
		userDefaults.synchronize()
	}
	
	static func loadUserPlacesFromNSUserDefaults() -> [MZPlace]
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_user_places)) != nil)
		{
			let json : [NSDictionary] = userDefaults.object(forKey: key_user_places) as! [NSDictionary]
			var places = [MZPlace]()
			for pl in json
			{
				places.append(MZPlace(json: pl as! [String : AnyObject]))
			}
			
			return places
		}
		
		return [MZPlace]()
	}
	
	static func loadPushNotificationsStatusFromNSUserDefaults() -> Bool
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_push_notifications_status)) != nil)
		{
			return userDefaults.object(forKey: key_push_notifications_status) as! Bool
		}
		
		return true
	}
	
	static func savePushNotificationsStatusToNSUserDefaults(_ pushNotificationsEnabled : Bool)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(pushNotificationsEnabled, forKey: key_push_notifications_status)
		
		userDefaults.synchronize()
	}
	
	static func loadLocationPermissionsStatusFromNSUserDefaults() -> Bool
	{
		let userDefaults = UserDefaults.standard;
		
		if((userDefaults.object(forKey: key_location_permission_status)) != nil)
		{
			return userDefaults.object(forKey: key_location_permission_status) as! Bool
		}
		
		return true
	}
	
	static func saveLocationPermissionsStatusToNSUserDefaults(_ locationPermissionsEnabled : Bool)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(locationPermissionsEnabled, forKey: key_location_permission_status)
		
		userDefaults.synchronize()
	}
	
    static func saveLastLocation(_ mutableData : NSMutableDictionary)
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.set(mutableData, forKey: key_last_location)
        
		userDefaults.synchronize()
	}
    
    static func saveAreOldNotificationsUnregistered(_ isUnregistered: Bool)
    {
        let userDefaults = UserDefaults.standard;
        
        userDefaults.set(isUnregistered, forKey: key_unregistered_old_notifications_status)
        
        userDefaults.synchronize()
    }
    
    static func loadAreOldNotificationsUnregistered() -> Bool
    {
        let userDefaults = UserDefaults.standard;
        
        if((userDefaults.object(forKey: key_unregistered_old_notifications_status)) != nil)
        {
            return userDefaults.object(forKey: key_unregistered_old_notifications_status) as! Bool
        }
        
        return false
    }
	
	static func clearCache()
	{
		let userDefaults = UserDefaults.standard;
		
		userDefaults.removeObject(forKey: key_auth_info)
		userDefaults.removeObject(forKey: key_user_info)
		userDefaults.removeObject(forKey: key_user_places)
		userDefaults.removeObject(forKey: key_user_preferences)
		userDefaults.removeObject(forKey: key_push_notifications_status)
        userDefaults.removeObject(forKey: key_last_latitude)
        userDefaults.removeObject(forKey: key_last_longitude)
        userDefaults.removeObject(forKey: key_location_permission_status)
        userDefaults.removeObject(forKey: key_unregistered_old_notifications_status)
        userDefaults.removeObject(forKey: key_location_channel_id)
        userDefaults.removeObject(forKey: key_activity_history_last_date_sent)
        
		userDefaults.synchronize()
	}
}
