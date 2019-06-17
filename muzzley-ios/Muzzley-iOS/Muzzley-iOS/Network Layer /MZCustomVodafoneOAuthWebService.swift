//
//  MZCustomOAuthWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/06/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
import RxSwift
//import RxCocoa

class MZCustomVodafoneOAuthWebService : MZBaseWebService
{
	
	func getAccessToken(_ code: String, completion: @escaping (_ accessToken: String?, _ error: NSError?) -> Void)
	{
		
		let path = MZEndpoints.VodafoneOAuthAccessToken(code: code)
		
		self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
			if(responseObj != nil)
			{
				let accessToken : String? = (responseObj as! NSDictionary).value(forKey: "access_token") as? String
				completion(accessToken, nil)
			}
			else
			{
				completion(nil, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
			}
		}, failure: { (sessionManager, error) in
			completion(nil, error as! NSError)
		})
	}

	func getUserInformation(_ accessToken: String, completion: @escaping (_ userInfo: NSDictionary?, _ error: NSError?) -> Void)	{
		

		let path = MZEndpoints.VodafoneOAuthUserInformation(accessToken: accessToken)
		
		self.httpGet(path, parameters: nil, success: { (sessionManager, responseObj) in
			if(responseObj != nil)
			{
				completion(responseObj as! NSDictionary, nil)
			}
			else
			{
				completion(nil, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
			}
		}, failure: { (sessionManager, error) in
			completion(nil, error as! NSError)
		})
		
	}
	
}
