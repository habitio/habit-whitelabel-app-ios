//
//  MZUserDataManager.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 10/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift
import MessageUI
import CocoaLumberjack
import UserNotifications
import CoreLocation



let MZSessionDataManagerErrorDomain = ""

@objc class MZSessionDataManager : NSObject, UNUserNotificationCenterDelegate, MZEmitLocationInteractorDelegate
{
	var session: MZUserSession
	
	class var sharedInstance : MZSessionDataManager {
		struct Singleton {
			static let instance = MZSessionDataManager()
		}
		return Singleton.instance
	}
	
	override init()
	{
		session = MZUserSession()
        super.init()
        MZEmitLocationInteractor.sharedInstance.delegate = self
        
	}
	
	internal var lastNotificationTags = [String]()
	
	let key_user = "user"
	let key_preferences = "preferences"
	
	func getLastNotificationTags() -> [String]
	{
		return lastNotificationTags
	}
	
	func getUserProfileObservable() -> Observable<(Any)>
	{
       
		return Observable.create({ (observer) -> Disposable in
            if MZSession.sharedInstance.authInfo == nil
            {
                observer.onNext(false as AnyObject)
                observer.onCompleted()
            }
            else
            {
            
                let userId : String =  MZSession.sharedInstance.authInfo!.userId

                MZUserWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
                
                let observable = MZUserWebService.sharedInstance.getUserObservable(userId)
               
                observable.subscribe(
                    onNext: {(result) -> Void in
                        if(result is NSDictionary)
                        {
                            if let res = result as? NSDictionary
                            {
                                self.session.userProfile = MZUserProfile(dictionary: res)
                                self.session.userProfile.checkForChanges()
                                observer.onNext(true as AnyObject)
                                observer.onCompleted()
                            }
                        }
                        else
                        {
                            observer.onNext(false as AnyObject)
                            observer.onCompleted()
                        }
                },
                    onError: {(error) -> Void in
                        print("Error on User Profile: ")
                        print(error)
                        observer.onError(error)
                        observer.onCompleted()
                    }
                )
               
            }
             return Disposables.create()
            })

	}
	
	
	func getNotificationsTagsObservable() -> Observable<(Any)>
	{
		return Observable.create({ (observer) -> Disposable in
			
            if MZSession.sharedInstance.authInfo == nil
            {
                observer.onNext(false as AnyObject)
                observer.onCompleted()
                
            }
            else
            {
                let userId : String = MZSession.sharedInstance.authInfo!.userId

                MZUserWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
                
                let observable = MZUserWebService.sharedInstance.getNotificationTagsObservable(userId)
                observable.subscribe(
                    onNext: {(result) -> Void in
                            observer.onNext(result)
                            observer.onCompleted()
                    }, onError: { error in
                        print("Error on Notification Tags: ")
                        print(error)

                        observer.onError(error)
                    }, onCompleted: {})
                
            }
            return Disposables.create()
        })
	}
	
	
	// Updates the user in the API. Fields aren't mandatory so it is not necessary to send all the values
	func updateUser(_ updatedPayload : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		
		let userId : String = MZSession.sharedInstance.authInfo!.userId
		
		MZUserWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
		MZUserWebService.sharedInstance.patchUser(userId, userPayload: updatedPayload, completion: { (result, error) -> Void in
			if(error == nil)
			{
				if(result is NSDictionary)
				{
				
//					if let res = result as? NSDictionary
//					{
//						self.session.userProfile = MZUserProfile(dictionary: res)
//						
//						self.session.userProfile.checkForChanges()
						completion(true as AnyObject, nil)
//						
//						return
//					}
//					completion(result: false, error: error)
				}
			}
			else
			{
				completion(false as AnyObject, error)
			}
		})
	}
	
