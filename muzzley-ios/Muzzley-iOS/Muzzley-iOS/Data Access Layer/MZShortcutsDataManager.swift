//
//  MZShortcutsDataManager.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 10/02/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

let MZShortcutsDataManagerErrorDomain = "MZShortcutsDataManagerErrorDomain";

class MZShortcutsDataManager
{

    var shortcuts: [MZShortcut] = [MZShortcut]()
	
    class var sharedInstance : MZShortcutsDataManager {
        struct Singleton {
            static let instance = MZShortcutsDataManager()
        }
        return Singleton.instance
    }
    
    func getShortcuts(_ completion: @escaping (_ result: [MZShortcut]?, _ error : NSError?) -> Void)
	{
		MZShortcutsWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        MZShortcutsWebService.sharedInstance.getShortcutsCurrentUser([KEY_USER: MZSession.sharedInstance.authInfo!.userId]) { (results, error) -> Void in
            if error == nil {
                if(results is NSDictionary) {
                    self.shortcuts = [MZShortcut]()
					for shortcut in results!.value(forKey: MZShortcutsWebService.key_shortcuts) as! NSArray {
                        self.shortcuts.append(MZShortcut(dictionary: shortcut as! NSDictionary))
                    }
                    completion(self.shortcuts, nil)
                } else {
                    completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
                }
            } else {
                completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
            }
        }
    }
    
    func setShortcutOrder(_ shortcutIds: [String], completion: @escaping (_ result: Bool?, _ error : NSError?) -> Void)
	{
		MZShortcutsWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
		
        MZShortcutsWebService.sharedInstance.setShortcutOrder([KEY_USER: MZSession.sharedInstance.authInfo!.userId, "params": ["order": shortcutIds]], completion: { (result, error) -> Void in
            if error == nil {
                completion(true, nil)
            } else {
                completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
            }
        })
    }
    
    func deleteShortcut(_ shortcutId: String, completion: @escaping (_ result: Bool?, _ error : NSError?) -> Void) {
        MZShortcutsWebService.sharedInstance.deleteShortcut([KEY_USER: MZSession.sharedInstance.authInfo!.userId, "shortcut_id": shortcutId], completion: { (result, error) -> Void in
            if error == nil {
                completion(result as? Bool, nil)
            } else {
                completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
            }
        })
    }
    
    func createShortcut(_ shortcutVM: MZWorker, inWatch: Bool, completion: @escaping (_ result: NSDictionary?, _ error : NSError?) -> Void) {
        MZShortcutsWebService.sharedInstance.createShortcut([KEY_USER: MZSession.sharedInstance.authInfo!.userId, "params": self.getParametersToCreateUpdate(shortcutVM, inWatch: inWatch)], completion: { (result, error) -> Void in
            if error == nil {
                if result is NSDictionary {
                    completion(result as? NSDictionary, nil)
                } else {
                    completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
                }
            } else {
                completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
            }
        })
    }
    
    func editShortcut(_ shortcutId: NSString, shortcutVM: MZWorker, inWatch: Bool, completion: @escaping (_ result: NSDictionary?, _ error : NSError?) -> Void) {
        MZShortcutsWebService.sharedInstance.editShortcut([KEY_USER: MZSession.sharedInstance.authInfo!.userId, "shortcut_id": shortcutId, "params": self.getParametersToCreateUpdate(shortcutVM, inWatch: inWatch)], completion: { (result, error) -> Void in
            if error == nil {
                if result is NSDictionary {
                    completion(result as? NSDictionary, nil)
                } else {
                    completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
                }
            } else {
                completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
            }
        })
    }
    
    fileprivate func getParametersToCreateUpdate(_ worker:MZWorker, inWatch: Bool) -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters[MZWorkersWebService.key_label] = worker.label as AnyObject
        parameters[MZShortcutsWebService.key_showInWatch] = NSNumber(value: inWatch as Bool)
        
        if !worker.actionDevices.isEmpty {
            parameters[MZWorkersWebService.key_actions] = self.getWorkerRules(worker.actionDevices) as AnyObject
        }
        
        return parameters
    }
    
    fileprivate func getWorkerRules(_ workerDevices: [MZBaseWorkerDevice]) -> [NSDictionary] {
        var itemsDict = [NSDictionary]()
        for workerDevice in workerDevices {
            for item in workerDevice.items as [MZBaseWorkerItem] {
                itemsDict.append(item.dictionaryRepresentation)
            }
        }
        return itemsDict
    }
	
	
	func executeShortcutForCurrentUser(_ shortcutID: String, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		MZShortcutsWebService.sharedInstance.executeShortcut([KEY_USER: MZSession.sharedInstance.authInfo!.userId, MZShortcutsWebService.key_shortcutId: shortcutID], completion: completion)
	}
	
	
    func getSuggestedShortcuts(_ completion: @escaping (_ result: [MZShortcut]?, _ error : NSError?) -> Void) {
        MZShortcutsWebService.sharedInstance.getSuggestedShortcutsCurrentUser([KEY_USER: MZSession.sharedInstance.authInfo!.userId]) { (results, error) -> Void in
            if error == nil {
                if(results is NSDictionary) {
                    self.shortcuts = [MZShortcut]()
					for shortcut in results!.object(forKey:[MZShortcutsWebService.key_shortcuts_suggestion]) as! NSArray {
                        self.shortcuts.append(MZShortcut(dictionary: shortcut as! NSDictionary))
                    }
                    completion(self.shortcuts, nil)
                } else {
                    completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
                }
            } else {
                completion(nil, NSError(domain: MZShortcutsDataManagerErrorDomain, code: 0, userInfo: nil))
            }
        }
    }
    
}
