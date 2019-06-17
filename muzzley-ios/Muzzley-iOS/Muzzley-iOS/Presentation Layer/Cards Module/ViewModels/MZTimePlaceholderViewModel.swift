//
//  MZPlaceholderViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZTimePlaceholderViewModel: NSObject {
    
    var timeServer: String = ""
    var timeUI: String = ""
    var timeDate:Date = Date()
    var weekDays: Array<Bool> = Array()
    var datePickerOpened: Bool = false
    var is24H: Bool = false
    
    var dateFormatter : DateFormatter = DateFormatter()

    func setupTime(_ time:String)
    {
        if !time.isEmpty {
            self.dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            self.dateFormatter.dateFormat = "HH:mm:ss.SSS"
			self.timeDate = self.dateFormatter.date(from: time)!
            self.setupDate(self.timeDate)
        }
    }
    
    func setupDate(_ date:Date)
    {
        self.timeDate = date
        
        self.dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "HH:mm:ss.SSS"
		self.timeServer = self.dateFormatter.string(from: self.timeDate)
        
        self.dateFormatter.timeZone = TimeZone.current
		if(MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat == 24)
		{
			self.dateFormatter.locale = Locale.init(identifier:"pt_PT")
		}
		else
		{
			self.dateFormatter.locale = Locale.init(identifier:"en_US")
		}
		
		self.dateFormatter.timeStyle = .short
		var string: NSString = self.dateFormatter.string(from: self.timeDate) as NSString
        string = string.replacingOccurrences(of: ":", with: " : ") as NSString
        self.timeUI = string as String
        
//        let amRange = (string.rangeOfString(self.dateFormatter.AMSymbol))
//        let pmRange = (string.rangeOfString(self.dateFormatter.PMSymbol))
//        self.is24H = amRange.location == NSNotFound && pmRange.location == NSNotFound
		
		if(MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat == 12)
		{
			self.is24H = false
		}
		else
		{
			self.is24H = true
		}
	}
    
}
