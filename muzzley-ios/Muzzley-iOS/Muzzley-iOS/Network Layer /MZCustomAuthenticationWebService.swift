//
//  MZCustomAuthenticationWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

@objc class MZCustomAuthenticationWebService : MZBaseWebService
{
	func createUrlPath(_ url: URL) -> String
	{
		var portString = ""
		if(url.port != nil)
		{
			portString = String(url.port!)
		}

		var urlString =  String(format: "%@://%@%@", url.scheme!, url.host!, portString)

		return urlString
		// TODO: Finish this and check this
	}
	
	func getDiscoveryProcessInitiation(_ url: URL, completion: @escaping (_ step: MZDiscoveryProcess?, _ error: NSError?) -> Void)
	{
		let path = url.absoluteString //self.createUrlPath(url)
		
		self.httpGet(path, parameters: nil, success: { (sessionDataTask, responseObject) in
			
			if (responseObject! as AnyObject).isKind(of: NSDictionary.self)
			{
				var discoveryProcess = MZDiscoveryProcess(dictionary: responseObject as! NSDictionary)
				completion(discoveryProcess, nil)
			}
			else
			{
				completion(nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Discovery Initiation Process failed.", NSLocalizedFailureReasonErrorKey : "Invalid Server Protocol response. Please try again."]))
			}
			
		}, failure: { (sessionManager, error) in
				completion(nil, error as! NSError)
		})
	}
	
	func postDiscoveryProcessStepResultWithURL(_ url: URL, array : NSArray, completion: @escaping (_ step: MZDiscoveryProcessStep?, _ data: NSDictionary?, _ error: NSError?) -> Void)
	{
		var path = createUrlPath(url)
		let parameters = ["actionsResults" : array]
		
		self.httpPost(path, parameters: parameters as AnyObject, success: { (sessionDataTask, responseObject) in
			if responseObject is NSDictionary
			{
				var discoveryProcessStep : MZDiscoveryProcessStep? = nil
				let success = (responseObject as! NSDictionary).value(forKey: "success") as! Bool
				if(!success)
				{
					discoveryProcessStep = MZDiscoveryProcessStep(dictionary: responseObject as! NSDictionary)
				}
				
				let jsonData = (responseObject as! NSDictionary).value(forKey: "data")
				
				
				completion (discoveryProcessStep, jsonData as! NSDictionary, nil)
			}
			else
			{
				completion(nil, nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Discovery step process failed.", NSLocalizedFailureReasonErrorKey : "Invalid Server Protocol response. Please try again."]))
			}
			
		}, failure: { (sessionManager, error) in
			completion(nil, nil, error as! NSError)
		})
	}
	
	func getNextDiscoveryProcessStepWithURL(_ url: URL, completion: @escaping (_ step: MZDiscoveryProcessStep?, _ error: NSError?) -> Void)
	{
		var path = url.absoluteString //createUrlPath(url)
		self.httpGet(path, parameters: nil, success: { (sessionDataTask, responseObject) in
			if responseObject is NSDictionary
			{
				completion (MZDiscoveryProcessStep(dictionary: responseObject as! NSDictionary),nil)
			}
			else
			{
				completion(nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Discovery step process failed.", NSLocalizedFailureReasonErrorKey : "Invalid Server Protocol response. Please try again."]))
			}
			
		}, failure: { (sessionManager, error) in
			completion(nil, error as! NSError)
		})
	}
	
	
	func _discoveryProcessStepWithDictionary(_ dictionary: NSDictionary) -> MZDiscoveryProcessStep
	{
		let discoveryProcessStep = MZDiscoveryProcessStep(dictionary: dictionary  as! NSDictionary)
	
		let mutableActions = NSMutableArray()
		for actionDictionary  in (discoveryProcessStep.actions)
		{
			let action = MZDiscoveryProcessAction(dictionary: actionDictionary as! NSDictionary)
			action.identifier = (actionDictionary as! NSDictionary).value(forKey: "id") as! String
			mutableActions.add(action)
		}
		
		discoveryProcessStep.actions = mutableActions as NSArray
		
		return discoveryProcessStep
	}
	
	// TODO: Finish this after swift 3 conversion
	func requestWithMethod(method : String, url: NSURL, headers: NSArray, parameters: NSDictionary, completion: @escaping (_ step: Any?, _ error: NSError?) -> Void)
	{
		var path = createUrlPath(url as! URL)
		var request : MutableURLRequest
		
		if parameters is NSDictionary
		{
			request = self.sessionManager.requestSerializer.request(withMethod: method, urlString: path, parameters: parameters, error: nil)
		}

		if parameters is String
		{
			request = self.sessionManager.requestSerializer.request(withMethod: method, urlString: path, parameters: nil, error: nil)
			let body : String = parameters as! String
			request.httpBody =  body.data(using: String.Encoding.utf8)
		}
		else
		{
			request = self.sessionManager.requestSerializer.request(withMethod: method, urlString: path, parameters: nil, error: nil)
		}
		
		for case let header as NSDictionary	in headers
		{
			let headerField = header.allKeys[0] as! String
			let value = header.allValues[0] as! String
			request.setValue(value, forHTTPHeaderField: headerField)
		}
		
		request.timeoutInterval = 240

		self.sessionManager.dataTask(with: request as URLRequest)
		{ (urlResponse, responseObject , error) in
			
			if(error != nil)
			{
				completion(nil, error as! NSError)
			}
			
			var responseString : String
			var jsonDictionary : NSDictionary
			if responseObject != nil && responseObject is Data
			{
				responseString = String.init(data: (responseObject as! Data), encoding: String.Encoding.utf8)!
				
				
				do
				{
					jsonDictionary =  try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as? [String:AnyObject] as! NSDictionary
					
					completion(jsonDictionary, nil)


				} catch let error as NSError
				{
//					dLog(message: "Error parsing core message! error:\(error)")
					completion(responseString, nil)
				}
			}
		}
	}
	
	
}
