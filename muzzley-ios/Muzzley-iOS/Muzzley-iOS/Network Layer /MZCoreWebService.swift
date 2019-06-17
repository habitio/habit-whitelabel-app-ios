//
//  MZPublishWebService.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 24/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import AFNetworking

class MZCoreWebService: MZBaseWebService
{
    static let key_profile      = "profileId"
    static let key_channel      = "channelId"
    static let key_component    = "componentId"
    static let key_property     = "propertyId"

	fileprivate var coreHttpUrl = ""
	
	class var sharedInstance : MZCoreWebService {
		struct Singleton {
			static let instance = MZCoreWebService()
		}
		return Singleton.instance
	}
	

    override init()
    {
		super.init()
		self.coreHttpUrl = MZEndpoints.apiHost()
	}
    
    func publish(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void) {
        if MZSession.sharedInstance.authInfo == nil
        {
            return
        }
        
        self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
		let channel = parameters[MZCoreWebService.key_channel]! as! String
		let component = parameters[MZCoreWebService.key_component]! as! String
		let property = parameters[MZCoreWebService.key_property]! as! String
		
        let path = coreHttpUrl + "/v3/channels/" + channel + "/components/" + component + "/properties/" + property + "/value"
		var data = ["data" : parameters["params"]!]
        
		self.httpPut(path, parameters: data as! AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
					completion(nil, err)
			}
		}
    }
}

