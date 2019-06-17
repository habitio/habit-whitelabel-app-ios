//
//  MZTileInformation.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//
enum InfoType
{
	case textUnit
	case textExpression
	case iconColor
	case unknown
}


class MZTileInformation: MZBaseTileAttr
{
	static let key_property         = "property"
	static let key_type             = "type"
	static let key_label            = "label"
	static let key_componentType    = "componentType"
	static let key_options          = "options"
	static let key_inputUnit        = "inputUnit"
	static let key_inputPath        = "inputPath"
	static let key_suffix           = "suffix"
	static let key_prefix           = "prefix"
	static let key_mathExpression   = "mathExpression"
	static let key_format           = "format"
	static let key_char             = "char"
	
	static let key_unit_muzzleyUnit = "muzzleyUnit"
	static let key_unit_targetImperial = "targetImperial"
	static let key_unit_targetMetric = "targetMetric"
	
	
	static let type_icon            = "icon-color"
	static let type_text            = "text"
	static let type_unit            = "text-unit"
	static let type_expression      = "text-expression"
	
	static let color_hsv            = "hsv"
	static let color_rgb            = "rgb"
	
	var label: String           = ""
	var char: String            = ""
	var format: String          = ""
	var unit: String            = ""
	var mathExpression: String  = ""
	var infoType : InfoType = InfoType.unknown
	
	var muzzleyUnit : String = ""
	var targetMetric : String = ""
	var targetImperial : String = ""
	
	func updateWithChannelPropertyInfo(_ unitOptions: NSDictionary)
	{
		
		if let _muzzleyUnit : String = unitOptions[MZTileInformation.key_unit_muzzleyUnit] as? String
		{
			muzzleyUnit = _muzzleyUnit
			
			var isMetricOrImperial = false
			if let _targetImperial: String = unitOptions[MZTileInformation.key_unit_targetImperial] as? String
			{
				isMetricOrImperial = true
				targetImperial = _targetImperial
			}
			
			if let _targetMetric : String = unitOptions[MZTileInformation.key_unit_targetMetric] as? String
			{
				isMetricOrImperial = true
				targetMetric = _targetMetric
			}
			
			if isMetricOrImperial //&& MZSessionDataManager.sharedInstance.session.isOpen
			{
				switch MZSessionDataManager.sharedInstance.session.userProfile.preferences.units
				{
				case "metric":
					self.unit = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(targetMetric).trim()
					
					break
					
				case "imperial":
					self.unit = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(targetImperial).trim()
					break
					
				default:
					break
				}
			}
			else
			{
				let suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(muzzleyUnit)
				if(suffix != "")
				{
					self.unit = suffix
				}
			}
		}

	
	}
	
	override init(dictionary: NSDictionary)
	{
		super.init(dictionary: dictionary)
		if (dictionary.isKind(of: NSDictionary.self))
		{
			if let label : String = dictionary[MZTileInformation.key_label] as? String {
				self.label = label
			}
			
			if let options : NSDictionary = dictionary[MZTileInformation.key_options] as? NSDictionary
			{
				// Sort according to type.
				// Type needs to be stored for future reference in unit conversion and to be able to differentiate between text-unit and text-expression.
				if let _type : String = dictionary[MZTileInformation.key_type] as? String
				{
					switch _type
					{
					case MZTileInformation.type_unit:
						infoType = InfoType.textUnit
//						if let inputUnit : String = options[MZTileInformation.key_inputUnit] as? String
//						{
//							self.unit = inputUnit // Set this if the following code fails for some reason (Default value)
//						}
						
						break
						
						
					case MZTileInformation.type_expression:
						infoType = InfoType.textExpression
						if let suffix : String = options[MZTileInformation.key_suffix] as? String
						{
							self.unit = suffix // unit is being used for both the input unit and the suffix (type_unit and type_expression)
						}
						
						if let mathExpression: String = options[MZTileInformation.key_mathExpression] as? String
						{
							self.mathExpression = mathExpression
						}
						break
						
						
					case MZTileInformation.type_icon:
						infoType = InfoType.iconColor
						if let char: String = options[MZTileInformation.key_char] as? String {
							self.char = char
						}
						if let format: String = options[MZTileInformation.key_format] as? String {
							self.format = format
						}
						
						break
						
					default:
						break
					}
				}
			}
		}
	}
}
