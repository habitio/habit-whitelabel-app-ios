//
//  MZDiscoveryProcessAction.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

@objc class MZDiscoveryProcessAction : NSObject
{
	let key_identifier = "id"
	let key_type = "type"
	let key_params = "params"
	
	var identifier : String = ""
	var type : String = ""
	var params : NSDictionary = NSDictionary()

	
	override init()
	{
		super.init()
	}
	
	init(dictionary : NSDictionary)
	{
		super.init()
		if let _identifier = dictionary[key_identifier] as? String
		{
			self.identifier = _identifier
		}
		else
		{
			self.identifier = ""
		}
		
		if let _type = dictionary[key_type] as? String
		{
			self.type = _type
		}
		else
		{
			self.type = ""
		}
		
		if let _params = dictionary[key_params] as? NSDictionary
		{
			self.params = _params
		}
		else
		{
			self.params = NSDictionary()
		}

	}
}
