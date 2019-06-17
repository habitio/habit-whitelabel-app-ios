//
//  MZClientVersionWebService.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 13/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

class MZClientVersionWebService : MZBaseWebService
{
    static let key_version    = "version"

	
	class var sharedInstance : MZClientVersionWebService {
		struct Singleton {
			static let instance = MZClientVersionWebService()
		}
		return Singleton.instance
	}
	
	
    func getVersionSupport (_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {

        let path = MZEndpoints.AppVersion(parameters[MZClientVersionWebService.key_version]! as! String)
	
		self.httpGet(path, parameters: nil, success: { (sessionManager, responseObject) in
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
