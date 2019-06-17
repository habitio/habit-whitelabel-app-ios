//
//  MZCurrencySpecs.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 20/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZCurrencySpec : NSObject
{
	
	static let key_version = "version"
	static let key_base = "base"
	static let key_currencyCalc = "currencyCalc"
	
	var version : String = ""
	var base : String = ""
	var currencyCalc = NSDictionary()
	
	//	var currencyDictionary = ""
	var currencyDictionary = NSDictionary()
	
	var isLoaded = false
	
	
	func setCurrencySpec(_ dictionary : NSDictionary)
	{
		if (dictionary.isKind(of: NSDictionary.self))
		{
			currencyDictionary = dictionary
			//currencyDictionary = MZJsonHelper.stringify(dictionary)
			//print(currencyDictionary)
			if let _version = dictionary[MZCurrencySpec.key_version] as? String  { version = _version }
			if let _base = dictionary[MZCurrencySpec.key_base] as? String  { base = _base }
			if let _currencyCalc = dictionary[MZCurrencySpec.key_currencyCalc] as? NSDictionary { currencyCalc = _currencyCalc }
			isLoaded = true
		}
	}
	
	func calculateCurrency(_ currency: String, value: Double) -> Double
	{
		if let conversionValue = currencyCalc[currency] as? Double
		{
			return value * conversionValue
		}
		
		return value // Something went wrong. Just return the same value
	}
}
