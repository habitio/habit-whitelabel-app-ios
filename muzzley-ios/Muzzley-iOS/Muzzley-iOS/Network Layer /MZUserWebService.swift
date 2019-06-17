//
//  MZUserWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 10/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//


import RxSwift

class MZUserWebService : MZBaseWebService
{
	
	class var sharedInstance : MZUserWebService {
		struct Singleton {
			static let instance = MZUserWebService()
		}
		return Singleton.instance
	}
	
	let useMock : Bool = false
	
	func getUserContextChannelId(_ userId : String, completion: @escaping (_ contextChannelId: String?, _ error: NSError?) -> Void)
	{
		let path = MZEndpoints.Channels(MZSession.sharedInstance.authInfo!.userId)
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
		self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
			if(responseObj != nil)
			{
				if(responseObj is NSDictionary)
				{
					if let elements : NSArray =  (responseObj as! NSDictionary)["channels"] as? NSArray
					{
                        for element in elements
                        {
                            let chan = MZChannel(dictionary: element as! NSDictionary)
                            
                            if (chan.components.filter { $0.classes.contains("com.muzzley.components.user.geo")}).count > 0
                            {
                                for property in chan.properties
                                {
                                    if property.classes.contains("com.muzzley.properties.location") && property.classes.contains("com.muzzley.properties.location.context")
                                    {
                                        print(chan.identifier)
                                        completion(chan.identifier, nil)
                                        return
                                    }
                                }
                            }
                        }
                        completion(nil, NSError(domain: "", code: 0, userInfo: nil))
					}
				}
			}
			completion(nil, NSError(domain: "", code: 0, userInfo: nil))

		
		}, failure: { (sessionManager, error) in
			completion(nil, error as! NSError)

			
		})
	}
	
	func getNotificationTagsObservable(_ userId : String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

			let path = MZEndpoints.UserTags(userId)
			//let path = String(format: Endpoints.Users.UserTags, userId)

			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! NSDictionary)
                return
//                observer.onCompleted()
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
					if(err.code == NSURLErrorCancelled) { return }
					observer.onError(err)
				}

			})
			return Disposables.create{}
		})
	}
	
	
	func getUserObservable(_ userId : String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

			let path = MZEndpoints.User(userId)
			
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! AnyObject)
//                observer.onCompleted()
                return
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
					if(err.code == NSURLErrorCancelled) { return }
					observer.onError(err)
				}
			})
			
			return Disposables.create{}
		})
	}
	
	func getPlacesObservable(_ userId : String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

			let path = MZEndpoints.Places(userId)

			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! NSDictionary)
                return
//                observer.onCompleted()
				}, failure: { (sessionManager, error) in
					if let err = error as? NSError
					{
						if(err.code == NSURLErrorCancelled) { return }
						observer.onError(err)
					}
				}
			)
			
			return Disposables.create{}
		})
	}
	
	// Payload is already fully built at this point. Just post it
	func addPlaceObservable(_ userId: String, placePayload : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		let path = MZEndpoints.Places(userId)

		self.httpPost(path, parameters: placePayload, success: { (sessionManager, responseObj) in
			completion(responseObj as AnyObject, nil)
		}) { (sessionManager, error) in
			completion(nil, error as? NSError)
		}
	}
	
	func updatePlaceObservable(_ userId: String, placeId : String, placePayload : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		let path = MZEndpoints.Place(userId, placeId: placeId)
		
		self.httpPatch(path, parameters: placePayload, success: { (sessionManager, responseObj) in
			completion(responseObj as AnyObject, nil)
		}) { (sessionManager, error) in
			completion(nil, error as? NSError)
		}
		
	}
	
	func deletePlaceObservable(_ userId: String, placeId : String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		let path = MZEndpoints.Place(userId, placeId: placeId)
		
		self.httpDelete(path, parameters: nil, success: { (sessionManager, responseObj) in
			completion(responseObj as! NSDictionary, nil)
		}) { (sessionManager, error) in
			completion(nil, error as? NSError)
		}
	}
	
	func getUnitsTableObservable() -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			self.setupAuthorization()
			var unitsPath = ""
			let locale = MZSessionDataManager.sharedInstance.session.userProfile.preferences.locale.lowercased()
			if locale.hasSuffix("pt")
			{
				unitsPath = MZEndpoints.UnitsTablePT()
			}
			else
			{
				unitsPath = MZEndpoints.UnitsTableEN()
			}
			
			self.httpGet(unitsPath, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! AnyObject)
//                observer.onCompleted()
                return
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
					if(err.code == NSURLErrorCancelled) { return }
					
					observer.onError(err)
				}
			})
			return Disposables.create{}
		})
	}
	
	
	
	func getCurrenciesTableObservable() -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			self.setupAuthorization()

			let path = MZEndpoints.CurrenciesTable
			
			self.httpGet(path(), parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! AnyObject)
                return
//                observer.onCompleted()
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
					if(err.code == NSURLErrorCancelled) { return }
					
					observer.onError(err)
				}
			})
			
			return Disposables.create{}
		})
	}
	
	
	// Payload is already fully built at this point. Just post it
	func patchUser(_ userId: String, userPayload : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		let path = MZEndpoints.User(userId)

		self.httpPatch(path, parameters: userPayload, success: { (sessionManager, responseObj) in
			completion(responseObj as AnyObject, nil)
		}) { (sessionManager, error) in
			completion(nil, error as? NSError)
		}
		
	}
	
	
	func postFeedbackForUser(_ parameters : NSDictionary, completion: @escaping (_ result: Bool, _ error: NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
		let path = MZEndpoints.Feedback(MZSession.sharedInstance.authInfo!.userId)
		print(parameters)
		self.httpPost(path, parameters: parameters, success: { (sessionManager, responseObj) in
			completion(true, nil)
			
		}) { (sessionManager, error) in
			completion(false, error as? NSError)
		}
	}
}
	
