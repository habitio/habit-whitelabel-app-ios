//
//  MZTilesWebService.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift


class MZTilesWebService : MZBaseWebService
{
    static let key_tileGroups   = "tileGroups"
    static let key_tiles        = "tiles"
    static let key_groups       = "groups"
    static let key_include      = "include"
    static let key_exclude      = "exclude"
    static let key_type         = "type"
    static let key_channel      = "channel"
    static let key_profile      = "profile"
    static let key_group        = "group"
    static let key_tileId       = "tileId"
    static let key_label        = "label"
    static let key_parent       = "parent"

	let use_mock = false
	
	class var sharedInstance : MZTilesWebService {
		struct Singleton {
			static let instance = MZTilesWebService()
		}
		return Singleton.instance
	}
	
    func getTilesObservableForCurrentUser (_ parameters : NSDictionary) -> Observable<(AnyObject)>
    {
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        return Observable.create({ (observer) -> Disposable in
            
			var path = MZEndpoints.Tiles(parameters[KEY_USER]! as! String)
            
            var queryParams = [String: String]()
            
            if let include : String = parameters[MZTilesWebService.key_include] as? String {
                queryParams[MZTilesWebService.key_include] = include
            }
            if let channel : String = parameters[MZTilesWebService.key_channel] as? String {
                queryParams[MZTilesWebService.key_channel] = channel
            }
            if let profile : String = parameters[MZTilesWebService.key_profile] as? String {
                queryParams[MZTilesWebService.key_profile] = profile
            }
            if let group : String = parameters[MZTilesWebService.key_group] as? String {
                queryParams[MZTilesWebService.key_group] = group
            }
            if let type : String = parameters[MZTilesWebService.key_type] as? String {
                queryParams[MZTilesWebService.key_type] = type
            }
            if let exclude : String = parameters[MZTilesWebService.key_exclude] as? String {
                queryParams[MZTilesWebService.key_exclude] = exclude
            }
			
			
			if self.use_mock
            {
				//path = "https://jsonblob.com/api/jsonblob/043fa73b-aa08-11e7-9754-2f8f3b0907eb"
                path = "https://api.myjson.com/bins/qkyid"
                //"https://jsonblob.com/api/jsonblob/aaebc378-1628-11e7-a0ba-cb270d7e9bcb"
               // path = "https://api.myjson.com/bins/ym4wj"
            }
			
			self.httpGet(path, parameters: queryParams as AnyObject, success: { (sessionManager, responseObject) in
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
    
    
    func getTileGroupsObservableForCurrentUser (_ parameters : NSDictionary) -> Observable<(AnyObject)>
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        return Observable.create({ (observer) -> Disposable in
			
			var path = MZEndpoints.TileGroups(MZSession.sharedInstance.authInfo!.userId)
			
			var queryParams = [String: String]()
            
            if let include : String = parameters[MZTilesWebService.key_include] as? String {
                queryParams[MZTilesWebService.key_include] = include
             }
			
			if self.use_mock
            {
				//path = "https://jsonblob.com/api/jsonBlob/411aef60-1623-11e7-a0ba-f5e1846028dd"
                //path="https://api.myjson.com/bins/13fpa7"
			}
			
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObject) in
				var responseObject = responseObject
				if responseObject == nil
				{
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
    
    
    func updateTileForCurrentUser (_ parameters : NSDictionary, completion: @escaping (_ error : NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path = MZEndpoints.Tile(MZSession.sharedInstance.authInfo!.userId, tileId: parameters[MZTilesWebService.key_tileId]! as! String)
        
        var queryParams = [String: AnyObject]()
        
        if let groups : [String] = parameters[MZTilesWebService.key_groups] as? [String] {
            queryParams[MZTilesWebService.key_groups] = groups as AnyObject
        }
        if let label : String = parameters[MZTilesWebService.key_label] as? String {
            queryParams[MZTilesWebService.key_label] = label as AnyObject
        }
				
		self.httpPatch(path, parameters: queryParams as AnyObject, success: { (sessionManager, responseObject) in
			completion(nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(err)
			}
		}
    }
    
    
    func createGroupForCurrentUser (_ parameters: NSDictionary, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path =  MZEndpoints.TileGroups(MZSession.sharedInstance.authInfo!.userId)
        
        var queryParams = [String: AnyObject]()
        
        if let label: String = parameters[MZTilesWebService.key_label] as? String {
            queryParams[MZTilesWebService.key_label] = label as AnyObject
        }
        if let parent: String = parameters[MZTilesWebService.key_parent] as? String {
            queryParams[MZTilesWebService.key_parent] = parent as AnyObject
        }
		
		self.httpPost(path, parameters: queryParams as AnyObject, success: { (sessionManager, responseObject) in
			completion(responseObject as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(nil,err)
			}
		}
    }
    
    
    func updateGroupForCurrentUser(_ parameters: NSDictionary,completion: @escaping (_ error: NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path =  MZEndpoints.TileGroup(MZSession.sharedInstance.authInfo!.userId, groupId: parameters[MZTilesWebService.key_group]! as! String)
        var queryParams = [String: AnyObject]()
        
        if let label: String = parameters[MZTilesWebService.key_label] as? String {
            queryParams[MZTilesWebService.key_label] = label as AnyObject
        }
		
		self.httpPut(path, parameters: queryParams as AnyObject, success: { (sessionManager, responseObject) in
			completion(nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(err)
			}
		}
    }
    
    
    func deleteGroupForCurrentUser(_ parameters: NSDictionary,completion: @escaping (_ error: NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path =  MZEndpoints.TileGroup(MZSession.sharedInstance.authInfo!.userId, groupId: parameters[MZTilesWebService.key_group]! as! String)
		
		self.httpDelete(path, parameters: nil, success: { (sessionManager, responseObject) in
			completion(nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(err)
			}
		}
    }
    
    
    func deleteTileForCurrentUser(_ parameters: NSDictionary,completion: @escaping (_ error: NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        let path = MZEndpoints.Tile(MZSession.sharedInstance.authInfo!.userId, tileId: parameters[MZTilesWebService.key_tileId]! as! String)
		
		self.httpDelete(path, parameters: nil, success: { (sessionManager, responseObject) in
			completion(nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if (err.code == NSURLErrorCancelled) { return; }
				completion(err)
			}
		}
    }
}
