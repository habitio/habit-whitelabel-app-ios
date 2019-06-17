//
//  MZDeviceInfoHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 20/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import CoreTelephony.CTCarrier
import CoreTelephony.CTTelephonyNetworkInfo
import SystemConfiguration.CaptiveNetwork
import CoreLocation


@objc class MZDeviceInfoHelper : NSObject
{
	static func getLocale() -> String
	{
		return Locale.current.identifier
	}

	static func getTimeZone() -> String
	{
		 return TimeZone.autoupdatingCurrent.identifier 
	}

	static func getCurrencyCode() -> String
	{
		return Locale.current.currencyCode!
	}

	static func getCurrencySymbol() -> String
	{
		return Locale.current.currencySymbol!
	}
    
	static func getDeviceLanguage() -> String
	{
		let lan = Locale.preferredLanguages[0]
		if lan.contains("-")
		{
			var split = lan.components(separatedBy: "-")
			if(split.count > 0)
			{
				return split[0]
			}
			
			//return lan.stringByReplacingOccurrencesOfString("-", withString: "_")
		}
		return lan
	}
	
	static func getHourFormat() -> Int
	{
		let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
		
		if dateFormat.range(of: "a") != nil {
			return 12
		}
		return 24
	}

	static func getLocaleUnitsSystem() -> String
	{
		if(Locale.current.usesMetricSystem as! Bool)
		{
			return "metric"
		}
		return "imperial"
	}
	
	/// May return nil if there's no card, is in airplane mode or there's no network
	static func getCarrierName() -> String?
	{
		#if arch(i386) || arch(x86_64)
			return ""
		#else
			let networkInfo = CTTelephonyNetworkInfo()
			
			let carrier : CTCarrier = networkInfo.subscriberCellularProvider!
			return carrier.carrierName as String?
		#endif
	
	}

    
    static func getUserAgent() -> String?
    {
        do
        {
         
            let executableName = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
            let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let build =  Bundle.main.infoDictionary?["CFBundleVersion"] as! String
            let model = UIDevice.current.model
            let systemVersion = UIDevice.current.systemVersion
            let name = UIDevice.current.name
            let systemName = UIDevice.current.systemName
            
            let userAgent = bundleID + "/" + version + "." + build + " (" + model + "/" + systemName + " " + systemVersion + ")"
            print(userAgent)
            return userAgent
        }
        catch
        {
            return nil
        }
        
//        [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    }
	static func getVendorId() -> String?
	{
		#if (TARGET_OS_SIMULATOR)
			return "unknown"
		#else
        
			return UIDevice.current.identifierForVendor?.uuidString
		#endif
	}
	
	static func getWifiSSID() -> String?
	{
		#if arch(i386) || arch(x86_64)
			return ""
		#else
			return UIDevice.current.SSID
		#endif
	}
	
	static func getWifiBSSID() -> String?
	{
		#if arch(i386) || arch(x86_64)
			return ""
		#else
			return UIDevice.current.BSSID
		#endif
	}
	
	static func getBroadcastAddress() -> String?
    {
//        return  SSNetworkInfo.wiFiBroadcastAddress
        return nil
    }
    
	static func getAppVersion() -> String
	{
        if(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) != nil
        {
            return (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) + "." + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
        }
        else
        {
            return ""
        }
    }
	
    static func areNotificationsEnabled() -> Bool
	{
		let notificationType  = UIApplication.shared.currentUserNotificationSettings?.types
		if notificationType == []
		{
			return false
		}
		else
		{
			return true
		}
	}

	static func areLocationServicesEnabled() -> Bool
	{
        
		if CLLocationManager.locationServicesEnabled() {
			switch(CLLocationManager.authorizationStatus()) {
			case .notDetermined, .authorizedWhenInUse, .restricted, .denied:
				return false
			case .authorizedAlways:
				return true
			}
		} else {
			return false

		}
    }
}
