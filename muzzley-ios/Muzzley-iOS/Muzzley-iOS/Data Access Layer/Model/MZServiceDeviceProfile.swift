//
//  MZServiceDeviceProfile.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZServiceDeviceProfile : NSObject
{
	static let key_id = "id"
	static let key_occurrences = "occurrences"
	
	
 	var id: String
	var occurrences: Int
	
	var dictionaryRepresentation: NSDictionary
	
	override init()
	{
		self.id = ""
		self.occurrences = 0
		
		dictionaryRepresentation = NSDictionary()
		
		super.init()
	}
	
	
	convenience init(dictionary: NSDictionary)
	{
		self.init()
		
		if (dictionary.isKind(of: NSDictionary.self))
		{
			self.dictionaryRepresentation = dictionary
			
			if let _id = dictionary[MZServiceDeviceProfile.key_id] as? String {
				self.id = _id
			}
			
			if let _occurrences = dictionary[MZServiceDeviceProfile.key_occurrences] as? Int {
				self.occurrences = _occurrences
			}
		}
	}
}
