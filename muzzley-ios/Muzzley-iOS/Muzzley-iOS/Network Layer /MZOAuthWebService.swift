
//
//  MZOAuthWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZOAuthWebService: MZBaseWebService {

	class var sharedInstance : MZOAuthWebService {
		struct Singleton {
			static let instance = MZOAuthWebService()
		}
		return Singleton.instance
	}
	
	func signIn(clientId: String, username: String, password: String, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		self.httpGet(MZEndpoints.SignIn(clientId: clientId, username: username, password: password), parameters: nil, success: { (sessionDataTask, responseObject) in
			if(responseObject != nil && responseObject is NSDictionary)
			{
				MZSession.sharedInstance.authInfo = MZUserAuthInfo(dictionary: responseObject as! NSDictionary)
				MZLocalStorageHelper.saveAuthInfoToNSUserDefaults(responseObject as! NSDictionary)
			}
			completion(responseObject as? AnyObject, nil)
		}, failure: { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		})
	}
	
	func signUp(parameters: NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		self.httpPost(MZEndpoints.SignUp(), parameters: parameters, success: { (sessionDataTask, responseObject) in
			completion(responseObject as? AnyObject, nil)
		}, failure: { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		})
	}
	
    

	func resetPassword(email: String, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		var parameters = NSMutableDictionary()
		let appId = MZThemeManager.sharedInstance.appInfo.namespace
		parameters["email"] = email

		if(appId != nil)
		{
			parameters["appId"] = appId
		}
		
		self.httpPost(MZEndpoints.ResetPassword(), parameters: parameters as? NSDictionary, success: { (sessionManager, responseObject) in
			completion(responseObject as? AnyObject, nil)
		}, failure: { (sessionManager, error) in
			completion(nil, error as? NSError)
		})
	}
	
	func refreshToken(completion: @escaping (_ success: AnyObject?, _ error : NSError?) -> Void)
	{
		self.httpGet(MZEndpoints.RefreshToken(clientId: MZSession.sharedInstance.authInfo!.clientId, refreshToken: MZSession.sharedInstance.authInfo!.refreshToken), parameters: nil, success: { (sessionDataTask, responseObject) in
			if(responseObject != nil && responseObject is NSDictionary)
			{
				MZSession.sharedInstance.authInfo = MZUserAuthInfo(dictionary: responseObject as! NSDictionary)
				MZLocalStorageHelper.saveAuthInfoToNSUserDefaults(responseObject as! NSDictionary)
				completion(responseObject as? AnyObject, nil)
				return
			}
			
			completion(nil, NSError(domain: "", code: 0, userInfo: nil))
			
		}, failure: { (sessionManager, error) in
		
			if let err = error as? NSError
			{
//				dLog(message: err.localizedDescription)
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		})
	}
}
