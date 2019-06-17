//
//  MZUnitSpec.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
class MZUnitsSpec : NSObject
{
	static let key_version = "version"
	
	static let key_unitSpec = "unitSpec"
	static let key_unitSpec_metric = "metric"
	static let key_unitSpec_imperial = "imperial"
	static let key_unitCalc = "unitCalc"
	static let key_unitCalc_metric = "metric"
	static let key_unitCalc_imperial = "imperial"
	static let key_unitSpec_nonSI = "nonSI"
	
	
	static let key_unit_decimalPlaces = "decimalPlaces"
	static let key_unit_suffix = "suffix"
	static let key_unit_prefix = "prefix"
	static let key_unit_name = "name"
	static let key_unit_nameSingular = "nameSingular"
	static let key_unit_namePlural = "namePlural"
	
	var version : String = ""
	
	var allUnits = NSDictionary()
	
	var conversions = NSDictionary()
	
	var isLoaded = false
	
	var unitsDictionary = NSDictionary() // To be sent to the webview
	
	func setUnitsSpec(_ dictionary : NSDictionary)
	{
		
		if (dictionary.isKind(of: NSDictionary.self))
		{
			unitsDictionary = dictionary
			if let _version = dictionary[MZUnitsSpec.key_version] as? String  { version = _version }
			
			if let _unitSpec = dictionary[MZUnitsSpec.key_unitSpec] as? NSDictionary
			{
				allUnits = _unitSpec
			}
			
			if let _unitCalc = dictionary[MZUnitsSpec.key_unitCalc] as? NSDictionary
			{
				conversions = _unitCalc
			}
		}
		isLoaded = true
	}
	
	
	func getUnitDecimalPlaces(_ unitKey: String) -> Int
	{
		
		if let unit = allUnits[unitKey] as? NSDictionary
		{
			if let _decimalPlaces = unit[MZUnitsSpec.key_unit_decimalPlaces] as? Int
			{
				return _decimalPlaces
			}
		}
		
		return 1
	}
	
	func applyUnitDecimalPlaces(_ unitKey: String, value: Double) -> Double
	{
		let decimalPlaces = getUnitDecimalPlaces(unitKey)
		
		let strFormat = "%." + String(decimalPlaces) + "f"
		var retValue = value
		let val = Double(String(format: strFormat, value))
		if val!.truncatingRemainder(dividingBy: 1) == 0
		{
			retValue = Double(String(format: "%.0f", value))!
		}
		else
		{
			retValue = Double(String(val!))!
		}
		
		return retValue
	}
	
	func getUnitSuffix(_ unitKey: String) -> String
	{
		if let unit = allUnits[unitKey] as? NSDictionary
		{
			if let _suffix = unit[MZUnitsSpec.key_unit_suffix] as? String
			{
				
				return _suffix.trim()
			}
		}

		return ""
	}
	
	func getUnitPrefix(_ userUnitSystem: UnitsSystem, unitKey: String) -> String
	{
		if let unit = allUnits[unitKey] as? NSDictionary
		{
			if let _prefix = unit[MZUnitsSpec.key_unit_prefix] as? String
			{
				return _prefix
			}
		}
		return ""
	}
	
	func getUnitNameSingular(_ userUnitSystem: UnitsSystem, unitKey: String) -> String
	{
		
		if let unit = allUnits[unitKey] as? NSDictionary
		{
			if let name = unit[MZUnitsSpec.key_unit_name] as? NSDictionary
			{
				if let _nameSingular = name[MZUnitsSpec.key_unit_nameSingular] as? String
				{
					return _nameSingular
				}
			}
		}
		
		return ""
	}
	
	func getUnitNamePlural(_ userUnitSystem: UnitsSystem, unitKey: String) -> String
	{
		
		if let unit = allUnits[unitKey] as? NSDictionary
		{
			if let name = unit[MZUnitsSpec.key_unit_name] as? NSDictionary
			{
				if let _namePlural = name[MZUnitsSpec.key_unit_namePlural] as? String
				{
					return _namePlural
				}
			}
		}
		
		return ""
	}
	
	func convertUnits(_ originUnitKey: String, targetUnitKey: String, value: Double) -> Double
	{
		if let conversionExpressions = conversions[originUnitKey] as? NSDictionary
		{
			if let mathExpression = conversionExpressions[targetUnitKey] as? String
			{
				let val = MathExpressionsHelper.calculate(mathExpression, value: value)
				
				// Remove extra decimal places
				return val
			}
		}
		
		return value // Something went wrong. Just return the same value
	}
	
	
}


