//
//  MZSession.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 15/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import NeuraSDK

class MZSession: NSObject
{
	
	// To clean up
	let kMZSessionKey =                       "MZSession"
	let kMZSessionKeyType =                   "sessionType"
	let kMZSessionKeyUserProfile =            "MZUser"
	let kMZSessionKeyUserProfileName =        "name"
	let kMZSessionKeyUserProfileId =          "id"
	let kMZSessionKeyUserProfileEmail =       "email"
	let kMZSessionKeyUserProfilePicture =     "pictureURLString"
	let kMZSessionKeyUserProfileAccessToken = "accessToken"
	let kMZSessionKeyUserProfileAuthToken =   "authToken"
	let kMZSessionKeyUserProfileClientId =    "clientId"
	let kMZSessionKeyUserDeviceId =           "deviceId"
	
	
	
	let key_auth_info = "MZAuthInfo"

	
	//var state: MZSessionState
	var authInfo : MZUserAuthInfo?
	
	
	class var sharedInstance : MZSession {
		struct Singleton {
			static let instance = MZSession()
		}
		return Singleton.instance
	}

	
	func loadFromCache(completion: @escaping (_ success: Bool) -> Void)
	{
		if(MZLocalStorageHelper.requiresCleanUpOldMZSession())
		{
			// Logout
			MZLocalStorageHelper.clearCache()
			completion(false)
            return
		}
			
		self.authInfo = MZLocalStorageHelper.loadAuthInfoFromNSUserDefaults()
		if(authInfo != nil)
		{
			// //Testing purposes
//			var yesterday = Date()
//			yesterday.addTimeInterval(-24*60*60)
//			var dateFormatter = DateFormatter()
//			dateFormatter.calendar = Calendar.current
//			dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
//			let yesterdayString = dateFormatter.string(from: yesterday)
			if(MZSessionValidationHelper.needsToRefreshToken(expiresDateStr: authInfo!.expiresDate))
			{
				MZSessionValidationHelper.refreshToken(completion: { (success) in
					if(!success)
					{
						completion(false)
						return
					}
					else
					{
						self.connectToMQTTCore()
						completion(true)
						return
					}
				})
			}
			else
			{
				self.connectToMQTTCore()
				completion(true)
				return
			}
		}
		
		completion(false)
        return
	}
	
		
	func saveToCache()
	{
		MZLocalStorageHelper.saveAuthInfoToNSUserDefaults(authInfo!.dictionaryRepresentation)
	}

	func closeAndClear()
	{
		MZLocalStorageHelper.clearCache()
		self.authInfo = nil
		
		MZOnboardingsInteractor.sharedInstance.resetAllOnboardings()
	}
	
	func signIn(username: String, password: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> Void)
	{
		let clientId = MZThemeManager.sharedInstance.appInfo.appId

		MZOAuthWebService.sharedInstance.signIn(clientId: clientId, username: username, password: password) { (responseObject, error) in
			if(error != nil)
			{
				completion(false, error!)
				return
			}
			
			if(responseObject != nil && responseObject is NSDictionary)
			{
				self.authInfo = MZUserAuthInfo(dictionary: responseObject as! NSDictionary)
				self.saveToCache()
				self.connectToMQTTCore()
				completion(true, nil)
			}
			else
			{
                
				completion(false, nil)
			}
		}
	}
	
	func signUp(parameters: NSDictionary, completion: @escaping (_ success: Bool, _ error: NSError?) -> Void)
	{
		
        MZLocalStorageHelper.clearCache()
        
		let appId = MZThemeManager.sharedInstance.appInfo.namespace

		var mutableParams = NSMutableDictionary()
		
		if(appId != nil)
		{
			mutableParams = NSMutableDictionary(dictionary: parameters)
			mutableParams["appId"] = appId
		}
		
		MZOAuthWebService.sharedInstance.signUp(parameters: mutableParams as! NSDictionary) { (responseObject, error) in
			
			if(error != nil)
			{
				completion(false, error)
			}
			else
			{
				completion(true, nil)
			}
		}
	}
	
	func connectToMQTTCore()
	{
		MZMQTTConnection.sharedInstance.userId = MZSession.sharedInstance.authInfo!.userId
		
		var useSSL = true
		
		let mqttUrl = URL(string: MZSession.sharedInstance.authInfo!.mqttUrl)
		
		if(mqttUrl?.scheme == nil)
		{
			MZSession.sharedInstance.closeAndClear()
			return
		}
		
		switch mqttUrl!.scheme!.lowercased()
		{
            
		case "mqtts":
			useSSL = true
			break
            
		case "mqtt":
			useSSL = false
			break
			
		default:
			// Show Error and signout!!!
			MZSession.sharedInstance.closeAndClear()
			return
		}
		
		if(mqttUrl?.port == nil)
		{
			MZSession.sharedInstance.closeAndClear()
			return
		}
		
		let mqttPort : UInt16 = UInt16(mqttUrl!.port!)
        
		if(mqttUrl?.host == nil || mqttUrl!.host == nil || mqttUrl!.host!.isEmpty)
		{
			MZSession.sharedInstance.closeAndClear()
			return
		}
		
		let mqttHost = mqttUrl!.host!
		
		MZMQTTConnection.sharedInstance.connect(
			MZSession.sharedInstance.authInfo!.clientId,
			password: MZSession.sharedInstance.authInfo!.accessToken,
			host: mqttHost,
			port: mqttPort,
			useSSL: useSSL,
			completion: nil)
	}
    

	
	func signOut()
	{
        if self.authInfo != nil
        {
            MZActivityInteractor.shared.stopTracking()
            
            if(MZThemeManager.sharedInstance.neura != nil)
            {
                if NeuraSDK.shared.isAuthenticated()
                {
                    NeuraSDK.shared.logout { result in
                        // Handle errors if required
                        print(result)
                    }
                }
            }
        }
        
        UserDefaults.standard.removeObject(forKey: MZAppStatsHelper.key_user_defaults_app_stats)
        UserDefaults.standard.synchronize()
        
		MZMQTTConnection.sharedInstance.disconnect()
		MZLocalStorageHelper.clearCache()
		MZOnboardingsInteractor.sharedInstance.resetAllOnboardings()
		MZEmitLocationInteractor.sharedInstance.setGeofences(nil)
        self.authInfo = nil
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cleanUpAndGoToStart"), object: nil)
	}
}
