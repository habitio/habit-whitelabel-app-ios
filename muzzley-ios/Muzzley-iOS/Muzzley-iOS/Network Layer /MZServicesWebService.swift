//
//  MZServiceWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 06/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import RxSwift


class MZServicesWebService: MZBaseWebService
{
	let use_mock = false
	let use_bundles_mock = false
	var profileId = ""
    let key_location = "Location"
    let key_custom_headers = "CustomHeaders"

	
	class var sharedInstance : MZServicesWebService {
		struct Singleton {
			static let instance = MZServicesWebService()
		}
		return Singleton.instance
	}

	// Service Subscriptions
	func getServiceSubscriptionsObservable(_ userId: String) -> Observable<(AnyObject)>
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		return Observable.create({ (observer) -> Disposable in
			
			var path = MZEndpoints.ServiceSubscriptions(userId)
			
//			if(self.use_mock)
//			{
//				path = "https://jsonblob.com/api/jsonblob/d620111a-1b87-11e7-a0ba-01bbe318a358"
//			}
			
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! NSDictionary)
				observer.onCompleted()
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
	
	
	// Add Service
	func getAllServicesObservable() -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			var path = MZEndpoints.Services()
			
            if(self.use_bundles_mock)
            {
				path = ""
            }
            
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! NSDictionary)
				observer.onCompleted()
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
    
	
	func getProfileByIdObservable(_ profileId: String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in

			let path = MZEndpoints.Profiles()

			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				if(responseObj != nil && responseObj is NSDictionary)
				{
					let profiles = (responseObj as! NSDictionary).value(forKey: "profiles") as! NSArray
					for profile in profiles
					{
						if((profile as! NSDictionary).value(forKey: "id") as! String == profileId)
						{
							observer.onNext(profile as AnyObject)
							observer.onCompleted()
							return
						}
					}
				}
				observer.onError(NSError(domain: "", code: 0, userInfo: nil))
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
    
    func getChannelTemplateByIdObservable(_ channelTemplateId: String) -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            let path = MZEndpoints.ChannelTemplatesById(MZSession.sharedInstance.authInfo!.userId, channelTemplateId: channelTemplateId)
            
            self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
                
                if(responseObj != nil && responseObj is NSDictionary)
                {
                    if let elements = (responseObj as! NSDictionary).value(forKey: "elements") as? NSArray
                    {
                        for element in elements
                        {
                            if let template = (element as! NSDictionary).value(forKey: "template")
                            {
                                if (template as! NSDictionary).value(forKey: MZChannelTemplate.key_id) as! String == channelTemplateId
                                {
                                    observer.onNext(element as AnyObject)
                                    observer.onCompleted()
                                    return
                                }
                            }
                        }
                    }
                }
                observer.onError(NSError(domain: "", code: 0, userInfo: nil))
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
	
	func getServiceAuthorizationUrlObservable(_ serviceId: String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in

			let path = MZEndpoints.ServiceAuthorization(serviceId)
			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! NSDictionary)
				observer.onCompleted()
			}, failure: { (sessionManager, error) in
			    if let err = error as? NSError
                {
                    let allHeaderFields : NSDictionary = (sessionManager?.currentRequest as! URLRequest).allHTTPHeaderFields as! NSDictionary
                    let locationHeaderString : String? = allHeaderFields.value(forKey: self.key_location) as? String
                    let customHeadersString : String? = allHeaderFields.value(forKey: self.key_custom_headers) as? String
                    
                    var newError : NSError
                    if(locationHeaderString != nil && !locationHeaderString!.isEmpty)
                    {
                        if(customHeadersString != nil && !customHeadersString!.isEmpty)
                        {
                            newError = NSError(domain: "HTTPDomain", code: 303, userInfo: [self.key_location : locationHeaderString, self.key_custom_headers: customHeadersString])
                        }
                        else
                        {
                            newError = NSError(domain: "HTTPDomain", code: 303, userInfo: [self.key_location : locationHeaderString])
                        }
                        
                        observer.onError(newError)
                        return
                    }
                    
                    observer.onError(err)
                }
			})
			
			self.sessionManager.setTaskWillPerformHTTPRedirectionBlock({ (session, task, response, request) -> URLRequest in                
                if(response == nil)
                {
                    return request
                }
                
                let allHeaderFields : NSDictionary = (response as! HTTPURLResponse).allHeaderFields as NSDictionary
                let locationHeaderString : String? = allHeaderFields.value(forKey: self.key_location) as? String
                
                if(locationHeaderString != nil && !locationHeaderString!.isEmpty)
                {
                    var customHeaders = NSMutableDictionary()
                    let headerPrefix = "X-Webview-"
                    for header in allHeaderFields.allKeys
                    {
                        if((header as! String).contains(headerPrefix))
                        {
                            let subHeader = (header as! String).substring(from: headerPrefix.endIndex)
                            customHeaders.setObject(allHeaderFields[header], forKey: subHeader as NSCopying)
                        }
                    }
                    
                    var newRequest = request
                    
                    newRequest.addValue(locationHeaderString!, forHTTPHeaderField: self.key_location)
                    
                    if(customHeaders != nil && customHeaders.allKeys.count > 0)
                    {
                        newRequest.addValue(MZJsonHelper.JSONStringify(customHeaders), forHTTPHeaderField: self.key_custom_headers)
                    }
                    
                    task.cancel()
                    return newRequest
                }
                
                return request
			})
			return Disposables.create{}

		})
	}
	
	

	
	func getChannelsSubscriptionsByProfileObservable(_ profileId: String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			let path = MZEndpoints.ProfileChannels(profileId)			
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! AnyObject)
				observer.onCompleted()
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
	
	// TODO: Check this
	
	func getChannelsFilteredByProfileObservable(_ userId: String, profileId: String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			let path = MZEndpoints.ChannelsByProfile(userId, profileId: profileId)
			
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
				observer.onNext(responseObj as! AnyObject)
				observer.onCompleted()
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
	
	func subscribeToService(_ serviceId: String, payload : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
	{
		let path = String(format: MZEndpoints.ServiceSubscribe(serviceId))
    
		self.sessionManager.requestSerializer.setValue("OAuth2.0 " + MZSession.sharedInstance.authInfo!.accessToken, forHTTPHeaderField: "Authorization")
		self.sessionManager.requestSerializer.setValue("true", forHTTPHeaderField: "X-No-Redirection")
		
		self.httpPost(path, parameters: payload, success: { (sessionManager, responseObj) in
			self.sessionManager.requestSerializer.setValue("false", forHTTPHeaderField: "X-No-Redirection")
			completion(responseObj as AnyObject, nil)
		}, failure: { (sessionManager, error) in
			self.sessionManager.requestSerializer.setValue("false", forHTTPHeaderField: "X-No-Redirection")
			completion(nil, error as! NSError)
		})
	}
	
}
