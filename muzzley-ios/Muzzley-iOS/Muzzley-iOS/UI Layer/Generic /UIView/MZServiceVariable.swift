//
//  MZServiceVariable.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/02/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZServiceVariable
{
	let key_profile = "profile"
	let key_class = "class"
	let key_channel = "channel"
	let key_remoteId = "remoteId"
	let key_component = "component"
	
	var profileId : String
	var componentClass : String
	var channelId : String
	var channelRemoteId : String
	var componentId : String
	
	init(profileId : String, componentClass: String, channelId: String, channelRemoteId: String, componentId : String)
	{
		self.profileId = profileId
		self.componentClass = componentClass
		self.channelId = channelId
		self.channelRemoteId = channelRemoteId
		self.componentId = componentId
	}
	
	// TODO: Hasn't been tested!
	func createVariablesNSDictionary(_ arrayOfVariables: [MZServiceVariable]) -> NSDictionary
	{
		let variables : NSMutableDictionary = NSMutableDictionary()
		let dictionary : NSMutableDictionary = NSMutableDictionary()
		
		
		for variable in arrayOfVariables
		{
			let v = NSMutableDictionary()
			v[self.key_profile] = variable.profileId
			v[self.key_class] = variable.componentClass
			v[self.key_channel] = variable.channelId
			v[self.key_remoteId] = variable.channelRemoteId
			v[self.key_component] = variable.componentId
			variables.addEntries(from: v as! [AnyHashable: Any])
		}
		
		dictionary["variables"] = variables
		return dictionary
	}
}
