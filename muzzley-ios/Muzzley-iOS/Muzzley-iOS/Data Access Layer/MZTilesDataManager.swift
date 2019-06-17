//
//  MZTilesDataManager.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift
//import RxCocoa

let MZTilesDataManagerErrorDomain = "MZTilesDataManagerErrorDomain";


class MZTilesDataManager
{
    var tilesInGroupsAndAreas = NSMutableArray ()
	
    let disposeBag = DisposeBag()
	
    class var sharedInstance : MZTilesDataManager {
        struct Singleton {
            static let instance = MZTilesDataManager()
        }
        return Singleton.instance
    }
	
	init()
	{
	}
    
    func getObservableOfTilesByAreaForCurrentUser (_ parameters: NSDictionary?) -> Observable<(Any)>
    {

        return Observable.create({ (observer) -> Disposable in
			
			//print(MZSession.sharedInstance.authInfo?.dictionaryRepresentation)
			let userId : String = MZSession.sharedInstance.authInfo!.userId
			
            var tasks: [Observable<AnyObject>] = []
            
            let tileGroupParams : NSMutableDictionary = NSMutableDictionary()
            let tileParams : NSMutableDictionary = NSMutableDictionary()
            
            tileGroupParams[KEY_USER] = userId
            tileGroupParams[MZTilesWebService.key_include] = "unsorted"
            
            tileParams[KEY_USER] = userId
            tileParams[MZTilesWebService.key_include] = "specs"
            
            if parameters != nil
            {
                if let include:String = parameters![MZTilesWebService.key_include] as? String
                {
                    tileParams[MZTilesWebService.key_include] = "\(include),\(tileParams[MZTilesWebService.key_include]!)"
                    tileGroupParams[MZTilesWebService.key_include] = "\(include),\(tileGroupParams[MZTilesWebService.key_include]!)"
                }
                if let type:String = parameters![MZTilesWebService.key_type] as? String
                {
                    tileParams[MZTilesWebService.key_type] = type
                }
                if let exclude:String = parameters![MZTilesWebService.key_exclude] as? String
                {
                    tileParams[MZTilesWebService.key_exclude] = exclude
                }
            }
            
            tasks.append(MZTilesWebService.sharedInstance.getTileGroupsObservableForCurrentUser(tileGroupParams))
            tasks.append(MZTilesWebService.sharedInstance.getTilesObservableForCurrentUser(tileParams))
            
            //let zipObservable: Observable<NSArray> = tasks.zip {return $0}
			
			Observable<Any>.zip(tasks) {return $0}
				.subscribe(onNext:
                { results in
                    if let resultArray: NSArray = results as! NSArray
                    {
                        let tileGroupsDic: NSDictionary = resultArray[0] as! NSDictionary
						
                        let tilesDic: NSDictionary = resultArray[1] as! NSDictionary
                        
                        var tileGroups: NSArray = NSArray()
                        var tiles: NSArray = NSArray()
                        if let dict = tileGroupsDic[MZTilesWebService.key_tileGroups] as? NSArray
                        {
							let appNamespace = MZThemeManager.sharedInstance.appInfo.namespace
							
							if(appNamespace != "allianz.smarthome")
							{
								var mutableGroups = NSMutableArray()
								for group in dict
								{
									var newGroup = NSMutableDictionary()
									newGroup["id"] = (group as! NSDictionary)["id"] as! String
									newGroup["label"] = NSLocalizedString("mobile_group_name", comment: "")
									mutableGroups.add(newGroup)
								}
								
								tileGroups = mutableGroups
							}
							else
							{
								tileGroups = dict
							}
                        }
                        if let dict = tilesDic[MZTilesWebService.key_tiles] as? NSArray
                        {
                            tiles = dict
                        }
                        
                        self.tilesInGroupsAndAreas = NSMutableArray ()
                        
                        for tileGroup in tileGroups
                        {
							let parent : String? = (tileGroup as! NSDictionary)[MZGroup.key_parent] as? String
                            if parent == nil
                            {
                                let newArea = MZArea(dictionary: tileGroup as! NSDictionary)
                                self.tilesInGroupsAndAreas.add(newArea)
                            }
                        }
                        
                        
                        for tileGroup in tileGroups
                        {
							if let parent : String = (tileGroup as! NSDictionary)[MZGroup.key_parent] as? String
                            {
                                let newGroup = MZGroup(dictionary: tileGroup as! NSDictionary)
                                
								let filteredArray = (self.tilesInGroupsAndAreas as! NSArray).filter() { ($0 as AnyObject).identifier == parent}
                                
                                if (!filteredArray.isEmpty)
                                {
                                    let parentArea: MZArea = filteredArray[0] as! MZArea
                                    newGroup.parent = parentArea
                                    parentArea.children?.add(newGroup)
                                }
                            }
                        }
                        
                        for tile in tiles
                        {
                            let newTile = MZTile(dictionary: tile as! NSDictionary)
							let tileInGroups: [String] = (tile as! NSDictionary).value(forKey:MZTilesWebService.key_groups) as! [String]
                            var predicate: NSPredicate
                            for groupId: String in tileInGroups
                            {
                                predicate = NSPredicate(format: "SELF.identifier = %@", groupId)
                                var filteredAreas = self.tilesInGroupsAndAreas.filtered(using: predicate)
                                var parentArea: MZArea
                                if (!filteredAreas.isEmpty)
                                {
                                    parentArea = filteredAreas[0] as! MZArea
                                    parentArea.children?.add(newTile)
                                    newTile.parent = parentArea
                                } else {
                                    predicate = NSPredicate(format: "ANY children.identifier = %@", groupId)
                                    filteredAreas = self.tilesInGroupsAndAreas.filtered(using: predicate)
                                    if (!filteredAreas.isEmpty)
                                    {
                                        parentArea = filteredAreas[0] as! MZArea
                                        predicate = NSPredicate(format: "SELF.identifier = %@", groupId)
                                        var filteredGroup = parentArea.children?.filtered(using: predicate)
                                        if (!filteredGroup!.isEmpty)
                                        {
                                            let parentGroup = filteredGroup![0] as! MZGroup
                                            parentGroup.children.append(newTile)
                                            newTile.parent = parentGroup
                                        }
                                    }
                                }
                            }
                        }
						
                        observer.onNext(self.tilesInGroupsAndAreas)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                    }
                }, onError: { error in
                    observer.onError(NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                }, onCompleted: {})
                .addDisposableTo(self.disposeBag)
        
            return Disposables.create()
        })
    }
    
    //TODO To similar with previous!!
    func getObservableOfTilesForCurrentUser (_ parameters: NSDictionary?) -> Observable<(Any)>
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId
        
        return Observable.create({ (observer) -> Disposable in
			
            let tileParams : NSMutableDictionary = NSMutableDictionary()
            tileParams[KEY_USER] =  userId
            tileParams[MZTilesWebService.key_include] = "specs"
            
            if parameters != nil
            {
                if let include:String = parameters![MZTilesWebService.key_include] as? String
                {
                    tileParams[MZTilesWebService.key_include] = "\(include),\(tileParams[MZTilesWebService.key_include]!)"
                }
                if let type:String = parameters![MZTilesWebService.key_type] as? String
                {
                    tileParams[MZTilesWebService.key_type] = type
                }
            }
            
            let observable = MZTilesWebService.sharedInstance.getTilesObservableForCurrentUser(tileParams)
            
            observable.subscribe(onNext: { (result) -> Void in
                let tilesDic: NSDictionary = result as! NSDictionary
                self.tilesInGroupsAndAreas = NSMutableArray ()
                
                if let tilesJSON = tilesDic[MZTilesWebService.key_tiles] as? NSArray
                {
                    var tiles = [MZTile]()
                    
                    for tile in tilesJSON
                    {
                        let newTile = MZTile(dictionary: tile as! NSDictionary)
                        tiles.append(newTile)
                    }
                    observer.onNext(tiles as AnyObject)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                }
                
                }, onError: { (errorType) -> Void in
                    observer.onError(NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                }, onCompleted: { () -> Void in
                    
            }).addDisposableTo(self.disposeBag)

            return Disposables.create()
        })
    }
    
    
    func createGroupForCurrentUser(_ label: String, tiles: [MZTile], area:MZArea, completion: @escaping (_ error: NSError?) -> Void)
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId
		
        MZTilesWebService.sharedInstance.createGroupForCurrentUser([KEY_USER: userId, MZTilesWebService.key_label: label, MZTilesWebService.key_parent: area.identifier],
            completion: { (result, error) -> Void in
                if error == nil
                {
                    if let result: NSDictionary = result as? NSDictionary
                    {
                        let group: MZGroup = MZGroup(dictionary: result)
                        self.addTilesToGroup(tiles, group: group, completion: completion)
                    } else {
                        completion (NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                    }
                } else {
                    completion (NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                }
        })
    }
    
    
    func addTilesToGroup(_ newTiles: [MZTile], group: MZGroup, completion: @escaping (_ error : NSError?) -> Void)
    {
        var tasks: [Observable<Any>] = []

        for newTile: MZTile in newTiles
        {
            let groups: [String] = [group.identifier]
            tasks.append(self.getObservableOfUpdateTileForCurrentUser(newTile, groups: groups))
        }
        
        //let zipObservable: Observable<NSArray> = tasks.zip {return $0}
        Observable<Any>.zip(tasks) {return $0}
			.subscribe(onNext:
            { results in
            }, onError: { error in
                completion (NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
            }, onCompleted: {
                completion (nil)
            })
            .addDisposableTo(self.disposeBag)
    }
    
    
    func removeTileFromGroup(_ removedTile: MZTile, group: MZGroup, completion: ((_ error : NSError?) -> Void)?) -> Observable<(Any)>
    {
        let groups: [String] = [(group.parent! as! MZArea).identifier]
        
        let observable = self.getObservableOfUpdateTileForCurrentUser(removedTile, groups: groups)
		
		observable.subscribe(onNext: { (result) in
			
		}, onError: { (error) in
			completion? (NSError(domain:Bundle.main.bundleIdentifier!, code:0, userInfo:nil))

		}, onCompleted: { 
			completion? (nil)
		}, onDisposed: {})
		
//        observable.subscribeCompleted { () -> Void in
//            completion? (error: nil)
//        }
//        observable.subscribeError { (error) -> Void in
//            completion? (error: NSError(domain:Bundle.main.bundleIdentifier!, code:0, userInfo:nil))
//        }
		
        return observable
    }
    
    
    func getObservableOfUpdateTileForCurrentUser(_ tile: MZTile, groups: [String]? = nil) -> Observable<(Any)>
    {
        let userId: String = MZSession.sharedInstance.authInfo!.userId

        return Observable.create({ (observer) -> Disposable in
			
            var params: [String: AnyObject] = [KEY_USER: userId as AnyObject, MZTilesWebService.key_tileId: tile.identifier as AnyObject, MZTilesWebService.key_label: tile.label as AnyObject]
			if groups != nil
            {
                params[MZTilesWebService.key_groups] = groups as AnyObject
            }
        
            MZTilesWebService.sharedInstance.updateTileForCurrentUser(params as NSDictionary, completion: { (error : NSError?) in
                if error == nil {
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
                }
            })
            
            return Disposables.create()
        })
    }
    
    
    func updateGroupForCurrentUser(_ group: MZGroup, completion: @escaping (_ error : NSError?) -> Void)
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId
		
        MZTilesWebService.sharedInstance.updateGroupForCurrentUser([KEY_USER: userId, MZTilesWebService.key_group: group.identifier, MZTilesWebService.key_label: group.label],
            completion: completion)
    }
    

    func ungroup(_ group: MZGroup, completion: @escaping (_ error : NSError?) -> Void)
    {
        let userId: String = MZSession.sharedInstance.authInfo!.userId
		
        MZTilesWebService.sharedInstance.deleteGroupForCurrentUser([KEY_USER: userId, MZTilesWebService.key_group: group.identifier], completion: completion)
    }
    
    func deleteTile(_ tile: MZTile, completion: @escaping (_ error : NSError?) -> Void)
    {
        let userId: String = MZSession.sharedInstance.authInfo!.userId
        MZTilesWebService.sharedInstance.deleteTileForCurrentUser([KEY_USER: userId, MZTilesWebService.key_tileId: tile.identifier],
            completion: completion)
    }

}
