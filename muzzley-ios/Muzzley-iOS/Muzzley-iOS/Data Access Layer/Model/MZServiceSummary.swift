//
//  MZServiceSummary.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZServiceSummary: NSObject
{
	static let key_topUrl = "topUrl"
	static let key_botUrl = "botUrl"
	static let key_title = "title"
	static let key_body = "body"
	
	var topUrl: String
	var botUrl: String

	var title: String
	var body : String
	
	var dictionaryRepresentation: NSDictionary
	
	override init()
	{
		self.topUrl = ""
		self.botUrl = ""
		self.title = ""
		self.body = ""
		self.dictionaryRepresentation = NSDictionary()
		super.init()
	}
	
	convenience init(dictionary: NSDictionary)
	{
		self.init()
		if (dictionary.isKind(of: NSDictionary.self))
		{
			self.dictionaryRepresentation = dictionary
			
			if let _topUrl = dictionary[MZServiceSummary.key_topUrl] as? String
			{
				self.topUrl = _topUrl
			}
			
			if let _botUrl = dictionary[MZServiceSummary.key_botUrl] as? String
			{
				self.botUrl = _botUrl
			}
			
			if let _title = dictionary[MZServiceSummary.key_title] as? String
			{
				self.title = _title
			}
			
			if let _body = dictionary[MZServiceSummary.key_body] as? String
			{
				self.body = _body
			}
		}
	}

}
