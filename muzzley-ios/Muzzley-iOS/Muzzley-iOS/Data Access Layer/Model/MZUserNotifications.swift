//
//  MZUserNotifications.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 01/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZUserNotifications
{
	let key_email = "email"
	let key_sms = "sms"
	
	var email : MZEmailNotifications
	var sms : MZSmsNotifications
	
	var dictionaryRepresentation = NSDictionary()
	
	
	init()
	{
		email = MZEmailNotifications()
		sms = MZSmsNotifications()
	}
	
	required init(dictionary: NSDictionary)
	{
		self.dictionaryRepresentation = dictionary
		
		if let _emailDic = dictionary[self.key_email] as? NSDictionary {
			self.email = MZEmailNotifications(dictionary: _emailDic)
		}
		else
		{
			self.email = MZEmailNotifications()
		}
		
		
		if let _smsDic = dictionary[self.key_sms] as? NSDictionary {
			self.sms = MZSmsNotifications(dictionary: _smsDic)
		}
		else
		{
			self.sms = MZSmsNotifications()
		}
	}

}



class MZSmsNotifications
{
	let key_state = "state"
	
	var dictionaryRepresentation = NSDictionary()
	
	var state : Bool
	
	init()
	{
		state = true
	}
	
	
	required init(dictionary: NSDictionary)
	{
		self.dictionaryRepresentation = dictionary
		
		if let _state = dictionary[self.key_state] as? Bool {
			self.state = _state
		}
		else
		{
			self.state = true
		}
	}
}

class MZEmailNotifications
{
	let key_state = "state"

	var dictionaryRepresentation = NSDictionary()
	
	var state : Bool
	
	init()
	{
		state = true
	}
	
	
	required init(dictionary: NSDictionary)
	{
		self.dictionaryRepresentation = dictionary
		
		if let _state = dictionary[self.key_state] as? Bool {
			self.state = _state
		}
		else
		{
			self.state = true
		}
	}
}
