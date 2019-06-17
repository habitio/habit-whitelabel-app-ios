//
//  MZDateExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/01/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//

import Foundation

extension Date {
    static var nowDateInHabitUTC: String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") as! TimeZone
        return dateFormatter.string(from: Date())
        
    }
}

@objc class MZDateHelper : NSObject
{
    static func dateInHabitUTC(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") as! TimeZone
        return dateFormatter.string(from: date)
        
    }
    
    static func dateToString(_ date: Date, dateFormat: String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
    
    
    static func stringToDate(_ dateStr: String, dateFormat: String) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: dateStr)!
    }
    
}
