//
//  MZDiscoveryProcess.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation


@objc class MZDiscoveryProcess : NSObject
{
	
	let key_context = "context"
	let key_title = "title"
	let key_dpDescription = "dpDescription"
	let key_image = "image"
	let key_steps = "steps"
	let key_connectionType = "connectionType"
	let key_nextStepUrl = "nextStepUrl"
	
	var context : String = ""
	var title : String = ""
	var dpDescription : String = ""
	var image : String = ""
	var steps : Int = 0
	var connectionType : String = ""
	var nextStepUrl : String = ""
	
	init(dictionary : NSDictionary)
	{
		if let _context = dictionary[key_context] as? String
		{
			self.context = _context
		}
		else
		{
			self.context = ""
		}
		

		if let _title = dictionary[key_title] as? String
		{
			self.title = _title
		}
		else
		{
			self.title = ""
		}
		
		if let _dpDescription = dictionary[key_dpDescription] as? String
		{
			self.dpDescription = _dpDescription
		}
		else
		{
			self.dpDescription = ""
		}
		
		if let _image = dictionary[key_image] as? String
		{
			self.image = _image
		}
		else
		{
			self.image = ""
		}
		
		if let _steps = dictionary[key_steps] as? Int
		{
			self.steps = _steps
		}
		else
		{
			self.steps = 0
		}
		
		if let _connectionType = dictionary[key_connectionType] as? String
		{
			self.connectionType = _connectionType
		}
		else
		{
			self.connectionType = ""
		}
		
		if let _nextStepUrl = dictionary[key_nextStepUrl] as? String
		{
			self.nextStepUrl = _nextStepUrl
		}
		else
		{
			self.nextStepUrl = ""
		}
	}

}
