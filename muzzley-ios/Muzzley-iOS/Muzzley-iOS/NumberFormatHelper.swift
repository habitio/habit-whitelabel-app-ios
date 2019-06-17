//
//  NumberFormatHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class NumberFormatHelper
{
	static func formatNumberAccordingToLocale(_ number: Double) -> String
	{
		let formatter = NumberFormatter()
		formatter.locale = Locale.current
		formatter.numberStyle = .decimal
		return formatter.string(from: number as! NSNumber)!
	}

	static func formatCurrencyAccordingToLocale(_ number: Double) -> String
	{
		let formatter = NumberFormatter()
		formatter.locale = Locale.current
		formatter.numberStyle = .currency
		return formatter.string(from: number as! NSNumber)!
	}
}
