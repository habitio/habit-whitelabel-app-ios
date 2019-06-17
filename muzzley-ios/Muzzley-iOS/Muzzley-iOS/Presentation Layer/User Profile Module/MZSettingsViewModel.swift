//
//  MZSettingsViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 05/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZSettingsViewModel
{
	var isMetric : Bool = false
	var isImperial : Bool = false
	
	var is24hFormat : Bool = false
	
	var places : [MZPlaceViewModel] = [MZPlaceViewModel]()
	
	var pushNotifications : Bool = false
	var emailNotifications : Bool = false
	var smsNotifications : Bool = false
	
	
	
	init()
	{
		self.isMetric = MZSessionDataManager.sharedInstance.session.userProfile.preferences.units == "metric" ? true : false
		
		self.is24hFormat = MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat == 24 ? true : false
		
		self.emailNotifications = MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state == true ? true : false
		
		self.smsNotifications = MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state == true ? true : false
		
		self.pushNotifications = MZLocalStorageHelper.loadPushNotificationsStatusFromNSUserDefaults()
		
		self.places = [MZPlaceViewModel]()
		
		for place in MZSessionDataManager.sharedInstance.session.userProfile.places
		{
			self.places.append(MZPlaceViewModel(pl: place))
		}
		
		MZNotifications.register(self, selector: #selector(self.reloadLocalSettings), notificationKey: MZNotificationKeys.UserProfile.SettingsUpdated)
	}
	

	
	@objc func reloadLocalSettings()
	{
		self.isMetric = MZSessionDataManager.sharedInstance.session.userProfile.preferences.units == "metric" ? true : false
		
		self.is24hFormat = MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat == 24 ? true : false
		
		self.places = [MZPlaceViewModel]()
		
		for place in MZSessionDataManager.sharedInstance.session.userProfile.places
		{
			self.places.append(MZPlaceViewModel(pl: place))
		}
		
		self.emailNotifications = MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state == true ? true : false
		
		self.smsNotifications = MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state == true ? true : false
		
		self.pushNotifications = MZLocalStorageHelper.loadPushNotificationsStatusFromNSUserDefaults()
	}
	
	func setUnits(_ completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		let units : UnitsSystem = self.isMetric ? UnitsSystem.metric : UnitsSystem.imperial

		MZSessionDataManager.sharedInstance.updateUnitsSystem(units, completion: { (success, error) -> Void in
			if(error == nil)
			{
				if(success as Bool)
				{
					MZNotifications.send(MZNotificationKeys.UserProfile.UnitsSystemUpdated, obj: nil)
					completion(true, nil)
				}
			}
			else
			{
				self.isMetric = !self.isMetric
				completion(false, error)
			}
		})
	}
	
	func setHourFormat(_ completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		let timeFormat : Int = self.is24hFormat ? 24 : 12
		
		MZSessionDataManager.sharedInstance.updateTimeFormat(timeFormat, completion: { (success, error) -> Void in
			if(error == nil)
			{
				if(success as Bool)
				{
					MZNotifications.send(MZNotificationKeys.UserProfile.HourFormatUpdated, obj: nil)
					completion(true, nil)
				}
			}
			else
			{
				self.is24hFormat = !self.is24hFormat
				completion(false, error)
			}
		})
	}
	
	
	func  setPushNotifications(_ enabled : Bool) -> Bool
	{
		if enabled
		{
            if MZDeviceInfoHelper.areNotificationsEnabled()
			{
				MZLocalStorageHelper.savePushNotificationsStatusToNSUserDefaults(enabled)
				
				AppManager.shared().activateRemoteNotificationsService(withTags: MZSessionDataManager.sharedInstance.lastNotificationTags) // Uses the previously fetched tags.
			}
			else
			{
				// Update UI to show that the system notifications are disabled but show toggle as enabled
				MZLocalStorageHelper.savePushNotificationsStatusToNSUserDefaults(enabled)
				AppManager.shared().deactivateRemoteNotificationsService()

				return true
			}
		}
		else
		{
			// Unregister
			AppManager.shared().deactivateRemoteNotificationsService()
		}
		
		MZLocalStorageHelper.savePushNotificationsStatusToNSUserDefaults(enabled)
		NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)

		return true
	}
	
	func setEmailNotifications(_ completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		let enabled : Bool = self.emailNotifications ? true : false
		
		MZSessionDataManager.sharedInstance.updateEmailNotifications(enabled, completion: { (success, error) -> Void in
			if(error == nil)
			{
				if(success as Bool)
				{
					completion(true, nil)
				}
			}
			else
			{
				self.emailNotifications = !self.emailNotifications
				completion(false, error)
			}
		})
	}
	
	func setSmsNotifications(_ completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		let enabled : Bool = self.smsNotifications ? true : false
		
		MZSessionDataManager.sharedInstance.updateSmsNotifications(enabled, completion: { (success, error) -> Void in
			if(error == nil)
			{
				if(success as Bool)
				{
					completion(true, nil)
				}
			}
			else
			{
				self.smsNotifications = !self.smsNotifications
				completion(false, error)
			}
		})
	}
}