	func updateUnitsSystem(_ units : UnitsSystem,  completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		switch units
		{
		case UnitsSystem.metric:
			MZSessionDataManager.sharedInstance.session.userProfile.preferences.units = "metric"
			break
			
		case UnitsSystem.imperial:
			MZSessionDataManager.sharedInstance.session.userProfile.preferences.units = "imperial"
			break
			
		default:
			return
		}
		
		let payload : NSDictionary = ["preferences" : ["units" : MZSessionDataManager.sharedInstance.session.userProfile.preferences.units]]
		
		updateUser(payload, completion: { (result, error) -> Void in
			if(error == nil)
			{
				MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
				completion(true, nil)
			}
			else
			{
				// Change back
				switch units
				{
				case UnitsSystem.metric:
					MZSessionDataManager.sharedInstance.session.userProfile.preferences.units = "imperial"
					break
				case UnitsSystem.imperial:
					MZSessionDataManager.sharedInstance.session.userProfile.preferences.units = "metric"
					break
					
				default:
					return
				}
				
				completion(false, error)
				
			}
		})
		
	}
	
	
	func updateTimeFormat(_ hourFormat : Int,  completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		
		// Only update if it is different
		if(hourFormat != MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat)
		{
			let prevFormat = MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat
			
			MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat = hourFormat
			
			let payload : NSDictionary = ["preferences" : ["hourFormat" : MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat]]
		
			
			updateUser(payload, completion: { (result, error) -> Void in
				if(error == nil)
				{
					completion(true, nil)
				}
				else
				{
					
					MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat = prevFormat
					completion(false, error)
				}
			})
		}
	}
	
	

	func updateEmailNotifications(_ enabled : Bool,  completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		
		// Only update if it is different
		if(enabled != MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state)
		{
			let prev = MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state
			
			MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state = enabled
			
			let payload : NSDictionary = ["preferences" : ["notifications" : [ "email" : ["state" : MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state]]]]
						
			updateUser(payload, completion: { (result, error) -> Void in
				if(error == nil)
				{
					completion(true, nil)
				}
				else
				{
					
					MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.email.state = prev
					completion(false, error)
				}
			})
		}
	}
	
	func updateSmsNotifications(_ enabled : Bool,  completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		
		// Only update if it is different
		if(enabled != MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state)
		{
			let prev = MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state
			
			MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state = enabled
			
			let payload : NSDictionary = ["preferences" : ["notifications" : [ "sms" : ["state" : MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state]]]]
						
			updateUser(payload, completion: { (result, error) -> Void in
				if(error == nil)
				{
					completion(true, nil)
				}
				else
				{
					
					MZSessionDataManager.sharedInstance.session.userProfile.preferences.notifications.sms.state = prev
					completion(false, error)
				}
			})
		}
	}
	
