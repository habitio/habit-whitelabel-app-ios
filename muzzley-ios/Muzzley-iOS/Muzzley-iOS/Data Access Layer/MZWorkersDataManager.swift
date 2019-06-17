 //
//  MZWorkersDataManager.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 13/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//
 
import RxSwift
// import RxCocoa

let MZWorkersDataManagerErrorDomain = "MZWorkersDataManagerErrorDomain";

class MZWorkersDataManager
{
	var numberOfWorkers = PublishSubject<String?>()
	
    var workers : [MZWorker] = [MZWorker]()
    fileprivate var geofences: [[String : AnyObject]] = []
    
    class var sharedInstance : MZWorkersDataManager {
        struct Singleton {
            static let instance = MZWorkersDataManager()
        }
        return Singleton.instance
    }
	
	init() {
		
		self.numberOfWorkers.on(.next("--"))
	}
	
    func getObservableOfWorkersForCurrentUser(_ parameters: [String:String]? = nil) -> Observable<(Any)>
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId
        
        return Observable.create({ (observer) -> Disposable in
            
            MZWorkersWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
            
            var queryParamts = [KEY_USER: userId]
            if parameters != nil
            {
                if let include: String = parameters![KEY_INCLUDE]! as String
                {
                    queryParamts[KEY_INCLUDE] = include
                }
            }
            
            MZWorkersWebService.sharedInstance.getWorkersCurrentUser(queryParamts as NSDictionary, completion: { (results, error) -> Void in
                if error == nil
                {
                    if(results is NSDictionary)
                    {
                        let resultWorkers : NSArray = (results as! NSDictionary)[MZWorkersWebService.key_workers] as! NSArray
                        
                        self.workers = [MZWorker]()
						
                        var newWorker : MZWorker
                        self.geofences.removeAll()
						for case let worker as NSDictionary in resultWorkers
                        {
                            newWorker = MZWorker(dictionary: worker as! NSDictionary);
                            if let triggers: NSArray = worker[MZWorker.key_triggers] as? NSArray {
                                newWorker.triggerDevices = self.createWorkerDevice(newWorker.triggerDevices, workerRuleDict: triggers, type: MZWorker.key_trigger)
                            }
                            
                            if let actions: NSArray = worker[MZWorker.key_actions] as? NSArray {
                                newWorker.actionDevices = self.createWorkerDevice(newWorker.actionDevices, workerRuleDict: actions, type: MZWorker.key_action)
                            }
                            
                            if let states: NSArray = worker[MZWorker.key_states] as? NSArray {
                                newWorker.stateDevices =  self.createWorkerDevice(newWorker.stateDevices, workerRuleDict: states, type: MZWorker.key_state)
                            }
                            
                            if let unsorted: NSArray = worker[MZWorker.key_unsorted] as? NSArray {
                                newWorker.unsortedDevices =  self.createWorkerDevice(newWorker.unsortedDevices, workerRuleDict: unsorted, type: MZWorker.key_unsorted)
                            }
                            self.workers.append(newWorker)
                        }
						
						self.numberOfWorkers.on(.next(String(self.workers.count)))
                        MZEmitLocationInteractor.sharedInstance.setGeofences(self.geofences as NSArray)
                        
                        observer.onNext(self.workers as AnyObject)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: MZWorkersDataManagerErrorDomain, code: 0, userInfo: nil))
						self.numberOfWorkers.on(.next("--"))

                    }
                } else {
					self.numberOfWorkers.on(.next("--"))
                    observer.onError(NSError(domain: MZWorkersDataManagerErrorDomain, code: 0, userInfo: nil))
                }
            })
            return Disposables.create {}
        })
    }
    
    
    fileprivate func createWorkerDevice(_ workerDevices: [MZBaseWorkerDevice], workerRuleDict: NSArray, type: String) -> [MZBaseWorkerDevice]
    {
        var workerDevices = workerDevices
        for element in workerRuleDict
        {
            if let dict = element as? NSDictionary
            {
                var workerDeviceM: MZBaseWorkerDevice
                let channelId: String = dict[MZBaseWorkerDevice.key_channel] as! String
                let componentId: String = dict[MZBaseWorkerDevice.key_component] as! String
                
                if let choices: [NSDictionary] = dict["choices"] as? [NSDictionary] {
                    choices.forEach({ (item: NSDictionary) -> () in
                        if let choice: NSDictionary = item["choice"] as? NSDictionary {
                            if let fence: NSDictionary = choice["fence"] as? NSDictionary {
                                var f = [String : AnyObject]()
                                f["id"] = UUID().uuidString as AnyObject
                                for (key, value) in fence {
                                    f[key as! String] = value as AnyObject
                                }
                                self.geofences.append(f)
                            }
                        }
                    })
                }
                
                if workerDevices.isEmpty
                {
                    workerDeviceM = MZBaseWorkerDevice (dictionary: dict)
                    workerDevices.append(workerDeviceM)
                }
                else
                {
                    let filteredWorkerDevices = workerDevices.filter ( { (workerDevice: MZBaseWorkerDevice) -> Bool in
                        let sameChannelId = workerDevice.channelId == channelId
                        
                        let filteredComponents = workerDevice.componentIds.filter {$0 == componentId}
                        return (sameChannelId && filteredComponents.count > 0)
                    })
                    
                    if filteredWorkerDevices.isEmpty
                    {
                        workerDeviceM = MZBaseWorkerDevice (dictionary: dict)
                        workerDevices.append(workerDeviceM)
                    } else {
                        workerDeviceM = filteredWorkerDevices[0]
                    }
                }
                
                let workerItem = MZBaseWorkerItem (dictionary: dict)
                workerDeviceM.items.append(workerItem)
                workerDeviceM.type = type
            }
        }
        
        return workerDevices
    }
    
    
    func createWorkerForCurrentUser(_ worker:MZWorker, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        let parameters = getParametersToCreateUpdate(worker)
        MZWorkersWebService.sharedInstance.createWorkerForCurrentUser(parameters as NSDictionary, completion: completion)
    }
    
    
    func updateWorkerForCurrentUser(_ worker:MZWorker, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        let parameters = getParametersToCreateUpdate(worker)
        MZWorkersWebService.sharedInstance.updateWorkerForCurrentUser(parameters as NSDictionary, completion: completion)
    }
    
    
    fileprivate func getParametersToCreateUpdate(_ worker:MZWorker) -> [String: AnyObject]
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId
        
        var parameters = [String: AnyObject] ()
        parameters[KEY_USER] = userId as AnyObject
        parameters[MZWorkersWebService.key_workerId] = worker.identifier as AnyObject
        parameters[MZWorkersWebService.key_label] = worker.label as AnyObject

        if !worker.triggerDevices.isEmpty
        {
            parameters[MZWorkersWebService.key_triggers] = self.getWorkerRules(worker.triggerDevices) as AnyObject
		}
        if !worker.actionDevices.isEmpty
        {
            parameters[MZWorkersWebService.key_actions] = self.getWorkerRules(worker.actionDevices) as AnyObject
        }
        if !worker.stateDevices.isEmpty
        {
            parameters[MZWorkersWebService.key_states] = self.getWorkerRules(worker.stateDevices) as AnyObject
        }
        
        return parameters
    }
    
    
    fileprivate func getWorkerRules(_ workerDevices: [MZBaseWorkerDevice]) -> [NSDictionary]
    {
        var itemsDict = [NSDictionary] ()
        for workerDevice in workerDevices
        {
            let items = workerDevice.items as [MZBaseWorkerItem]
            for item in items
            {
                itemsDict.append(item.dictionaryRepresentation)
            }
        }
        
        return itemsDict
    }
    
    
    func enableWorkerForCurrentUser(_ workerID: String, enabled: Bool, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        MZWorkersWebService.sharedInstance.enableWorkerForCurrentUser([KEY_USER: MZSession.sharedInstance.authInfo!.userId, MZWorkersWebService.key_workerId: workerID, MZWorkersWebService.key_enabled: enabled], completion: completion)
    }
    
    func executeWorkerForCurrentUser(_ workerID: String, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        MZWorkersWebService.sharedInstance.executeWorkerForCurrentUser([KEY_USER: MZSession.sharedInstance.authInfo!.userId, MZWorkersWebService.key_workerId: workerID], completion: completion)
    }
    
    
    func deleteWorkerForCurrentUser(_ workerID: String, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        MZWorkersWebService.sharedInstance.deleteWorkerForCurrentUser([KEY_USER: MZSession.sharedInstance.authInfo!.userId, MZWorkersWebService.key_workerId: workerID], completion: completion)
    }
}
