//
//  MZService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZService : NSObject
{
	static let key_id = "id"
	static let key_name = "name"
	static let key_shopUrl = "shopUrl"
	static let key_shopDescription = "shopDescription"
	static let key_photoUrlSquared = "photoUrlSquared"
	static let key_requiredCapability = "requiredCapability"
	static let key_profiles = "profiles"
	static let key_tutorial = "tutorial"
	static let key_summary = "summary"
	
	
	var id: String
	var name: String
	var shopUrl: String
	var shopDescription: String
	var photoUrlSquared: String
	var requiredCapability: String
	var profiles : [MZServiceDeviceProfile]
	var tutorial : MZServiceTutorial
	var summary : MZServiceSummary
	var dictionaryRepresentation: NSDictionary
	
	override init()
	{
		dictionaryRepresentation = NSDictionary()
		id = ""
		name = ""
		shopUrl = ""
		shopDescription = ""
		photoUrlSquared = ""
		requiredCapability = ""
		profiles = [MZServiceDeviceProfile]()
		tutorial = MZServiceTutorial()
		summary = MZServiceSummary()
		
		super.init()
	}
	
	convenience init(dictionary: NSDictionary)
	{
		self.init()
		
		if (dictionary.isKind(of: NSDictionary.self))
		{
			self.dictionaryRepresentation = dictionary
			
			if let _id = dictionary[MZService.key_id] as? String {
				self.id = _id
			}
			
			if let _name = dictionary[MZService.key_name] as? String {
				self.name = _name
			}
	
			
			if let _shopUrl = dictionary[MZService.key_shopUrl] as? String {
				self.shopUrl = _shopUrl
			}
		
			if let _shopDescription = dictionary[MZService.key_shopDescription] as? String {
				self.shopDescription = _shopDescription
			}
			
			if let _photoUrlSquared = dictionary[MZService.key_photoUrlSquared] as? String {
				self.photoUrlSquared = _photoUrlSquared
			}
			
			if let _requiredCapability = dictionary[MZService.key_requiredCapability] as? String {
				self.requiredCapability = _requiredCapability
			}
				
			
			if let _profiles = dictionary[MZService.key_profiles] as? NSArray
			{
				self.profiles = [MZServiceDeviceProfile]()
				for profile in _profiles
				{
					self.profiles.append(MZServiceDeviceProfile(dictionary: profile as! NSDictionary))
				}
			}
			
			if let _tutorial = dictionary[MZService.key_tutorial] as? NSDictionary {
				self.tutorial = MZServiceTutorial(dictionary: _tutorial)
			}
			
			if let _summary = dictionary[MZService.key_summary] as? NSDictionary {
				self.summary = MZServiceSummary(dictionary: _summary)
			}
			
		}
	}
}
