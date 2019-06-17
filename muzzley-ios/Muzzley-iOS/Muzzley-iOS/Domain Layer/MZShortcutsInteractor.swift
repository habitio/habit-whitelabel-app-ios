//
//  MZShortcutsInteractor.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 10/02/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit
import RxSwift

class MZShortcutsInteractor: MZDeviceListInteractor
{

    func getShortcuts(_ completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void) {
        
        var tasks: [Observable<Any>] = []
        let parameters:[String:String] = [KEY_INCLUDE: "context"]

        tasks.append(MZTilesDataManager.sharedInstance.getObservableOfTilesForCurrentUser(parameters as! NSDictionary))
        tasks.append(self.getObservableOfShortcuts())
        
        // let zipObservable: Observable<NSArray> = tasks.zip {return $0}
		Observable<Any>.zip(tasks) { return $0 }
			.subscribe(onNext: { (results) in
				let results = results as? NSArray
				if let shortcutsArray: [MZShortcut] = results?[1] as? [MZShortcut] {
					if let tiles = results?[0] as? [MZTile] {
                    var shortcutViewModels = [MZShortcutViewModel] ()
                    shortcutsArray.forEach({ (shortcut) in
                        let shortcutVM : MZShortcutViewModel = MZShortcutViewModel(model: shortcut.toWorkerModel())
                        shortcutVM.shortcutModel(shortcut)
                        shortcutVM.isValid = true
                        
                        for actionShortcutDeviceVM in shortcutVM.actionDeviceVMs
                        {
                            shortcutVM.isValid = self.updateShortcutWithTile(actionShortcutDeviceVM, tiles: tiles)
                            if !shortcutVM.isValid { break }
                        }
                        shortcutViewModels.append(shortcutVM)
                    })
                
                    completion(shortcutViewModels as AnyObject, nil)
                    return
                }
            }
            
            completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
        }, onError: { (error) in
            completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
        }).addDisposableTo(self.disposeBag)
    }
    
    fileprivate func getObservableOfShortcuts() -> Observable<(Any)> {
        return Observable.create({ (observer) -> Disposable in
            MZShortcutsDataManager.sharedInstance.getShortcuts { (result, error) -> Void in
                if error == nil {
                    let toOrder: [MZShortcut] = (result?.filter{ $0.order >= 0 }.sorted{ $0.order < $1.order })!
                    let others: [MZShortcut] = (result?.filter{ $0.order < 0 })!
                    
                    observer.onNext(toOrder + others as Any)
                    observer.onCompleted()
                } else {
                    observer.onError(error!)
                }
            }
            
            return Disposables.create {}
        })
    }
    
//    func updateShortcutVMWithTile(shortcutsVM: MZWorkerViewModel, completion: (result: MZWorkerViewModel?, error : NSError?) -> Void) {
//        MZTilesDataManager.sharedInstance.getObservableOfTilesForCurrentUser([KEY_INCLUDE: "context"]).subscribe(onNext: { (r) -> Void in
//            if let resultTiles = r as? [MZTile] {
//                shortcutsVM.actionDeviceVMs.forEach {
//                    self.updateShortcutWithTile($0.model!, tiles: resultTiles)
//                }
//                completion(result: shortcutsVM, error: nil)
//            }
//            completion(result: nil, error: NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
//        }, onError: { (ErrorType) -> Void in
//            completion(result: nil, error: NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
//        }).addDisposableTo(self.disposeBag)
//    }
    

//    func updateShortcutVMWithTile(shortcutsVM: MZWorkerViewModel, completion: (result: MZWorkerViewModel?, error : NSError?) -> Void)
//    {
//        let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
//        let channelDM : MZChannelsDataManager = MZChannelsDataManager.sharedInstance
//
//        var tasks: [Observable<AnyObject>] = []
//        
//        let parameters:[String:String] = [KEY_INCLUDE: "context"]
//        
//        tasks.append(tilesDM.getObservableOfTilesForCurrentUser(parameters))
//        
//        let zipObservable: Observable<NSArray> = tasks.zip {return $0}
//        zipObservable.subscribe(onNext:
//            { results in
//                
//                if let resultArray: NSArray = results as NSArray
//                {
//                    if let tiles = resultArray[0] as? [MZTile]
//                    {
//                        if let channels = resultArray[1] as? [String : MZChannel]
//                        {
//                            shortcutsVM.actionDeviceVMs.forEach {
//                                self.updateShortcutWithTile($0, tiles: tiles, channels: channels)
//                            }
//                            
//                            completion(result: shortcutsVM, error: nil)
//                        } else {
//                            completion(result: nil, error: NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
//                        }
//
//                    } else {
//                        completion(result: nil, error: NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
//                    }
//                } else {
//                    completion(result: nil, error: NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
//                }
//            }, onError: { error in
//                completion(result: nil, error: NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
//            }, onCompleted: {})
//            .addDisposableTo(self.disposeBag)
//    }
    
    
    

