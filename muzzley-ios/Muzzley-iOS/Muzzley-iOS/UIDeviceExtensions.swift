//
//  UIDeviceExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 05/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension UIDevice
{
	public var SSID : String? {
	 get {
		#if arch(i386) || arch(x86_64)
			return ""
			
			#else
		if let interfaces = CNCopySupportedInterfaces() {
			for i in 0..<CFArrayGetCount(interfaces){
				let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
				let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
				let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
				
				if let unsafeInterfaceData = unsafeInterfaceData as? Dictionary<AnyHashable, Any> {
					return unsafeInterfaceData["SSID"] as? String
				}
			}
		}
		return ""
		#endif
		}
		
	}
	
	
	public var BSSID : String?
	{
	 get {

		#if arch(i386) || arch(x86_64)
			return ""
			
		#else
			if let interfaces = CNCopySupportedInterfaces()
			{
				for i in 0..<CFArrayGetCount(interfaces){
					let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
					let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
					let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
					
					if let unsafeInterfaceData = unsafeInterfaceData as? Dictionary<AnyHashable, Any> {
						return unsafeInterfaceData["BSSID"] as? String
					}
				}
			}
			return ""
		#endif
	}
	}
}