	func  getUnitsTableObservable() -> Observable<(Any)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			let observable = MZUserWebService.sharedInstance.getUnitsTableObservable()
			observable.subscribe(onNext: {(result) -> Void in
				if(result is NSDictionary)
				{
					self.session.unitsSpec.setUnitsSpec(result as! NSDictionary)
					observer.onNext(true as AnyObject)
					observer.onCompleted()
				}
				else
				{
					//observer.onError()
				}
                }, onError: { error in
                    observer.onError(error)
                }, onCompleted: {})
			return Disposables.create()
		})
	}
	
	
	func getCurrencyTableObservable()  -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
		
		let observable = MZUserWebService.sharedInstance.getCurrenciesTableObservable()
			observable.subscribe(onNext: {(result) -> Void in
				if(result is NSDictionary)
				{
					self.session.currencySpec.setCurrencySpec(result as! NSDictionary)
					observer.onNext(true as AnyObject)
					observer.onCompleted()
				}
				else
				{
					//observer.onError()
				}
                }, onError: { error in
                    observer.onError(error)
                }, onCompleted: {})
		return Disposables.create()
	})
	}
    
    func locationPermissionsWereProvided(status: CLAuthorizationStatus) {        
        DispatchQueue.main.async {
            MZNeuraManager.initializeNeura()
            MZActivityInteractor.shared.queryForRecentActivityData()
        }
    }
	
	func getPlacesObservable() -> Observable<(Any)>
	{
        return Observable.create({ (observer) -> Disposable in
            if MZSession.sharedInstance.authInfo == nil
            {
                observer.onNext(false as AnyObject)
                observer.onCompleted()
            }
            else
            {
                 let userId : String = MZSession.sharedInstance.authInfo!.userId
                let observable =  MZUserWebService.sharedInstance.getPlacesObservable(userId)
                observable.subscribe(
                    onNext: {(result) -> Void in
                        if(result is NSDictionary)
                        {
                            if let res = result as? NSDictionary
                            {
                                let json = res["places"]! as! [NSDictionary]
                                
                                self.session.userProfile.places.removeAll()
                                for pl in json
                                {
                                    self.session.userProfile.places.append(MZPlace(json: pl as! [String : AnyObject]))
                                }

                                MZLocalStorageHelper.saveUserPlacesToNSUserDefaults((res["places"] as? [NSDictionary])!)

                                observer.onNext(true as AnyObject)
                                observer.onCompleted()
                            }
                        }
                        else
                        {
                            //observer.onError()
                        }
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: {})
                
                }
                return Disposables.create()
            })
	}
	
	func addPlace(_ placeToAdd : [String: Any], completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		let userId : String = MZSession.sharedInstance.authInfo!.userId
		
		MZUserWebService.sharedInstance.addPlaceObservable(userId, placePayload: placeToAdd as NSDictionary, completion: { (result, error) -> Void in
			if(error == nil)
			{
				self.getPlacesObservable().subscribe(
					onNext: {(result) -> Void in
							completion(result as AnyObject, nil)
						MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)

					}, onError: { error in
						completion(nil, (error as? NSError))
					}, onCompleted: {})
			}
			else
			{
				completion(false as AnyObject, error)
			}
		})
	}

	// Updates the user in the API. Fields aren't mandatory so it is not necessary to send all the values
	func updatePlace(_ placeId : String, updatedPlace : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		let userId : String = MZSession.sharedInstance.authInfo!.userId
		
		 MZUserWebService.sharedInstance.updatePlaceObservable(userId, placeId: placeId, placePayload: updatedPlace, completion: { (result, error) -> Void in
			if(error == nil)
			{
				self.getPlacesObservable().subscribe(
					onNext: {(result) -> Void in
						completion(result as AnyObject, nil)
						MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
						
					}, onError: { error in
						completion(nil, (error as? NSError))
						
					}, onCompleted: {})

				//				if(result is NSDictionary)
//				{
//					if let res = result as? NSDictionary
//					{
//						let place = MZPlace(json: res as! [String: AnyObject])
//						var toUpdate : Int = -1
//						for (index,element) in MZSessionDataManager.sharedInstance.session.userProfile.places.enumerate()
//						{
//							if( placeId == element.id)
//							{
//								toUpdate = index
//								break
//							}
//						}
//						
//						if(toUpdate > -1)
//						{
//							MZSessionDataManager.sharedInstance.session.userProfile.places[toUpdate] = place
//							//MZLocalStorageHelper.saveUserPlacesToNSUserDefaults(MZSessionDataManager.sharedInstance.session.userProfile.places.toDictionaryArray() as! [NSDictionary])
//						}
//						MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
//
//
//						completion(result: true, error: nil)
//						
//						return
//					}
//					completion(result: false, error: error)
//				}
			}
			else
			{
				completion(false as AnyObject, error)
			}
		})
	}
	
	func deletePlace(_ placeId : String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		let userId : String = MZSession.sharedInstance.authInfo!.userId
		
		
		 MZUserWebService.sharedInstance.deletePlaceObservable(userId, placeId: placeId, completion: { (result, error) -> Void in
			if(error == nil)
			{
				self.getPlacesObservable().subscribe(
					onNext: {(result) -> Void in
						completion(result as AnyObject, nil)
						MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
						
					}, onError: { error in
						completion(nil, (error as? NSError))
						
					}, onCompleted: {})
//				if(result is NSDictionary)
//				{
//					if let res = result as? NSDictionary
//					{
//						var toRemove : Int = -1
//						for (index,element) in MZSessionDataManager.sharedInstance.session.userProfile.places.enumerate()
//						{
//							if( placeId == element.id)
//							{
//								switch(element.id)
//								{
//									case "home", "work", "gym", "school":
//										element.address = ""
//										element.latitude = 0
//										element.longitude = 0
//										element.wifi = []
//										break
//									default:
//										toRemove = index
//										break
//								}
//								
//								break
//							}
//						}
//						
//						if(toRemove > -1)
//						{
//							MZSessionDataManager.sharedInstance.session.userProfile.places.removeAtIndex(toRemove)
//						//MZLocalStorageHelper.saveUserPlacesToNSUserDefaults(MZSessionDataManager.sharedInstance.session.userProfile.places.toDictionaryArray() as! [NSDictionary])
//						}
//						
//						// TODO: Don't remove special
//						MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
//
//						completion(result: true, error: nil)
//						
//						return
//					}
//					completion(result: false, error: error)
//				}
			}
			else
			{
				completion(false as AnyObject, error)
			}
		})
	}
	
	
	func getSessionInfo(_ completion: @escaping (_ result: Bool) -> Void)
	{
        
		var tasks : [Observable<Any>] = []
        
		tasks.append(MZSessionDataManager.sharedInstance.getUnitsTableObservable())
		tasks.append(MZSessionDataManager.sharedInstance.getUserProfileObservable())
		tasks.append(MZSessionDataManager.sharedInstance.getPlacesObservable())
        tasks.append(MZSessionDataManager.sharedInstance.getNotificationsTagsObservable())
        
		let storedLocationChannelId = MZLocalStorageHelper.loadLocationChannelIdFromNSUserDefaults()
		if(storedLocationChannelId.isEmpty)
		{
			let userwebservice = MZUserWebService()
			userwebservice.getUserContextChannelId(MZSession.sharedInstance.authInfo!.userId) { (contextChannelId, error) in
				if(contextChannelId != nil)
				{
					MZEmitLocationInteractor.sharedInstance.contextChannelId = contextChannelId!
                    MZContextManager.shared.contextChannelID = contextChannelId!
					MZLocalStorageHelper.saveLocationChannelIdToNSUserDefaults(contextChannelId!)
                    MZContextManager.shared.sendWifiInfo(unknownStart: true, completion: { (error) in
                    })
                    
				}
			}
		}
		else
		{
            MZContextManager.shared.contextChannelID = storedLocationChannelId
			MZEmitLocationInteractor.sharedInstance.contextChannelId = storedLocationChannelId
			MZLocalStorageHelper.saveLocationChannelIdToNSUserDefaults(storedLocationChannelId)
            MZContextManager.shared.sendWifiInfo(unknownStart: true, completion: { (error) in
            })
            
            
		}

		Observable<Any>.zip(tasks) {return $0}
			.retry(5).subscribe(onNext: { (results) in
				let results = results as! NSArray
                
				if(results[0] as? Bool == true && results[1] as? Bool == true && results[2] as? Bool == true)
				{
					MZNotifications.send(MZNotificationKeys.UserProfile.UnitsSystemUpdated, obj: nil)
					MZNotifications.send(MZNotificationKeys.UserProfile.HourFormatUpdated, obj: nil)
					MZNotifications.send(MZNotificationKeys.UserProfile.SettingsUpdated, obj: nil)
                    
                    self.handlePermissions(tagsObject: results[3] as? NSDictionary)
                    completion(true)
                    return
				}
				else
				{
					completion(false)
                    return
				}
                
            }, onError: { (error) in
			Log.error("GetSession ERROR", saveInDebugLog: true)
			completion(false)
            return
		}, onCompleted: {
            return
            
            }, onDisposed: {}
		)
	}
    
    func handlePermissions(tagsObject : NSDictionary?)
    {
        if tagsObject != nil && tagsObject is NSDictionary
        {
            let tags = tagsObject!.object(forKey: "tags") as? [String]
            if !(tags?.isEmpty)!
            {
                
                // This asynchronous request needs to run before activateRemoteNotificationsService.
                /*  if(self.lastNotificationTags.count > 0)
                 {
                 AppManager.shared().deactivateRemoteNotificationsService()
                 }
                 */
                
                self.lastNotificationTags = tags!
                let notificationsInUserDefaults = MZLocalStorageHelper.loadPushNotificationsStatusFromNSUserDefaults()
                if notificationsInUserDefaults
                {
                    if #available(iOS 10.0, *) {
                        UNUserNotificationCenter.current()
                            .requestAuthorization(options: [.alert, .sound, .badge]) {
                                granted, error in
                                    AppManager.shared().activateRemoteNotificationsService(withTags: tags)
                                    DispatchQueue.main.async {
                                        MZEmitLocationInteractor.sharedInstance.startMonitoringLocation()
                                    }
                        }
                    }
                    else
                    {
                        // Fallback on earlier versions
                        AppManager.shared().activateRemoteNotificationsService(withTags: tags)
                        DispatchQueue.main.async {
                            MZEmitLocationInteractor.sharedInstance.startMonitoringLocation()
                        }
                    }
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                MZEmitLocationInteractor.sharedInstance.startMonitoringLocation()
            }
        }
    }
	
	func logout()
	{
		MZSession.sharedInstance.closeAndClear()
		MZEmitLocationInteractor.sharedInstance.setGeofences(nil)
	}
}
