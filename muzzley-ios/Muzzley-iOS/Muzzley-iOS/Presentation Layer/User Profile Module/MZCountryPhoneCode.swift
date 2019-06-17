//
//  MZCountryPhoneCode.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 18/08/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZCountryPhoneCode
{
	var phoneCode : String
	var countryCode : String
	var countryName : String
	
	init(_phoneCode: String, _countryCode : String, _countryName : String)
	{
		self.phoneCode = _phoneCode
		self.countryCode = _countryCode
		self.countryName = _countryName
	}
	
	
	init(_countryName : String)
	{
		self.countryName = _countryName
		self.phoneCode = ""
		self.countryCode = ""
	}
	
}
