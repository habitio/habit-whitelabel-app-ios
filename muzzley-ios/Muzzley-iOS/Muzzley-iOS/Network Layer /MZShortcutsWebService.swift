//
//  MZShortcutsWebService.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 10/02/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZShortcutsWebService : MZBaseWebService
{

    static let key_shortcuts = "shortcuts"
    static let key_shortcutId = "id"
    static let key_showInWatch = "showInWatch"
    static let key_shortcuts_suggestion = "shortcutSuggestions"
	
	
	
	class var sharedInstance : MZShortcutsWebService {
		struct Singleton {
			static let instance = MZShortcutsWebService()
		}
		return Singleton.instance
	}
	

    func getShortcutsCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void) {
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.Shortcuts(parameters[KEY_USER]! as! String) //"/users/\(parameters[KEY_USER]!)/shortcuts"
		
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
    
    func setShortcutOrder(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.ShortcutsReorder(parameters[KEY_USER]! as! String) //"/users/\(parameters[KEY_USER]!)/shortcuts/reorder"
		
		
		self.httpPost(path, parameters: parameters["params"] as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}
    }
    
    func deleteShortcut(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.Shortcut(parameters[KEY_USER]! as! String, shortcutId: parameters["shortcut_id"] as! String)
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
    
    func createShortcut(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.Shortcuts(parameters[KEY_USER]! as! String) // "/users/\(parameters[KEY_USER]!)/shortcuts"
		
		self.httpPost(path, parameters: parameters["params"] as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)

		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}
		}
	}
    
    func editShortcut(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path = MZEndpoints.Shortcut(parameters[KEY_USER]! as! String, shortcutId: parameters["shortcut_id"]! as! String) // "/users/\(parameters[KEY_USER]!)/shortcuts/\(parameters["shortcut_id"]!)"
		
		self.httpPut(path, parameters: parameters["params"] as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil, err)
			}

		}

    }
    
    func getSuggestedShortcutsCurrentUser(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{

		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.ShortcutsSuggestions(parameters[KEY_USER]! as! String)//"/users/\(parameters[KEY_USER]!)/shortcut-suggestions"
		
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
	
	func executeShortcut(_ parameters : NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

		let path = MZEndpoints.ShortcutPlay(parameters[KEY_USER]! as! String, shortcutId: parameters[MZShortcutsWebService.key_shortcutId]! as! String) //"/users/\(parameters[KEY_USER]!)/shortcuts/\(parameters[MZShortcutsWebService.key_shortcutId]!)/play"
		
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
	
}
