//
//  TimeFormatHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 20/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class TimeFormatHelper
{
	static func formatTime(_ hourFormat: Int, date: Date ) -> String
	{
		let dateFormatter = DateFormatter()

		// This locale override needs to be here and override the locale because otherwise the HH 24h format won't work...
		let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
		
		if(hourFormat == 12)
		{
			dateFormatter.dateFormat = "hh:mm a"
//			print(dateFormatter.stringFromDate(date))
			return dateFormatter.string(from: date)
		}
		else
		{
			dateFormatter.dateFormat = "HH:mm"
//			print(dateFormatter.stringFromDate(date))
			return dateFormatter.string(from: date)
		}
	}
	
	static func formatLongDate(_ hourFormat: Int, date: Date ) -> String
	{
		let dateFormatter = DateFormatter()
		
		dateFormatter.locale = Locale.current
		
		dateFormatter.dateStyle = .long
			return dateFormatter.string(from: date)
		
	}
}
