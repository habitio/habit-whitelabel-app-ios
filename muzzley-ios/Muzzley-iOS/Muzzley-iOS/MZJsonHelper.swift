//
//  MZJsonHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 25/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZJsonHelper
{
	// TODO: See if it's possible to simplify serialization between classes and Json objects and put helper functions here
	
    static func stringify(_ obj: AnyObject, _ prettyPrint: Bool = false) -> String
	{
		do
		{
            if prettyPrint
            {
                let jsonData = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.prettyPrinted)
                return (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String)
            }
            else
            {
                let jsonData = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.prettyPrinted)
                return (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String) .replacingOccurrences(of: "\n", with: "")
            }
		}
		catch
		{
			return ""
		}
	}
	
	
	static func JSONStringify(_ value: AnyObject,prettyPrinted:Bool = false) -> String
    {
		let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
		
		
		if JSONSerialization.isValidJSONObject(value) {
			
			do{
				let data = try JSONSerialization.data(withJSONObject: value, options: options)
				if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
					return string as String
				}
			}catch {
				
//				dLog(message: "error")
				//Access error here
			}
			
		}
		return ""
		
	}
	
	static func convertStringToDictionary(text: String) -> [String: Any]?
    {
		if let data = text.data(using: .utf8) {
			do {
				return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
			} catch {
//				dLog(message: error.localizedDescription)
			}
		}
		return nil
	}
}
