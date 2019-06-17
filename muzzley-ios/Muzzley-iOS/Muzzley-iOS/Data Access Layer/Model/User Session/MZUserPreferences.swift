//
//  MZUserSettings.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 10/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

enum UnitsSystem
{
	case metric
	case imperial
	case nonSI
	case unknown
}

class MZUserPreferences
{
	
	let key_units = "units"
	let key_timezone = "timezone"
	let key_currency  = "currency"
	let key_hourFormat = "hourFormat"
	let key_language = "language"
	let key_locale = "locale"
	let key_notifications = "notifications"
	
	// Class variables
	var units : String  = ""
	var timezone : String = ""
	var currency : String = ""
	var hourFormat : Int = 12
	var language : String = ""
	var locale : String = ""
	var notifications : MZUserNotifications = MZUserNotifications()
	
	var dictionaryRepresentation = NSDictionary()
	
	required init()
	{
		self.units = ""
		self.timezone = ""
		self.currency = ""
		self.hourFormat  = 12
		self.language = ""
		self.locale = ""
		self.notifications = MZUserNotifications()
	}
	
	init(dictionary : NSDictionary)
	{
		self.dictionaryRepresentation = dictionary
		
		if let _units = dictionary[self.key_units] as? String {
			self.units = _units
		}
		else
		{
			self.units = "metric"
		}
		
		if let _timezone = dictionary[self.key_timezone] as? String {
			self.timezone = _timezone
		}
		if let _currency = dictionary[self.key_currency] as? String {
			self.currency = _currency
		}
		if let _hourFormat = dictionary[self.key_hourFormat] as? Int {
			self.hourFormat = _hourFormat
		}
		if let _language = dictionary[self.key_language] as? String {
			self.language = _language
		}
		if let _locale = dictionary[self.key_locale] as? String {
			self.locale = _locale
		}
		
		if let _notifications = dictionary[self.key_notifications] as? NSDictionary {
			self.notifications = MZUserNotifications(dictionary: _notifications)
		}
	}
	
	func checkForChanges() -> Bool
	{
		var needsUpdate = false
		
		let unitsSystem = MZDeviceInfoHelper.getLocaleUnitsSystem()
		let timezone = MZDeviceInfoHelper.getTimeZone()
		let currency = MZDeviceInfoHelper.getCurrencyCode()
		//let hourFormat = MZDeviceInfoHelper.getHourFormat()
		let language = MZDeviceInfoHelper.getDeviceLanguage()
		let locale = MZDeviceInfoHelper.getLocale()
		
		if(self.timezone != timezone)
		{
			self.timezone = timezone
			needsUpdate = true
		}
		if(self.currency != currency)
		{
			self.currency = currency
			needsUpdate = true
		}
		
		if(self.language != language || self.language.contains("\(language)_"))
		{
			self.language = language
			needsUpdate = true
		}
		if(self.locale != locale)
		{
			self.locale = locale
			needsUpdate = true
		}
		if(self.units.isEmpty)
		{
			self.units = unitsSystem
			needsUpdate = true
		}
		
		if(needsUpdate)
		{
			let tempDic: NSDictionary =
			[
				self.key_units : self.units,
				self.key_timezone : self.timezone,
				self.key_currency : self.currency,
				self.key_hourFormat : self.hourFormat,
				self.key_language : self.language,
				self.key_locale : self.locale
			]
			self.dictionaryRepresentation = tempDic
		}
		
		return needsUpdate
	}
}










