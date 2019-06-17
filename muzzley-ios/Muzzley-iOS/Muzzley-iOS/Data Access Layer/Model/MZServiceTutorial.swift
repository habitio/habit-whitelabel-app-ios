//
//  MZServiceTutorial.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZServiceTutorial : NSObject
{
	
	static let key_url = "url"
	static let key_steps = "steps"

	var url: String
	var steps: [MZServiceTutorialStep]
	
	var dictionaryRepresentation: NSDictionary
	
	override init()
	{
		
		self.url = ""
		self.steps = [MZServiceTutorialStep]()
		
		dictionaryRepresentation = NSDictionary()
		
		super.init()
	}
	
	
	convenience init(dictionary: NSDictionary)
	{
		self.init()
		
		if (dictionary.isKind(of: NSDictionary.self))
		{
			self.dictionaryRepresentation = dictionary
			
			if let _url = dictionary[MZServiceTutorial.key_url] as? String
			{
				self.url = _url
			}
			
			self.steps = [MZServiceTutorialStep]()
			if let _steps = dictionary[MZServiceTutorial.key_steps] as? NSArray
			{
				for step in _steps
				{
					steps.append(MZServiceTutorialStep(dictionary: step as! NSDictionary))
				}
			}
		}
	}
}
