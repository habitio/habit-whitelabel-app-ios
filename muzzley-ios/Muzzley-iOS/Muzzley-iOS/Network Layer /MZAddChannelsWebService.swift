//
//  MZAddChannelsWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 03/07/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import RxSwift


class MZAddChannelsWebService: MZBaseWebService
{
//	var profileId = ""
	
	var addedChannels = NSDictionary()
	
	convenience override init()
	{
		self.init(baseURL: MUZZLEY_REST_API_BASE_URL)
	}
	
	func addChannelsObservable(profileId: String, channels : NSArray) -> Observable<(AnyObject)>
	{
         return Observable.create({ (observer) -> Disposable in
            
            //TODO check why only setupBasicAuthorization does not work
            self.HTTPClient.requestSerializer.setValue("OAuth2.0 " + MZSession.activeSession().userProfile.authToken, forHTTPHeaderField: "Authorization")
            
    //		self.profileId = profileId
            
            var payload = NSMutableDictionary()
            var channelsToPost : NSMutableArray = NSMutableArray()
            for chan in channels
            {
                channelsToPost.addObject(["id": chan["id"] as! String])
            }
            
            payload.addEntriesFromDictionary(["profile" : profileId])
            payload.addEntriesFromDictionary(["channels" : channelsToPost])

            let path = String(format: Endpoints.Channels.Channels, MZSession.activeSession().userProfile.identifier)
            
            dLog("path \(path) payload \(payload)")
            
            self.HTTPPost(path, parameters: payload,
                          success: {(operation, responseObj) -> Void in
                            var responseWithProfileId = NSMutableArray()
                            let array = responseObj as! NSArray
                            for res in array
                            {
                                let chanWithProfileId : NSMutableDictionary = NSMutableDictionary(dictionary: res as! NSDictionary)
                                chanWithProfileId.addEntriesFromDictionary(["profileId": profileId])
                                responseWithProfileId.addObject(chanWithProfileId)
                            }
                            observer.onNext(responseWithProfileId)
                            observer.onCompleted()
                            },
                          failure: { (operation, error) -> Void in
                            if(error.code == NSURLErrorCancelled) { return }
                            dLog("error \(error) for profileId \(profileId)")
                            observer.onError(error)
                            })
            
            return AnonymousDisposable{}
         })

	}

}
