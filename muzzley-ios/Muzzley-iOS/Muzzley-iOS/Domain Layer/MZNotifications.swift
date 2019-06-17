//
//  MZNotifications.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 01/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
class MZNotifications : NSObject
{
	static func send(_ notificationKey: String, obj: AnyObject?)
	{
		NotificationCenter.default.post(name: Notification.Name(rawValue: notificationKey), object: obj)
	}
	
	static func register(_ observer: AnyObject, selector: Selector, notificationKey: String)
	{
		NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: notificationKey), object: nil)
	}
	
	static func unregister(_ observer: AnyObject, notificationKey: String)
	{
		NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: notificationKey), object: nil)
	}
}
