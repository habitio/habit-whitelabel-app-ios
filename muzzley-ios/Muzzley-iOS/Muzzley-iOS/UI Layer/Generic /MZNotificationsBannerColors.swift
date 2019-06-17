//
//  MZNotificationsBannerColors.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 07/08/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
import NotificationBannerSwift

//
//public protocol BannerColorsProtocol {
//	func color(for style: BannerStyle) -> UIColor
//}

class MZNotificationsBannerColors: BannerColorsProtocol {
	
	internal func color(for style: BannerStyle) -> UIColor {
		switch style {
		case .danger:
			return UIColor.init(hex: "#FF5441")
		case .info:
			return UIColor.muzzleyBlueColor(withAlpha: 1)
		case .none:     // Your custom .none color
			return UIColor.muzzleyBlueColor(withAlpha: 1)
		case .success:  // Your custom .success color
			return UIColor.muzzleyBlueColor(withAlpha: 1)
		case .warning:  // Your custom .warning color
			return UIColor.muzzleyYellowColor(withAlpha: 1)
		}
	}
}

