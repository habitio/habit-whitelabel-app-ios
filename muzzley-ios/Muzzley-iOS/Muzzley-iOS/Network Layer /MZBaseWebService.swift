//
//  MZBaseWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import AFNetworking

@objc class MZBaseWebService : NSObject
{
	var sessionManager : AFHTTPSessionManager
	
	override init()
	{
		self.sessionManager = AFHTTPSessionManager()
		self.sessionManager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
		self.sessionManager.requestSerializer = AFJSONRequestSerializer()
		self.sessionManager.responseSerializer = AFJSONResponseSerializer()
		super.init()
	}
	
	func setupAuthorization()
	{
		self.sessionManager.requestSerializer.clearAuthorizationHeader()
	}
	
	
	func setupAuthorization(accessToken: String)
	{
		self.sessionManager.requestSerializer.clearAuthorizationHeader()
		self.sessionManager.requestSerializer.setValue(String.init(format: "OAuth2.0 %@", accessToken), forHTTPHeaderField: "Authorization")
	}
	
	func cancelAllOngoingTasks()
	{
		for task in self.sessionManager.tasks
		{
			task.cancel()
		}
	}
	
	func httpGet(_ urlString : String, parameters: AnyObject?, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error?) -> Void))
	{
        Log.http("GET REQUEST: " + urlString)
		sessionManager.get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
	}
	
	func httpPost(_ urlString : String, parameters: AnyObject?, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error?) -> Void))
	{
		Log.http("POST REQUEST: " + urlString)
		sessionManager.post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
	}
	
	func httpPut(_ urlString : String, parameters: AnyObject?, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error?) -> Void))
	{
		Log.http("PUT REQUEST: " + urlString)
		sessionManager.put(urlString, parameters: parameters, success: success, failure: failure)
	}
	
	func httpPatch(_ urlString : String, parameters: AnyObject?, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error?) -> Void))
	{
		Log.http("PATCH REQUEST: " + urlString)
		sessionManager.patch(urlString, parameters: parameters, success: success, failure: failure)
	}
	
	func httpDelete(_ urlString : String, parameters: AnyObject?, success: @escaping ((URLSessionDataTask, Any?) -> Void), failure: @escaping ((URLSessionDataTask?, Error?) -> Void))
	{
		Log.http("DELETE REQUEST: " + urlString)
		sessionManager.delete(urlString, parameters: parameters, success: success, failure: failure)
	}
}