    fileprivate func updateShortcutWithTile(_ workerDeviceVM:MZBaseWorkerDeviceViewModel, tiles:[MZTile]) -> Bool
    {
        //TODO should check if all component id's correspond to tile components
        for componentId in workerDeviceVM.model!.componentIds {
            if let tile = self.getTile(workerDeviceVM.model!.channelId, componentId: componentId, tiles: tiles) {
                workerDeviceVM.model!.tile = tile
                return true
            }
        }
        return false
    }
    
    fileprivate func getTile(_ channelId: String, componentId: String, tiles:[MZTile]) -> MZTile?
    {
        let filteredTiles = tiles.filter(){
            let sameChannel = ($0.channelId == channelId)
            let filteredComponents = $0.components.filter() { $0.identifier == componentId }
            return sameChannel && !filteredComponents.isEmpty
        }
        
        if !filteredTiles.isEmpty {
            return filteredTiles[0]
        }
        return nil
    }
    
    func setShortcutOrder(_ shortcutIds: [String], completion: @escaping (_ result: Bool?, _ error : NSError?) -> Void) {
        MZShortcutsDataManager.sharedInstance.setShortcutOrder(shortcutIds) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func deleteShortcut(_ shortcutId: String, completion: @escaping (_ result: Bool?, _ error : NSError?) -> Void) {
        MZShortcutsDataManager.sharedInstance.deleteShortcut(shortcutId) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func createShortcut(_ shortcutVM: MZWorkerViewModel, inWatch: Bool, completion: @escaping (_ result: NSDictionary?, _ error : NSError?) -> Void) {
        shortcutVM.updateModel()
        MZShortcutsDataManager.sharedInstance.createShortcut(shortcutVM.model!, inWatch: inWatch) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func editShortcut(_ shortcutId: String, shortcutVM: MZWorkerViewModel, inWatch: Bool, completion: @escaping (_ result: NSDictionary?, _ error : NSError?) -> Void) {
        shortcutVM.updateModel()
        MZShortcutsDataManager.sharedInstance.editShortcut(shortcutId as NSString, shortcutVM: shortcutVM.model!, inWatch: inWatch) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func getSuggestedShortcuts(_ completion: @escaping (_ result: [MZShortcutViewModel]?, _ error : NSError?) -> Void) {
        MZShortcutsDataManager.sharedInstance.getSuggestedShortcuts { (result, error) -> Void in
            if error == nil {
                let toOrder: [MZShortcut] = (result?.filter{ $0.order >= 0 }.sorted{ $0.order < $1.order })!
                let others: [MZShortcut] = (result?.filter{ $0.order < 0 })!
                
                let shortcutsArray: [MZShortcut] = toOrder + others
                
                var shortcutViewModels = [MZShortcutViewModel] ()
                shortcutsArray.forEach({ (shortcut) in
                    let shortcutVM : MZShortcutViewModel = MZShortcutViewModel(model: shortcut.toWorkerModel())
                    shortcutVM.shortcutModel(shortcut)
                    shortcutVM.isValid = true
                    
//                        for actionShortcutDeviceVM in shortcutVM.actionDeviceVMs
//                        {
//                            shortcutVM.isValid = self.updateShortcutWithTile(actionShortcutDeviceVM, tiles: tiles)
//                            if !shortcutVM.isValid { break }
//                        }
					
                    shortcutViewModels.append(shortcutVM)
                })
                
                completion(shortcutViewModels, error)
            } else {
                completion(nil, error)
            }
        }
    }
	
	
//	func executeShortcut(executeCommands: [NSDictionary], completion: (result: AnyObject?, error : NSError?) -> Void)
//	{
//		for payload in executeCommands
//		{
//			let components = MZMQTTWebviewMessageHelper.getTopicInfoFromNSDictionary(payload)
//			if(components != nil)
//			{
//				let topic = MZTopicParser.createPublishTopic(components!.channelId, componentId: components!.componentId, propertyId: components!.propertyId)
//				MZMQTTConnection.sharedInstance.publish(topic, jsonDict: payload, completion: { (success, error) in
//					completion(result: success, error: error)
//				})
//			}
//		}
//	}
	
	func executeShortcut(_ shortcutVM: MZShortcutViewModel, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		MZShortcutsDataManager.sharedInstance.executeShortcutForCurrentUser(shortcutVM.model!.identifier, completion: {(result, error) in
			completion(result, error)
		})
	}
	
}
