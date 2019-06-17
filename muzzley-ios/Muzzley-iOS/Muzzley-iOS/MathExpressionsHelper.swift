//
//  MathExpressionsHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MathExpressionsHelper
{
	class func calculate(_ mathExpression: String, value: Double) -> Double
	{
		let filledMathExpress = mathExpression.replacingOccurrences(of: "x", with: "\(value)")
		if !filledMathExpress.isEmpty
		{
			return NSExpression(format:filledMathExpress).expressionValue(with: nil, context: nil) as! Double
		}
		
		return value
	}
}
