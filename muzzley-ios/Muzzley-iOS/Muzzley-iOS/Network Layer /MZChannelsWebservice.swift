//
//  MZChannelsWebservice.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import RxSwift

class MZChannelsWebService: MZBaseWebService
{
	let key_location = "Location"
	let key_custom_headers = "CustomHeaders"
	let use_mock = false
    let use_mock_profiles = false
    let use_mock_channelTemplates = false

	class var sharedInstance : MZChannelsWebService {
		struct Singleton {
			static let instance = MZChannelsWebService()
		}
		return Singleton.instance
	}
	
	func getChannelsObservableForCurrentUser (_ parameters : NSDictionary?) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

			var path = MZEndpoints.Channels(MZSession.sharedInstance.authInfo!.userId) 

			if self.use_mock
			{
				// path = "https://jsonblob.com/api/jsonblob/bfdc01d4-2372-11e7-a0ba-0920dad8cd97";   //PROD
                // path = "https://jsonblob.com/api/jsonblob/373b6894-aa08-11e7-9754-37ecb5044b73"
                path = "https://api.myjson.com/bins/11ared"
			}
			
			self.httpGet(path, parameters: parameters as AnyObject, success: { (sessionManager, responseObject) in
				var responseObject = responseObject
				if responseObject == nil {
					responseObject = NSDictionary()
				}
				
				observer.onNext(responseObject as AnyObject)
				observer.onCompleted()
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
					if (err.code == NSURLErrorCancelled) { return; }
					observer.onError(err)
				}
			})
			
			return Disposables.create {}
		})
	}
	
	func getChannels(_ parameters : NSDictionary? , completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		var path = MZEndpoints.Channels(MZSession.sharedInstance.authInfo!.userId)
		
		if self.use_mock
		{
			//path = "https://jsonblob.com/api/jsonblob/bfdc01d4-2372-11e7-a0ba-0920dad8cd97";   //PROD
            //path = "https://jsonblob.com/api/jsonblob/373b6894-aa08-11e7-9754-37ecb5044b73"
            path = "https://api.myjson.com/bins/11ared"
		}
		
		self.httpGet(path, parameters: parameters as AnyObject, success: { (sessionManager, responseObject) in
			var responseObject = responseObject
			if responseObject == nil {
				responseObject = NSDictionary()
			}
			completion(responseObject as! AnyObject,  nil)
			
		}, failure: { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		})
	}
	
	func getAuthorizationWithProfileIdObservable (_ profileId : String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in

			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

			let path = MZEndpoints.ProfileAuthorization(profileId)
		
			let params = NSDictionary(dictionary: ["policy": "one"])
			
			self.httpGet(path, parameters: params, success: { (sessionDataTask, responseObject) in
				observer.onNext(responseObject as AnyObject)
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
			return Disposables.create {}
		}
	)}
	
	
	func getProfileAuthorization(_ profileId : String , completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
		let path = MZEndpoints.ProfileAuthorization(profileId)
		let params = NSDictionary(dictionary: ["policy": "one"])
		
		self.httpGet(path, parameters: params, success: { (sessionDataTask, responseObject) in
			if(responseObject == nil)
			{
				completion(NSArray(), nil)
			}
			else
			{
				completion(responseObject as AnyObject, nil)
			}
		},
			failure: { (sessionManager, error) in
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
						
						completion(nil, newError)
						return
					}
					
					completion(nil,err)
					
					
				}
		})
		
		self.sessionManager.setTaskWillPerformHTTPRedirectionBlock { (session, task, response, request) -> URLRequest in
			
			if(response == nil)
			{
				return request
			}

			let allHeaderFields : NSDictionary = (response as! HTTPURLResponse).allHeaderFields as NSDictionary
			let locationHeaderString : String? = allHeaderFields.value(forKey: self.key_location) as? String
            
            dLog("allHeaderFields \(allHeaderFields)")
            dLog("locationHeaderString \(locationHeaderString)")
			
			if(locationHeaderString != nil && !locationHeaderString!.isEmpty)
			{
				var customHeaders = NSMutableDictionary()
				let headerPrefix = "X-Webview-"
				for header in allHeaderFields.allKeys
				{
                    dLog("header \(header)")
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
		}
	}
	
	
	
	
	// Check if there aren't parameters missing

    func getChannelTemplates() -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
            
            var path = MZEndpoints.ChannelTemplatesByType(MZSession.sharedInstance.authInfo!.userId, type: "device")
            
            if self.use_mock_channelTemplates
            {
                path = "https://jsonblob.com/api/jsonblob/56222c30-ff61-11e7-84aa-bb43aa71028b";
            }
            
            self.httpGet(path, parameters: nil, success: { (sessionDataTask, responseObject) in
                print(responseObject)
                observer.onNext(responseObject as AnyObject)
                observer.onCompleted()
            }, failure: { (sessionManager, error) in
                if let err = error as? NSError
                {
                    if (err.code == NSURLErrorCancelled) { return; }
                    observer.onError(err)
                }
            })
            return Disposables.create {}
        })
    }
    
    
    // Check if there aren't parameters missing
    func getChannelTemplates(completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
        
        var path = MZEndpoints.ChannelTemplatesByType(MZSession.sharedInstance.authInfo!.userId, type: "device")
        
        if self.use_mock_channelTemplates
        {
            path = "https://jsonblob.com/api/jsonblob/56222c30-ff61-11e7-84aa-bb43aa71028b";
        }
        
        self.httpGet(path, parameters: nil, success: { (sessionManager, responseObject) in
            var responseObject = responseObject
            if responseObject == nil {
                responseObject = NSDictionary()
            }
            completion(responseObject as! AnyObject,  nil)
        }, failure: { (sessionManager, error) in
            if let err = error as? NSError
            {
                if (err.code == NSURLErrorCancelled) { return; }
                completion(nil, err)
            }
        })
    }
    
	func getProfiles() -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
			
			var path = MZEndpoints.Profiles()
			
            if self.use_mock_profiles
            {
                path = "https://jsonblob.com/api/jsonblob/afdbe124-acff-11e7-894a-5713e7789d07";
            }
            
			self.httpGet(path, parameters: nil, success: { (sessionDataTask, responseObject) in
				
				observer.onNext(responseObject as AnyObject)
				observer.onCompleted()
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
					if (err.code == NSURLErrorCancelled) { return; }
					observer.onError(err)
				}
			})
			return Disposables.create {}
		})
	}
	
	// Check if there aren't parameters missing
	func getProfiles(completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
		var path = MZEndpoints.Profiles()
        
        if self.use_mock_profiles
        {
            path = "https://jsonblob.com/api/jsonblob/afdbe124-acff-11e7-894a-5713e7789d07";
        }
        
		self.httpGet(path, parameters: nil, success: { (sessionManager, responseObject) in
			var responseObject = responseObject
			if responseObject == nil {
				responseObject = NSDictionary()
			}
			completion(responseObject as! AnyObject,  nil)
		}, failure: { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		})
	}
	
	
	
	func postChannelIds(channelsArray: [NSDictionary], profileId: String, completion: @escaping (_ result: [NSDictionary]?, _ error : NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		let path = MZEndpoints.Channels(MZSession.sharedInstance.authInfo!.userId)

		// Each channelId value inside the channelIds parameter must be copied to a new array
		// with the following structure:
		//
//         {
//         “profile”: “<profile_id>”,
//         “channels”: [
//                      {
//                         “id”: “<channel_id>”,
//        
//                      }
//                     ]
//          }
		
//		var channelsInfo = NSMutableDictionary(dictionary: ["channels" : channelsArray])
//		channelsInfo.addEntries(from: ["profile" : profileId])
//		
		var payload = NSMutableDictionary()
		var channelsToPost : NSMutableArray = NSMutableArray()
		for chan in channelsArray
		{
			channelsToPost.add(["id": chan["id"] as! String])
		}
		
		payload.addEntries(from: ["profile" : profileId])
		payload.addEntries(from: ["channels" : channelsToPost])

		self.httpPost(path, parameters: payload, success: { (sessionManager, responseObject) in
			
			var responseWithProfileId = NSMutableArray()
			if let array = responseObject as? NSArray
            {
                for res in array
                {
                    let chanWithProfileId : NSMutableDictionary = NSMutableDictionary(dictionary: res as! NSDictionary)
                    chanWithProfileId.addEntries(from: ["profileId": profileId])
                    responseWithProfileId.add(chanWithProfileId)
                }
                
                completion(responseWithProfileId as! [NSDictionary],  nil)
            }
			
			
		}, failure: { (sessionManager, error) in
			
			if((error as! NSError).code == NSURLErrorCancelled) { return }
			dLog("error \(error) for profileId \(profileId)")
			
			completion(nil, error as? NSError)
		})
	}
	

    
    func addChannelsObservable(profileId: String, channels : [NSDictionary]) -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            //TODO check why only setupBasicAuthorization does not work
            //self.HTTPClient.requestSerializer.setValue("OAuth2.0 " + MZSession.activeSession().userProfile.authToken, forHTTPHeaderField: "Authorization")
            self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
            
            var payload = NSMutableDictionary()
            var channelsToPost : NSMutableArray = NSMutableArray()

            for chan in channels
            {
                channelsToPost.add(["id": chan["id"] as! String])
            }
            
            payload.addEntries(from: ["profile" : profileId])
            payload.addEntries(from: ["channels" : channelsToPost])
            
            let path = MZEndpoints.Channels(MZSession.sharedInstance.authInfo!.userId)

            
            dLog("path \(path) payload \(payload)")
            
            self.httpPost(path, parameters: payload,
                          success: {(operation, responseObj) -> Void in
                            var responseWithProfileId = NSMutableArray()
                            let array = responseObj as! NSArray
                            for res in array
                            {
                                let chanWithProfileId : NSMutableDictionary = NSMutableDictionary(dictionary: res as! NSDictionary)
                                chanWithProfileId.addEntries(from: ["profileId": profileId])
                                responseWithProfileId.add(chanWithProfileId)
                            }
                            observer.onNext(responseWithProfileId)
                            observer.onCompleted()
            },
                          failure: { (operation, error) -> Void in
                            if((error as! NSError).code == NSURLErrorCancelled) { return }
                            dLog("error \(error) for profileId \(profileId)")
                            observer.onError(error!)
            })
            
            return Disposables.create()
        })
        
    }

	
}
