//
//  MZServiceTutorialStep.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZServiceTutorialStep : NSObject
{
	
	static let key_url = "url"
	static let key_type = "type"
    static let key_title = "title"
	static let key_description = "description"

	var url: String
	var type: String
    var stepTitle: String
	var stepDescription : String
	
	var dictionaryRepresentation: NSDictionary
	
	override init()
	{
		self.url = ""
		self.type = ""
        self.stepTitle = ""
		self.stepDescription = ""
		self.dictionaryRepresentation = NSDictionary()
		super.init()
	}
	
	convenience init(dictionary: NSDictionary)
	{
		self.init()
		if (dictionary.isKind(of: NSDictionary.self))
		{
			self.dictionaryRepresentation = dictionary
			
			if let _url = dictionary[MZServiceTutorialStep.key_url] as? String
			{
				self.url = _url
			}
			
			if let _type = dictionary[MZServiceTutorialStep.key_type] as? String
			{
				self.type = _type
			}
            
            if let _title = dictionary[MZServiceTutorialStep.key_title] as? String
            {
                self.stepTitle = _title
            }
			
			if let _description = dictionary[MZServiceTutorialStep.key_description] as? String
			{
				self.stepDescription = _description
			}
		}
	}
}
