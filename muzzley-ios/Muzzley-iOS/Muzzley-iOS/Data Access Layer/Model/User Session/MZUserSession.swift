//
//  MZSession.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 10/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift

class MZUserSession: NSObject
{
	
	enum MZSessionState
	{
		case mzSessionStateCreated
		case mzSessionStateOpen
		case mzSessionStateClosed
	}
	
	var state : MZSessionState
	
	var isOpen : Bool
		
	var userProfile : MZUserProfile
	
	var unitsSpec : MZUnitsSpec
	
	var currencySpec : MZCurrencySpec

	override init()
	{
		isOpen = false
		state = MZSessionState.mzSessionStateClosed
		userProfile = MZUserProfile()
		unitsSpec = MZUnitsSpec()
		currencySpec = MZCurrencySpec()
		MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)

	}
}
