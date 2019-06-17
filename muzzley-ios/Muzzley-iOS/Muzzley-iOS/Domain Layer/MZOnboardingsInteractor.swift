//
//  MZOnboardingsInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 29/12/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

//       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCreatedGroup"];

//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCreatedTile"];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"canCreateGroup"];
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasDevicesLaunched"])
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"didShowMoreShortcuts"]) {



import Foundation

class MZOnboardingsInteractor : NSObject
{
	internal let key_createGroup = "canCreateGroup"
	let key_groupCreated = "hasCreatedGroup"
	let key_shortcuts = "didShowMoreShortcuts"
	let key_tileAdded = "hasCreatedTile"
	let key_tileAddedCreateGroup = "tileAddedCreateGroup"
	let key_createWorker = "createWorker"
	let key_workerCreated = "hasCreatedAgent"
	let key_devices = "hasDevicesLaunched"
	let key_cards = "hasCardsLaunched"
	
	class var sharedInstance : MZOnboardingsInteractor {
		struct Singleton {
			static let instance = MZOnboardingsInteractor()
		}
		return Singleton.instance
	}

	func hasOnboardingBeenShown(_ onBoardingName: String) -> Bool
	{
		return UserDefaults.standard.bool(forKey: onBoardingName)
	}
	
	func updateOnboardingStatus(_ onBoardingKey: String, shownStatus : Bool)
	{
		UserDefaults.standard.set(shownStatus, forKey: onBoardingKey)
		UserDefaults.standard.synchronize()
	}
	
	func resetOnboarding(_ onboardingKey: String)
	{
		UserDefaults.standard.set(false, forKey: onboardingKey)
		UserDefaults.standard.synchronize()
	}
	
	func resetAllOnboardings()
	{
		UserDefaults.standard.set(false, forKey: key_createGroup)
		UserDefaults.standard.set(false, forKey: key_groupCreated)
		UserDefaults.standard.set(false, forKey: key_tileAdded)
		UserDefaults.standard.set(false, forKey: key_tileAddedCreateGroup)
		UserDefaults.standard.set(false, forKey: key_createWorker)
		UserDefaults.standard.set(false, forKey:key_workerCreated)
		UserDefaults.standard.set(false, forKey:key_devices)
		UserDefaults.standard.set(false, forKey:key_cards)
		UserDefaults.standard.set(false, forKey:key_shortcuts)
		UserDefaults.standard.synchronize()

	}
}
