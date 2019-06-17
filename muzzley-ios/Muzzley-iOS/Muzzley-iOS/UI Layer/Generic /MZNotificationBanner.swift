//
//  MZNotificationBanner.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 18/12/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation
import NotificationBannerSwift
class MZNotificationBanner
{
    static func showDebugBanner(title: String, subtitle : String)
    {
        if MZSession.sharedInstance.authInfo?.userId == "59cf7f26-b33a-11e7-bf6b-066268605eec" ||  MZSession.sharedInstance.authInfo?.userId == "a9a0f014-8a8c-11e8-b9b5-000d3a2c0f58"
        {
            let banner = NotificationBanner(title: title, subtitle: subtitle, leftView: nil, style: .none, colors: MZNotificationsBannerColors() as! BannerColorsProtocol)
            
            banner.onTap = {
            }
            
            banner.subtitleLabel?.font = UIFont.regularFontOfSize(14)
            banner.titleLabel?.font = UIFont.boldFontOfSize(17)
            banner.show()
        }

    }
    
}
