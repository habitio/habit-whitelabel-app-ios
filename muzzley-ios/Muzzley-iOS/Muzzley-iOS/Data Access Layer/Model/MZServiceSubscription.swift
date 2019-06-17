//
//  MZServiceSubscription.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 07/04/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZServiceSubscription: NSObject {

	static let key_id = "id"
	static let key_name = "name"
	static let key_state = "state"
	static let key_squaredImageUrl = "squaredImageUrl"
	static let key_infoUrl = "infoUrl"

	
	
	var id: String
	var name: String
	var state: Bool
	var squaredImageUrl: String
	var infoUrl: String

	var dictionaryRepresentation: NSDictionary
	
	override init()
	{
		dictionaryRepresentation = NSDictionary()
		id = ""
		name = ""
		state = false
		squaredImageUrl = ""
		infoUrl = ""
		
		super.init()
	}
	
	convenience init(dictionary: NSDictionary)
	{
		self.init()
		
		if (dictionary.isKind(of: NSDictionary.self))
		{
			self.dictionaryRepresentation = dictionary
			
			if let _id = dictionary[MZServiceSubscription.key_id] as? String {
				self.id = _id
			}
			
			if let _name = dictionary[MZServiceSubscription.key_name] as? String {
				self.name = _name
			}
			
			
			if let _squaredImageUrl = dictionary[MZServiceSubscription.key_squaredImageUrl] as? String {
				self.squaredImageUrl = _squaredImageUrl
			}
			
			if let _infoUrl = dictionary[MZServiceSubscription.key_infoUrl] as? String {
				self.infoUrl = _infoUrl
			}
			
			if let _state = dictionary[MZServiceSubscription.key_state] as? Bool {
				self.state = _state
			}
			
			
		}
	}

	
}
