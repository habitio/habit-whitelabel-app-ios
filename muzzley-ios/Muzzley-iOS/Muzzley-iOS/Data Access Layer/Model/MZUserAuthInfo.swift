//
//  MZUserAuthInfo.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation


// To hold the info obtained in the new oAuth!

class MZUserAuthInfo : NSObject
{
	
	let key_access_token = "access_token"
	let key_client_id = "client_id"
	let key_endpoints = "endpoints"
	let key_endpoints_http = "http"
	let key_endpoints_mqtt = "mqtt"
	let key_expires = "expires"
	let key_owner_id = "owner_id"
	let key_refresh_token = "refresh_token"
	
	var clientId : String = ""
	var userId : String = ""
	var accessToken : String = ""
	var refreshToken : String = ""
	var expiresDate : String
	var httpUrl : String = ""
	var mqttUrl : String = ""

	var dictionaryRepresentation = NSDictionary()
	
	init(clientId: String, userId : String, accessToken : String, refreshToken : String, expireDate: String, httpUrl: String,  mqttUrl: String)
	{
		self.clientId = clientId
		self.userId = userId
		self.accessToken = accessToken
		self.refreshToken = refreshToken
		self.expiresDate = expireDate
		self.httpUrl = httpUrl
		self.mqttUrl = mqttUrl
		
		
		APIHost = self.httpUrl
		MQTTHost = self.mqttUrl
		
		if(APIHost.isEmpty || MQTTHost.isEmpty)
		{
			MZSession.sharedInstance.closeAndClear()
		}
	}
	
	init(dictionary : NSDictionary)
	{
		self.dictionaryRepresentation = dictionary
		
		if let user_id = dictionary.value(forKey: key_owner_id) as? String
		{
			self.userId = user_id
		}
		else
		{
			self.userId = ""
		}
		
		if let access_token = dictionary.value(forKey: key_access_token) as? String
		{
			self.accessToken = access_token
		}
		else
		{
			self.accessToken = ""
		}

		if let refresh_token = dictionary.value(forKey: key_refresh_token) as? String
		{
			self.refreshToken = refresh_token
		}
		else
		{
			self.refreshToken = ""
		}
		
		
		if let client_id = dictionary.value(forKey: key_client_id) as? String
		{
			self.clientId = client_id
		}
		else
		{
			self.clientId = ""
		}
		

		if let expires = dictionary.value(forKey: key_expires) as? String
		{
			self.expiresDate = expires
		}
		else
		{
			self.expiresDate = ""
		}
		
		if let endpoints = dictionary.value(forKey: key_endpoints) as? NSDictionary
		{
			if let http = endpoints.value(forKey: key_endpoints_http) as? String
			{
				self.httpUrl = http
			}
			else
			{
				self.httpUrl = ""
			}
			
			if let mqtt = endpoints.value(forKey: key_endpoints_mqtt) as? String
			{
				self.mqttUrl = mqtt
			}
			else
			{
				self.mqttUrl = ""
			}
			
		}
		else
		{
			self.httpUrl = ""
			self.mqttUrl = ""
		}
		
		APIHost = self.httpUrl
		MQTTHost = self.mqttUrl
		
		if(APIHost.isEmpty || MQTTHost.isEmpty)
		{
			MZSession.sharedInstance.closeAndClear()
		}
		
	}
}
