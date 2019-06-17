//
//  WorkersInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 13/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

class MZWorkersInteractor : MZDeviceListInteractor
{    
    static let key_type         = "type"
    static let key_exclude      = "exclude"
    static let key_version      = "version"
    static let key_channels     = "channels"
    static let key_capabilities = "capabilities"
    static let key_tiles        = "tiles"
	static let key_preferences        = "preferences"
    
    var currentDevices:[MZAreaViewModel]?
    static fileprivate var workerURL: URL?
    
    func getWorkerURL() -> URL
    {
        if MZWorkersInteractor.workerURL == nil
        {
            MZWorkersInteractor.workerURL = URL(string: MZThemeManager.sharedInstance.endpoints.workerEditorUrl)
        }
        return MZWorkersInteractor.workerURL!
    }

    func getWorkers(_ completion: @escaping (  _ result: Any?, _ error : NSError?) -> Void)
    {
        let workersDM :  MZWorkersDataManager = MZWorkersDataManager.sharedInstance
        let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
        let channelDM : MZChannelsDataManager = MZChannelsDataManager.sharedInstance

        
        var tasks: [Observable<Any>] = []
        
        let parameters:[String:String] = [KEY_INCLUDE: "context,capabilities"]
        
        tasks.append(tilesDM.getObservableOfTilesForCurrentUser(parameters as NSDictionary))
        tasks.append(workersDM.getObservableOfWorkersForCurrentUser(parameters))
        tasks.append(channelDM.getObservableOfChannelForCurrentUser(parameters as NSDictionary))
        
        //let zipObservable: Observable<NSArray> = tasks.zip {return $0}
        Observable<Any>.zip(tasks) {return $0}
			.subscribe(onNext:
            { results in
                var workerViewModels = [MZWorkerViewModel] ()

                if let resultArray: NSArray = results as! NSArray
                {                    
                    if let workersArray: [MZWorker] = resultArray[1] as? [MZWorker]
                    {
                        if let tiles = resultArray[0] as? [MZTile]
                        {
                            for worker : MZWorker in workersArray
                            {
                                let workerVM : MZWorkerViewModel = MZWorkerViewModel(model: worker)
                                
                                if workerVM.isValid
                                {
                                    if let resultChannels : [String : MZChannel] = resultArray[2] as? [String : MZChannel]
                                    {
                                        if self.updateWorkerVMValidation(workerVM, tiles: tiles, channels:resultChannels)
                                        {
                                            workerVM.requiredCapabilities = self.getAllWorkerCapabilities(workerVM)
                                        }
                                    }
                                }
								workerViewModels.append(workerVM)
                            }
                            
                            completion(workerViewModels, nil)
                            return
                        }
                    }
                }
                completion(nil, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
            }, onError: { error in
                completion(nil, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
            }, onCompleted: {})
            .addDisposableTo(self.disposeBag)
    }


    func updateWorkerVMValidation(_ workerVM:MZWorkerViewModel, tiles:[MZTile], channels: [String : MZChannel]) -> Bool
    {
        var triggers : [MZBaseWorkerDeviceViewModel] = []
        
        if let trigger = workerVM.triggerDeviceVM
        {
            triggers.append(trigger)
        }
        
        let devicesVMs = triggers + workerVM.actionDeviceVMs + workerVM.stateDeviceVMs + workerVM.unsortedDeviceVMs + workerVM.unsortedDeviceVMs
        
        for workerDeviceVM in devicesVMs
        {
            workerVM.isValid = self.updateWorkerWithTile(workerDeviceVM, tiles: tiles, channels:channels)
            if !workerVM.isValid { break }
        }
        
        return workerVM.isValid
    }


    func updateWorkerWithTile(_ workerDeviceVM:MZBaseWorkerDeviceViewModel, tiles:[MZTile], channels: [String : MZChannel]) -> Bool
    {
        //TODO should check if all component id's correspond to tile components
        for componentId in workerDeviceVM.model!.componentIds
        {
            if let tile = self.getTile(workerDeviceVM.model!.channelId, componentId: componentId, tiles: tiles)
            {
                tile.updateWithChannel(channels)
                workerDeviceVM.model!.tile = tile
                return true
            }
        }
        return false
    }


    func getTile(_ channelId: String, componentId: String, tiles:[MZTile]) -> MZTile?
    {
        let filteredTiles = tiles.filter(){
            let sameChannel = ($0.channelId == channelId)
            
            let filteredComponents = $0.components.filter() { $0.identifier == componentId }
            
            return sameChannel && !filteredComponents.isEmpty
        }
        
        if !filteredTiles.isEmpty
        {
            return filteredTiles[0]
        }
        return nil
    }
    
    
    //TODO check only properties beeing used
    func getAllWorkerCapabilities(_ workerDeviceVM: MZWorkerViewModel) -> [String]
    {
        var capabilities: [String] = []
        
        let devices = workerDeviceVM.model!.triggerDevices + workerDeviceVM.model!.actionDevices + workerDeviceVM.model!.stateDevices + workerDeviceVM.model!.unsortedDevices
        
        devices.forEach { (device) in
            
            let devicesComponentsType = device.tile?.components.map { $0.type }
            
            let propertiesOfComp = device.tile?.channel?.properties.filter({ (property) -> Bool in
                MZBaseInteractor.isArrayContainsAnyArray(property.components, lookFor: devicesComponentsType)
            })
            
            propertiesOfComp?.forEach {
                $0.requiredCapabilities.forEach {
                    if !capabilities.contains($0) {
                        capabilities.append($0)
                    }
                }
            }
        }
        
        return capabilities
    }
	

    
    override func getDevicesByArea(_ input:AnyObject?, completion: @escaping (_ result:AnyObject?, _ error:NSError?) -> Void)
    {
        var filters:[String:AnyObject]? = input as? [String:AnyObject]
        var type = ""
        var typeStr = ""
        var excludeIds = ""
        if filters != nil
        {
            if let typeInDict:String = filters![MZWorkersInteractor.key_type] as? String
            {
                type = typeInDict
                switch type
                {
                    case MZWorker.key_trigger:
                        typeStr = "triggerable"
                        break
                    case MZWorker.key_action:
                        typeStr = "actionable"
                        break
                    case MZWorker.key_state:
                        typeStr = "stateful"
                        break
                    default: break
                }
            }
            
            if let excludeIdArray:[String] = filters![MZWorkersInteractor.key_exclude] as? [String]
            {
                excludeIdArray.forEach({ (excludeId) -> () in
                    excludeIds = "\(excludeIds),\(excludeId)"
                })
                
                excludeIds = String(excludeIds.characters.dropFirst())
            }
        }
        
        var parameters:[String:Any] = [String:Any]()

        switch type {
        case MZWorker.key_trigger:
            parameters = [KEY_TYPE: typeStr, KEY_INCLUDE: "context,capabilities"]
            break
        case MZWorker.key_action:
            parameters = [KEY_TYPE: typeStr, KEY_INCLUDE: "context,capabilities"]
            break
        case MZWorker.key_state:
            parameters = [KEY_TYPE: typeStr, KEY_INCLUDE: "context,capabilities", KEY_EXCLUDE: excludeIds]
            break
        default: break
        }
        self.getUnGroupedDevicesFilterByType(parameters) { (result, error) in
			completion(result as AnyObject, error)
		}
        //self.getUnGroupedDevicesFilterByType(parameters, completion: completion as! (Any?, NSError?) -> Void)
    }

    
    func getUnGroupedDevicesFilterByType(_ parameters: [String:Any], completion: @escaping (_ result: Any?, _ error: NSError?) -> Void)
    {
        self.getAllDevices ({ (results, error) -> Void in
            if error == nil
            {
                if let arrayResults: [AnyObject] = results as? [AnyObject]
                {
                    let resultTiles: [MZArea] = arrayResults[0] as! [MZArea]
                    let resultChannels: [String : MZChannel] = arrayResults[1] as! [String : MZChannel]
                    var areaViewModels = [MZAreaViewModel] ()
                
                    
                    for area: MZArea in resultTiles
                    {
                        
                        if area.children!.count > 0
                        {
                            if let areaVM: MZAreaViewModel = self.addDeviceViewModelToArea(area, channels: resultChannels)
                            {
                                areaVM.devicesViewModel.forEach({ (device) -> Void in
                                    
                                    let devicesComponentsType = device.model!.components.map { $0.type }
                                    
                                    let propertiesOfComp = device.model?.channel?.properties.filter({ (property) -> Bool in
                                        MZBaseInteractor.isArrayContainsAnyArray(property.components, lookFor: devicesComponentsType)
                                    })
                                    
                                    let propertiesOfType = propertiesOfComp!.filter() {
                                        if parameters[KEY_TYPE] as! String == "triggerable"
                                        {
                                            return $0.isTriggable
                                        }
                                        else if parameters[KEY_TYPE] as! String == "actionable"
                                        {
                                            return $0.isActionable
                                        }
                                        else if parameters[KEY_TYPE] as! String == "stateful"
                                        {
                                            return $0.isStateful
                                        }
                                        
                                        return false
                                    }
                                    
                                    let propertiesWithCap = propertiesOfType.filter({ (property) -> Bool in
                                        MZBaseInteractor.isArrayContainsAnyArray(property.requiredCapabilities, lookFor: MZHardwareCapabilities.supportedCapabilities)
                                    })
                                    
                                    if propertiesWithCap.isEmpty
                                    {
                                        areaVM.devicesViewModel.remove(at: areaVM.devicesViewModel.index(of: device)!)
                                    }
                                })
                                
                                areaViewModels.append(areaVM)
                            }
                        }
                    }
                    self.currentDevices = areaViewModels
                    completion(areaViewModels, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
            }, parameters: parameters as NSDictionary)
    }
    
    
    
    
    func getOptionsPayload(_ deviceVMs: [MZDeviceViewModel], type:String) -> NSDictionary
    {
		let bridgeOptions = NSMutableDictionary(objects: [type,VERSION_WORKER_EDITOR], forKeys: ([MZWorkersInteractor.key_type, MZWorkersInteractor.key_version] as! NSCopying) as! [NSCopying])
//        let bridgeOptions = NSMutableDictionary(objects: [type,VERSION_WORKER_EDITOR], forKeys: [MZWorkersInteractor.key_type as NSCopying, MZWorkersInteractor.key_version as NSCopying])
        let tileDicts:NSMutableArray = NSMutableArray()
        let channelDicts:NSMutableArray = NSMutableArray()

        for device in deviceVMs
        {
            let tileModel: MZTile = device.model!
            tileDicts.add(tileModel.dictionaryRepresentation)
            if tileModel.channel != nil
            {
                channelDicts.add(tileModel.channel!.dictionaryRepresentation)
            }
        }
        bridgeOptions.setObject(tileDicts, forKey: MZWorkersInteractor.key_tiles as NSCopying)
        bridgeOptions.setObject(channelDicts, forKey: MZWorkersInteractor.key_channels as NSCopying)
        bridgeOptions.setObject(MZSessionDataManager.sharedInstance.session.userProfile.preferences.dictionaryRepresentation, forKey: MZWorkersInteractor.key_preferences as NSCopying)
        var capabilities = MZHardwareCapabilities.supportedCapabilities
        capabilities.remove(at: capabilities.index(of: NONE_CAPABILITY)!)
        bridgeOptions.setObject(capabilities, forKey: MZWorkersInteractor.key_capabilities as NSCopying)
        return bridgeOptions
    }
    
    
    func updateWorkerViewModel(_ workerVM: MZWorkerViewModel, message: [AnyHashable: Any], isUpdate: Bool = false, isEdit: Bool = false, isShortcut: Bool = false) -> MZWorkerViewModel
    {
        var workerVM = workerVM
        let ruleUnit = (message["d"] as! NSDictionary)["ruleUnit"] as! NSDictionary
        let rules = ruleUnit["rules"] as! NSArray
        let type = ruleUnit["type"] as! String
        
        if type == MZWorker.key_trigger
        {
            //TODO TOO SIMILLAR!!
            let rule = rules[0] as! NSDictionary
			let channelId:String = rule["channel"] as! String
            let componentId:String = rule["component"] as! String
            let label:String = rule["label"] as! String
            workerVM = setWorkerDeviceTriggerViewModel(workerVM, channelId: channelId, componentId: componentId, label: label, type: type, ruleDict: rule as! NSDictionary, isUpdate: isUpdate, isEdit: isEdit, isShortcut: isShortcut)
            
        } else if type == MZWorker.key_action || type == MZWorker.key_state
        {
            //TODO TOO SIMILLAR!!
			for case let rule as NSDictionary in rules
            {
                let channelId:String = rule["channel"] as! String
                let componentId:String = rule["component"] as! String
                let label:String = rule["label"] as! String
                 workerVM = setWorkerDeviceViewModel(workerVM, channelId: channelId, componentId: componentId, label: label, type: type, ruleDict: rule as! NSDictionary, isUpdate: isUpdate, isEdit: isEdit, isShortcut: isShortcut)
            }
        }
        workerVM.updateModel()
        
        return workerVM
    }
    
    //TODO TOO SIMILLAR!!
    fileprivate func setWorkerDeviceTriggerViewModel(_ workerVM: MZWorkerViewModel, channelId: String, componentId: String, label: String, type: String, ruleDict: NSDictionary, isUpdate: Bool = false, isEdit: Bool = false, isShortcut: Bool = false) -> MZWorkerViewModel
    {
        if let device: MZDeviceViewModel = getDeviceViewModel(channelId, componentId: componentId)
        {
            let workerDeviceM = MZBaseWorkerDevice()
            workerDeviceM.tile = device.model!
            let triggerDeviceVM = MZBaseWorkerDeviceViewModel (model: workerDeviceM)
            
            let workerDeviceItemM = MZBaseWorkerItem(dictionary: ruleDict)
            let triggerWorkerItemVM = MZBaseWorkerItemViewModel (model: workerDeviceItemM)
            triggerWorkerItemVM.stateDescription = NSAttributedString(string: label)

            triggerDeviceVM.type = type
            triggerDeviceVM.items.append(triggerWorkerItemVM)
            
            workerVM.triggerDeviceVM = triggerDeviceVM
        }
        
        if isUpdate {
            if isEdit {
                //MZAnalyticsInteractor.routineEditEditTriggerDoneEvent(
            } else {
                MZAnalyticsInteractor.workerEditAddTriggerDoneEvent(workerVM.model!.identifier,
                                                                    profileID: workerVM.triggerDeviceVM!.model!.tile!.profileId,
                                                                    deviceName: workerVM.triggerDeviceVM!.title!)
            }
        } else {
            if isEdit {
                // MZAnalyticsInteractor.routineCreateEditTriggerDoneEvent(
            } else {
                 MZAnalyticsInteractor.workerCreateAddTriggerDoneEvent(workerVM.triggerDeviceVM!.model!.tile!.profileId,
                                                                       deviceName: workerVM.triggerDeviceVM!.title!)
            }
        }
        
        return workerVM
    }
    
    //TODO TOO SIMILLAR!!
    fileprivate func setWorkerDeviceViewModel(_ workerVM: MZWorkerViewModel,channelId: String, componentId: String, label: String, type: String, ruleDict: NSDictionary, isUpdate: Bool = false, isEdit: Bool = false, isShortcut: Bool = false) -> MZWorkerViewModel
    {
        var workerDeviceVMs: [MZBaseWorkerDeviceViewModel]? = nil
        
        switch type
        {
        case MZWorker.key_action:
            workerDeviceVMs = workerVM.actionDeviceVMs
            break
        case MZWorker.key_state:
            workerDeviceVMs = workerVM.stateDeviceVMs
            break
        default: break
        }
        
        if workerDeviceVMs == nil { return workerVM }

        let filteredWorkers = workerDeviceVMs!.filter ( { (workerDeviceViewModel: MZBaseWorkerDeviceViewModel) -> Bool in
            if workerDeviceViewModel.model!.tile != nil {
                let sameChannelId = workerDeviceViewModel.model!.tile!.channelId == channelId
                let filteredComponents = workerDeviceViewModel.model!.tile!.components.filter {$0.identifier == componentId}
                return (sameChannelId && filteredComponents.count > 0)
            } else {
                return false
            }
        })
        
        var workerDeviceViewModel: MZBaseWorkerDeviceViewModel?
        if filteredWorkers.isEmpty
        {
            if let device: MZDeviceViewModel = getDeviceViewModel(channelId, componentId: componentId)
            {
                let workerDeviceModel = MZBaseWorkerDevice()
                workerDeviceModel.tile = device.model!
                workerDeviceViewModel = MZBaseWorkerDeviceViewModel (model: workerDeviceModel)
                workerDeviceViewModel!.type = type
                workerDeviceVMs!.append(workerDeviceViewModel!)
                
                //TODO if its a reference why this is needed?
                switch type
                {
                case MZWorker.key_action:
                    workerVM.actionDeviceVMs = workerDeviceVMs!
                    break
                case MZWorker.key_state:
                    workerVM.stateDeviceVMs = workerDeviceVMs!
                    break
                default: break
                }
            }
        } else {
            workerDeviceViewModel = filteredWorkers[0]
        }
        
        let workerDeviceItemM = MZBaseWorkerItem(dictionary: ruleDict)
        let workerItemViewModel: MZBaseWorkerItemViewModel = MZBaseWorkerItemViewModel (model: workerDeviceItemM)
        workerItemViewModel.stateDescription = NSAttributedString(string: label)
        
        workerDeviceViewModel!.items.append(workerItemViewModel)
        
        if !isShortcut {
            if isUpdate {
                if isEdit {
                    if type == MZWorker.key_action {
                        //MZAnalyticsInteractor.routineEditEditActionDoneEvent(
                    } else {
                        //MZAnalyticsInteractor.routineEditEditStateDoneEvent(
                    }
                } else {
                    if type == MZWorker.key_action {
                         MZAnalyticsInteractor.workerEditAddActionDoneEvent((workerVM.model?.identifier)!,
                                                                            profileID: workerDeviceViewModel!.model!.tile!.profileId,
                                                                            deviceName: workerDeviceViewModel!.model!.tile!.label)
                    } else {
                        MZAnalyticsInteractor.workerEditAddStateDoneEvent(workerVM.model!.identifier,
                                                                          profileID: workerDeviceViewModel!.model!.tile!.profileId,
                                                                          deviceName: workerDeviceViewModel!.model!.tile!.label)
                    }
                }
            } else {
                if isEdit {
                    if type == MZWorker.key_action {
                        //MZAnalyticsInteractor.routineCreateEditActionDoneEvent(
                    } else {
                        //MZAnalyticsInteractor.routineCreateEditStateDoneEvent(
                    }
                } else {
                    // FIXME:  channel is nil so we cannot get profile name
                    if type == MZWorker.key_action {
                        MZAnalyticsInteractor.workerCreateAddActionDoneEvent(workerDeviceViewModel!.model!.tile!.profileId,
                                                                             deviceName: workerDeviceViewModel!.model!.tile!.label)
                    } else {
                        MZAnalyticsInteractor.workerCreateAddStateDoneEvent(workerDeviceViewModel!.model!.tile!.profileId,
                                                                            deviceName: workerDeviceViewModel!.model!.tile!.label)
                    }
                }
            }
        } else {
            if isUpdate {
                if isEdit {
                    //MZAnalyticsInteractor.shortcutEditEditActionDoneEvent(
                } else {
                    MZAnalyticsInteractor.shortcutEditAddActionDoneEvent(
                        workerVM.model!.identifier,
                        profileID: workerDeviceViewModel!.model!.tile!.profileId,
                        deviceName: workerDeviceViewModel!.model!.tile!.label)
                }
            } else {
                if isEdit {
//                    MZAnalyticsInteractor.shortcutCreateEditActionDoneEvent(                } else {
                    // FIXME: Mixpanel channel is nil so we cannot get profile name
                    MZAnalyticsInteractor.shortcutCreateAddActionDoneEvent(workerDeviceViewModel!.model!.tile!.profileId,
                                                                           deviceName: workerDeviceViewModel!.model!.tile!.label)
                }
            }
        }
        
        return workerVM
    }
    
    
    func getDeviceViewModel(_ channelId: String, componentId: String) -> MZDeviceViewModel?
    {
        if self.currentDevices != nil
        {
            var devices:[MZDeviceViewModel] = []
            for area in self.currentDevices!
            {
                devices.append(contentsOf: area.devicesViewModel)
            }
            
            let filteredDevices = devices.filter ( { (device: MZDeviceViewModel) -> Bool in
                let sameChannelId = device.model!.channelId == channelId
                
                let filteredComponents = device.model!.components.filter {$0.identifier == componentId}
                return (sameChannelId && filteredComponents.count > 0)
            })
            
            if !filteredDevices.isEmpty
            {
                let device: MZDeviceViewModel = filteredDevices[0]
                return device
            }
        }
        
        return nil
    }
    
	
    func createWorker(_ workerVM: MZWorkerViewModel, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        workerVM.updateModel()
        MZWorkersDataManager.sharedInstance.createWorkerForCurrentUser(workerVM.model!, completion: completion)
    }
	
	
    func editWorker(_ workerVM: MZWorkerViewModel, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        workerVM.updateModel()
        MZWorkersDataManager.sharedInstance.updateWorkerForCurrentUser(workerVM.model!, completion: completion)
    }
    
	
    func enableWorker(_ workerVM: MZWorkerViewModel, enabled: Bool, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        MZWorkersDataManager.sharedInstance.enableWorkerForCurrentUser(workerVM.model!.identifier, enabled: enabled, completion: {(result, error) in
            workerVM.enabled = enabled
            completion(result, error)
        })
    }
	
    func executeWorker(_ workerVM: MZWorkerViewModel, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        MZWorkersDataManager.sharedInstance.executeWorkerForCurrentUser(workerVM.model!.identifier, completion: {(result, error) in
            completion(result, error)
        })
    }
    
    func deleteWorker(_ workerVM: MZWorkerViewModel, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
        MZWorkersDataManager.sharedInstance.deleteWorkerForCurrentUser(workerVM.model!.identifier, completion: completion)
    }
    
    //OLD to delete
//    func executeWorker(workerVM: MZWorkerViewModel, completion: (result: AnyObject?, error : NSError?) -> Void)
//    {
//        let executeCommands = workerVM.model!.executeCommands
//        let publishMuzzleyInteractor = PublishToMuzzleyInteractor(MZBaseClient: self.client)
//        for payload in executeCommands
//        {
//            publishMuzzleyInteractor.publishWithNamespace("iot", payload:payload as [NSObject : AnyObject], completion: { (result, error) in
//                //FIX ME trocar o 5 pelo erro
//                if error == nil || error.code == 5
//                {
//                    completion(result: result, error: nil)
//                } else {
//                    completion(result: result, error: error)
//                }
//            } )
//        }
//    }
}
