//
//  MZUserProfile.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 10/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift

class MZUserProfile 
{
	let key_id = "id"
	let key_name = "name"
	let key_email = "email"
	let key_photoUrl = "photo"
	let key_preferences = "preferences"

	var id : String = ""
	var name : String = ""
	var email : String = ""
	var photoUrl : String = ""
	var phoneNumbers : [MZPhoneNumber] = [MZPhoneNumber]()
	
	
	var preferences : MZUserPreferences = MZUserPreferences()
	
	var places : [MZPlace] =  [MZPlace]()
	
	var dictionaryRepresentation = NSDictionary()
	
	func getPreferencesAsDictionary() -> NSDictionary
	{
		return preferences.dictionaryRepresentation
	}
	
	required init()
	{
		self.id = ""
		self.name = ""
		self.email = ""
		self.photoUrl  = ""
		self.preferences = MZLocalStorageHelper.loadUserPreferencesFromNSUserDefaults()
		self.places = MZLocalStorageHelper.loadUserPlacesFromNSUserDefaults()
	}
	
	init(dictionary : NSDictionary)
	{

		self.dictionaryRepresentation = dictionary
		
		if let _id = dictionary[self.key_id] as? String {
			self.id = _id
		}
		if let _name = dictionary[self.key_name] as? String {
			self.name = _name
		}
		if let _email = dictionary[self.key_email] as? String {
			self.email = _email
		}
		if let _photoUrl = dictionary[self.key_photoUrl] as? String {
			self.photoUrl = _photoUrl
		}
		
		if let _preferences = dictionary[self.key_preferences] as? NSDictionary {
			self.preferences = MZUserPreferences(dictionary: _preferences)
		}

		self.places = MZLocalStorageHelper.loadUserPlacesFromNSUserDefaults()

	}
	
	
	
	func checkForChanges()
	{
		let requiresUpdate = preferences.checkForChanges()
		if(requiresUpdate)
		{
			let dictionary = NSDictionary(object: self.preferences.dictionaryRepresentation, forKey: "preferences" as NSCopying)
            //TODO commented just to test without the loop
			MZSessionDataManager.sharedInstance.updateUser(dictionary, completion: { (result, error) in
			})
		}
		else
		{
			MZLocalStorageHelper.saveUserPreferencesToNSUserDefaults(self.preferences.dictionaryRepresentation)
			var tasks : [Observable<Any>] = []
			tasks.append(MZSessionDataManager.sharedInstance.getPlacesObservable())
			//let zipObservable: Observable<NSArray> = tasks.zip { return $0 }
			Observable<Any>.zip(tasks) {return $0}

				.subscribe(onNext: { (results) in
				if((results as! NSArray)[0] as? Bool == true)
				{
					MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
				}
				}, onError: { (error) in
		
				}, onCompleted: {},
				onDisposed: {}
			)
//			zipObservable.subscribeNext({
//				results in
//				if(results[0] as? Bool == true)
//				{
//					MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
//				}
//				else
//				{
//					//completion(result:false)
//				}
//			})
		}
	}
	

}
