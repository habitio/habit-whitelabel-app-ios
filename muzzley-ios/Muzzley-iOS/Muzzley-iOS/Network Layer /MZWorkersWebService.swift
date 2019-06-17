//
//  MZWorkersWebService.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 13/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZWorkersWebService : MZBaseWebService
{
    static let key_workers    = "workers"
    static let key_workerId   = "workerId"
    static let key_enabled    = "enabled"
    static let key_label      = "label"
    static let key_triggers   = "triggers"
    static let key_actions    = "actions"
    static let key_states     = "states"

	let use_mock = false
	
	
	class var sharedInstance : MZWorkersWebService {
		struct Singleton {
			static let instance = MZWorkersWebService()
		}
		return Singleton.instance
	}

    
    func getWorkersCurrentUser (_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
	
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        // https://bitbucket.org/muzzley/muzzley-api/wiki/worker-resource#markdown-header-capabilities
		
        var path = MZEndpoints.WorkersAndUsecases(parameters[KEY_USER]! as! String)
		
		if self.use_mock
		{
			path = "https://jsonblob.com/api/jsonblob/d55afd87-19e3-11e7-a0ba-635676818553" //a5c869e3-26aa-11e7-ae4c-0d2741b209ba"
		}

		self.httpGet(path, parameters: nil, success: { (sessionManager, result) in
			completion(result as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}
    }
    
    func createWorkerForCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.Workers(parameters[KEY_USER]! as! String)
		//"/users/\(parameters[KEY_USER]!)/workers"
        let payload = getCreateUpdateParams(parameters)
		
		self.httpPost(path, parameters: payload as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)

		}) { (sessionManager, error) in
			
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}
    }
    
    
    func updateWorkerForCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.Worker(parameters[KEY_USER]! as! String, workerId: parameters[MZWorkersWebService.key_workerId]! as! String)
		//"/users/\(parameters[KEY_USER]!)/workers/\(parameters[MZWorkersWebService.key_workerId]!)"
        let payload = getCreateUpdateParams(parameters)
		
		self.httpPut(path, parameters: payload as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)

		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}

    }
    
    func executeWorkerForCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.WorkerExecute(parameters[KEY_USER]! as! String, workerId: parameters[MZWorkersWebService.key_workerId]! as! String)
		//"/users/\(parameters[KEY_USER]!)/workers/\(parameters[MZWorkersWebService.key_workerId]!)/play"
		
		self.httpPost(path, parameters: nil, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}
    }
    
    
    fileprivate func getCreateUpdateParams(_ parameters : NSDictionary) -> [String: AnyObject]
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        var payload : [String: AnyObject] = ["user": parameters[KEY_USER]! as AnyObject,
            "enabled": true as AnyObject,
            "label": parameters[MZWorkersWebService.key_label]! as AnyObject]
        
        if let workerId: String = parameters[MZWorkersWebService.key_workerId] as? String
        {
            if !workerId.isEmpty
            {
                payload["id"] = workerId as AnyObject
            }
        }
        
        if let triggers = parameters[MZWorkersWebService.key_triggers]
        {
            payload["triggers"] = triggers as AnyObject
        }
        if let actions = parameters[MZWorkersWebService.key_actions]
        {
            payload["actions"] = actions as AnyObject
        }
        if let states = parameters[MZWorkersWebService.key_states]
        {
            payload["states"] = states as AnyObject
        }

        return payload
    }
    
    
    func enableWorkerForCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.Worker(parameters[KEY_USER]! as! String, workerId: parameters[MZWorkersWebService.key_workerId]! as! String)
		//"/users/\(parameters[KEY_USER]!)/workers/\(parameters[MZWorkersWebService.key_workerId]!)"
		
        let payload : [String: Bool] = ["enabled" : parameters[MZWorkersWebService.key_enabled] as! Bool]
		
		self.httpPatch(path, parameters: payload as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}
    }
    
    
    func deleteWorkerForCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path = MZEndpoints.Worker(parameters[KEY_USER]! as! String, workerId: parameters[MZWorkersWebService.key_workerId]! as! String) // "/users/\(parameters[KEY_USER]!)/workers/\(parameters[MZWorkersWebService.key_workerId]!)"
		
		self.httpDelete(path, parameters: nil, success: { (sessionManager, responseObject) in
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
