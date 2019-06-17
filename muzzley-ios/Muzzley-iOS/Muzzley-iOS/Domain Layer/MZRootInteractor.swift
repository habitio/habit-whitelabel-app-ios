//
//  MZRootInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 18/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import NotificationBannerSwift


class MZRootInteractor: NSObject
{
	var remoteNotification : NSDictionary?
	
	override init()
	{
		super.init();
		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRemoteNotification), name: NSNotification.Name.AppManagerDidReceiveRemote, object: nil)
		
//		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRemoteNotification), name: NSNotification.Name.AppManagerDidReceiveRemote, object: nil)
	}
	
	
	func didReceiveRemoteNotification(notification: Notification)
	{
        
		let leftView = UIImageView(image: (UIImage(named: "icon_alert_white")! as UIImage))
		
		//DLog("Did receive remote notification: %@", notification.object);
		if(notification.object != nil)
		{
			let notificationObject = notification.object as! NSDictionary
			if notificationObject.value(forKey: "aps") != nil
			{
				// Ignoring Neura events for now
                let data = notificationObject.value(forKey: "data") as? NSDictionary
                if data != nil
                {
                    let pushType = data!["pushType"] as? String
                    if pushType == "neura_event"
                    {
                        // Ignore
                        return
                    }
                }
                
                let aps = notificationObject.value(forKey: "aps") as? NSDictionary
                
				if(aps != nil)
				{
					let alert = aps!.value(forKey: "alert") as? NSDictionary
				
					if(alert != nil)
					{
						if(alert is NSDictionary)
						{
							var body = alert!.value(forKey: "body") as? String
							if(body == nil)
							{
								body = ""
							}
							var title = alert!.value(forKey: "title") as? String
							if(title == nil)
							{
								title = ""
							}
					
							if(body!.isEmpty && title!.isEmpty)
							{
								return
							}
							
							let banner = NotificationBanner(title: title!, subtitle: body!, leftView: leftView, style: .danger, colors: MZNotificationsBannerColors() as! BannerColorsProtocol)
							
                            banner.onTap = {
                            }
                            if screenHasTopNotch
                            {
                                banner.bannerHeight = banner.bannerHeight + 40
                            }
                            
							banner.subtitleLabel?.font = UIFont.regularFontOfSize(14)
							banner.titleLabel?.font = UIFont.boldFontOfSize(17)
							banner.show()
						}
						else if(alert is String)
						{
							
							let banner = NotificationBanner(title: "", subtitle: alert! as! String, leftView: leftView, style: .danger, colors: MZNotificationsBannerColors() as! BannerColorsProtocol)
							
                            banner.onTap = {
                                
                            }
                            if screenHasTopNotch
                            {
                                banner.bannerHeight = banner.bannerHeight + 40
                            }
							banner.subtitleLabel?.font = UIFont.regularFontOfSize(14)
							banner.titleLabel?.font = UIFont.boldFontOfSize(17)
							banner.show()
						}
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllTabs"), object: nil)

					}
				}
			}
		}
	}
	
    var screenHasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        
        return false
    }
	
	func  stopLocation()
	{
		MZEmitLocationInteractor.sharedInstance.stopMonitoringLocation()
	}
	
	func deactivateRemoteNotificationsService()
	{
		AppManager.shared().deactivateRemoteNotificationsService()
	}
	

}
