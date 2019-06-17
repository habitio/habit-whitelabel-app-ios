//
//  StringExtensionMethods.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 18/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension String
{
	func trim() -> String
	{
		return self.trimmingCharacters(in: CharacterSet.whitespaces)
	}
    
	func removeCharsAtEnd(_ numberOfChars: Int) -> String
	{
		return self.substring(to: self.characters.index(self.endIndex, offsetBy: -numberOfChars))
	}
	
	func removeCharsAtBeginning(_ numberOfChars: Int) -> String
	{
		return self.substring(from: self.characters.index(self.startIndex, offsetBy: numberOfChars))
	}
    
}
