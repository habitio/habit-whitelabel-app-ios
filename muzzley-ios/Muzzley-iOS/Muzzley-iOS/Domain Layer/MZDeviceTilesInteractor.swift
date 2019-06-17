//  MZDeviceTilesInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 07/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

@objc protocol MZDeviceTilesInteractorDelegate {
	@objc optional func deviceViewModelsDidUpdate(_ devices: [MZTileAreaViewModel])
}

class MZDeviceTilesInteractor: MZDeviceListInteractor
{
	var delegate: MZDeviceTilesInteractorDelegate?
	var devices: [MZTileAreaViewModel] = [MZTileAreaViewModel]()
    
	override init()
	{
		super.init()
		
		NotificationCenter.default.addObserver(self, selector: #selector(MZDeviceTilesInteractor.didSubscribeMQTT), name: NSNotification.Name(rawValue: MQTTDidSubscribe), object: nil)
		// Notifications registrations
		MZNotifications.register(self, selector: #selector(MZDeviceTilesInteractor.updateTilesUnitValues), notificationKey: MZNotificationKeys.UserProfile.UnitsSystemUpdated)
		
        if(MZMQTTConnection.sharedInstance.subscribedChannels.contains(MZTopicParser.createSubscribeAllChannelsTopic(MZSession.sharedInstance.authInfo!.userId)))
        {
            dLog("Entered New did subscribe")
            self.didSubscribeMQTT()
        }
        
        MZMQTTConnection.sharedInstance.listenToMqttDidDisconnect { () in
            dLog("DISCONNECTED MQTT")
        }
        
        
	}
	
	
	func configureSearchFilter(_ searchField: UITextField, shouldFilter: @escaping (_ searchString: String?) -> Void)
	{
		let _ = searchField.rx.text.debounce(0.5, scheduler: MainScheduler.instance).subscribe { (event) -> Void in
						shouldFilter(event.element as! String)
			}

//		let _ = searchField.rx_text.debounce(0.5, scheduler: MainScheduler.instance).subscribe { (event) -> Void in
//			shouldFilter(searchString: event.element)
//		}
	}
	
	
	func getDevicesByAreasAndGroups(_ completion: @escaping (_ result: AnyObject?,_ error: NSError?) -> Void)
	{
		self.getAllDevicesVM({ (result, error) -> Void in
			if error == nil
			{
				self.devices = result as! [MZTileAreaViewModel]
                
				self.requestDevicesPropertiesViaMQTT()
			}
			
			completion(result, error)
		})
	}
	
	
	func addTilesToGroup(_ groupVM: MZTileGroupViewModel, newTilesVM: [MZDeviceViewModel], completion: @escaping (_ error : NSError?) -> Void)
	{
		let newTileModels: [MZTile] = convertDeviceViewModel(newTilesVM)
		
		let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
		tilesDM.addTilesToGroup(newTileModels, group: groupVM.model as! MZGroup, completion: { (error) -> Void in
			if error == nil
			{
				for tileVM : MZDeviceViewModel in newTilesVM
				{
					let deviceTileVM : MZTileViewModel = MZTileViewModel (model: tileVM.model!)
					groupVM.tilesViewModel.append(deviceTileVM)
				}
				completion(nil )
			} else {
				completion (error)
			}
		})
	}
	
	
	func removeTileFromGroup(_ groupVM: MZTileGroupViewModel, removedTileMV: MZTileViewModel, completion: @escaping (_ error : NSError?) -> Void)
	{
		let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
		tilesDM.removeTileFromGroup(removedTileMV.model as! MZTile, group: groupVM.model as! MZGroup) { (error) -> Void in
			if error == nil
			{
				groupVM.tilesViewModel = groupVM.tilesViewModel.filter() { $0.model?.identifier != removedTileMV.model?.identifier }
				completion(nil)
			} else {
				completion (error)
			}
		}
	}
	
	
	func ungroup(_ groupVM: MZTileGroupViewModel, completion: @escaping (_ error : NSError?) -> Void)
	{
		let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
		tilesDM.ungroup(groupVM.model as! MZGroup) { (error) -> Void in
			if error == nil
			{
				completion(nil)
			} else {
				completion (error)
			}
		}
	}
	
	
	func editGroupName(_ groupVM: MZTileGroupViewModel, completion: @escaping (_ error : NSError?) -> Void)
	{
		let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
		tilesDM.updateGroupForCurrentUser(groupVM.model as! MZGroup, completion: completion)
	}
	
	
	func editDeviceName(_ deviceVM: MZTileViewModel, completion: @escaping (_ error : NSError?) -> Void)
	{
		let tilesDM: MZTilesDataManager = MZTilesDataManager.sharedInstance
		let tile: MZTile = deviceVM.model as! MZTile
		
		let observable = tilesDM.getObservableOfUpdateTileForCurrentUser(tile)
		observable.subscribe(onNext: { (result) in
			//
		}, onError: { (Error) in
			// FIXME:  error info
			MZAnalyticsInteractor.deviceEditFinishEvent(deviceVM.model as! MZTile, errorMessage: "")
			completion (NSError(domain:Bundle.main.bundleIdentifier!, code:0, userInfo:nil))
		}, onCompleted: {
			MZAnalyticsInteractor.deviceEditFinishEvent(deviceVM.model as! MZTile, errorMessage: nil)
			completion (nil)
		}, onDisposed: {})
		
//		observable.subscribeCompleted { () -> Void in
//			MZAnalyticsInteractor.deviceEditFinishEvent(deviceVM.model as! MZTile, errorMessage: nil)
//			completion (error: nil)
//		}
//		observable.subscribeError { (error) -> Void in
//			// FIXME:  error info
//			MZAnalyticsInteractor.deviceEditFinishEvent(deviceVM.model as! MZTile, errorMessage: "")
//			completion (error: NSError(domain:Bundle.main.bundleIdentifier!, code:0, userInfo:nil))
//		}
	}
	
	
	func deleteDevice(_ tileMV: MZTileViewModel, completion: @escaping (_ error : NSError?) -> Void)
	{
		let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
		tilesDM.deleteTile(tileMV.model as! MZTile, completion: { (error) -> Void in
			if error == nil
			{
				completion(nil)
			} else {
				completion (error)
			}
		})
	}
	
	
	func createGroupVM(_ label: String, newTilesVM: [MZDeviceViewModel], completion: @escaping (_ error: NSError?) -> Void)
	{
		let newTileModels: [MZTile] = convertDeviceViewModel(newTilesVM)
		var area: MZArea
		if let parent: MZGroup = newTileModels[0].parent as? MZGroup
		{
			area = getParentArea(parent)!
		} else
		{
			area = getParentArea(newTileModels[0])!
		}
		
		let tilesDM: MZTilesDataManager = MZTilesDataManager.sharedInstance
		tilesDM.createGroupForCurrentUser(label, tiles: newTileModels, area: area, completion: { (error) -> Void in
			if error == nil
			{
				completion(nil)
			} else {
				completion (error)
			}
		})
	}
	
	fileprivate func convertDeviceViewModel (_ tilesVM: [MZDeviceViewModel]) -> [MZTile]
	{
		var tileModels: [MZTile] = [MZTile]()
		
		for tilesVM: MZDeviceViewModel in tilesVM
		{
			let tileModel: MZTile = tilesVM.model!
			tileModels.append(tileModel)
		}
		
		return tileModels
	}
	
	
	fileprivate func getParentArea(_ child: MZAreaChild) -> MZArea?
	{
		if let parent: MZArea = child.parent! as? MZArea
		{
			return parent
		}
		return nil
	}
	
	
	func sendStatusToDevice(_ device: MZAreaChildViewModel, completion: ((_ result: AnyObject?, _ error: NSError?) -> Void)?)
	{
		if let tile: MZTile = device.model! as? MZTile
		{
			if tile.actions.isEmpty
			{
//				dLog(message: "sendStatusToDevice ignored!!")
				completion?(nil, NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			
			let stateKey = (device.tileActionViewModel!.state == TileActionViewModelState.on) ? "on" : "off"
			//let paths = tile.actions[0].outputPath.characters.split{$0 == "."}.map(String.init)
			
			if tile.actions[0].mappings == nil {
				completion?(nil, NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			
			var child: AnyObject? = tile.actions[0].mappings![stateKey]
			if child == nil {
				completion?(nil, NSError(domain: "", code: 0, userInfo: nil))
				return
			}
			
			let dic = NSMutableDictionary()
			dic.addEntries(from: ["io": "w", "data":child!])
			
			let topic =	MZTopicParser.createPublishTopic(tile.channel!.identifier, componentId: tile.actions[0].componentId, propertyId: tile.actions[0].propertyId)
			
			if(!topic.isEmpty)
			{
				MZMQTTConnection.sharedInstance.publish(topic, jsonDict: dic, completion:nil)
			}
		} else {
			//TODO create group case
			//            MZAnalyticsInteractor.manualInteractionEvent(
		}
		
	}
    
    
    func didSubscribeMQTT()
    {
		MZMQTTConnection.sharedInstance.listenToDidReceiveMessage { (mqttMessage) in
			self.processMQTTResponse(mqttMessage)
		}
	
		requestDevicesPropertiesViaMQTT()

    }
	
	fileprivate func requestDevicesPropertiesViaMQTT()
	{
		for area in devices
		{
			for device in area.tilesViewModel
			{
				if let tile: MZTile = device.model! as? MZTile
				{
					self.requestDeviceUpdateViaMQTT(area, channelId: tile.remoteId, profileId: tile.profileId)
				}
			}
		}
	}
	
	fileprivate func requestDeviceUpdateViaMQTT(_ areaVM: MZTileAreaViewModel, channelId: String, profileId: String)
	{
		let filteredTiles = self.filteredTiles(areaVM, channelId: channelId)
		for childVM in filteredTiles
		{
			if let tile: MZTile = childVM.model as? MZTile
			{
				let payload: [String:AnyObject] = ["io":"r" as AnyObject]
				
				for information in tile.informations
				{
					let topic = MZTopicParser.createPublishTopic(tile.channel!.identifier, componentId: information.componentId, propertyId: information.propertyId)
					
					MZMQTTConnection.sharedInstance.publish(topic, jsonDict: payload as NSDictionary, completion: nil)
				}
				
				for action in tile.actions
				{
					let topic = MZTopicParser.createPublishTopic(tile.channel!.identifier, componentId: action.componentId, propertyId: action.propertyId)

					MZMQTTConnection.sharedInstance.publish(topic, jsonDict: payload as NSDictionary, completion: nil)
				}
			}
		}
	}

	
	fileprivate func filteredTiles(_ areaVM: MZTileAreaViewModel, channelId: String) -> [MZAreaChildViewModel]
	{
		var filteredTiles = areaVM.tilesViewModel.filter() {
			if let tileModel = $0.model as? MZTile
			{
				return tileModel.remoteId == channelId
			}
			return false
		}
		
		let filteredGroup = areaVM.tilesViewModel.filter() {
			$0.model is MZGroup
		}
		
		for groupVM in filteredGroup as! [MZTileGroupViewModel]
		{
			let filteredTilesInGroup = groupVM.tilesViewModel.filter() {
				if let tileModel = $0.model as? MZTile
				{
					return tileModel.remoteId == channelId
				}
				return false
			}
			
			filteredTiles.append(contentsOf: filteredTilesInGroup)
		}
		
		return filteredTiles
	}
	
	
	fileprivate func getAreaTiles(_ areaVM: MZTileAreaViewModel) -> [MZAreaChildViewModel]
	{
		var filteredTiles = areaVM.tilesViewModel.filter() {
			if let tileModel = $0.model as? MZTile
			{
				return true
			}
			return false
		}
		
		let filteredGroup = areaVM.tilesViewModel.filter() {
			$0.model is MZGroup
		}
		
		
		for groupVM in filteredGroup as! [MZTileGroupViewModel]
		{
			let filteredTilesInGroup = groupVM.tilesViewModel.filter() {
				if let tileModel = $0.model as? MZTile
				{
					return true
				}
				return false
			}
			
			filteredTiles.append(contentsOf: filteredTilesInGroup)
		}
		
		return filteredTiles
	}
	
	
	@objc func updateTilesUnitValues()
	{
		for areaVM in devices
		{
			let tiles = self.getAreaTiles(areaVM)
			for childVM in tiles
			{
				if let tileVM = childVM as? MZTileViewModel
				{
					updateTileUnits(tileVM.tileInformations)
				}
			}
		}
		self.delegate?.deviceViewModelsDidUpdate?(self.devices)
		//MZNotifications.send(MZNotificationKeys.Tiles.Reload, obj: nil)
	}
	
	
	func updateTileUnits(_ attrViewModels:[TileAttrViewModel])
	{
		for attrVM in attrViewModels
		{
			if let attrM : MZTileInformation = attrVM.model! as? MZTileInformation
			{
				if attrM.type == MZTileInformation.type_unit
				{
		
					if !attrM.muzzleyUnit.isEmpty
					{
						if !attrM.targetMetric.isEmpty && !attrM.targetImperial.isEmpty
						{
							switch MZSessionDataManager.sharedInstance.session.userProfile.preferences.units
							{
							case "metric":
								
								attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.targetMetric)
								if(attrVM.valueRaw != nil)
								{
									let convertedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.convertUnits(attrM.muzzleyUnit, targetUnitKey: attrM.targetMetric, value: attrVM.valueInDefaultUnit!)
									attrVM.valueRaw = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.targetMetric, value: convertedValue as! Double) as AnyObject
								}
								break
								
							case "imperial":
								
								attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.targetImperial)
						
								if(attrVM.valueRaw != nil)
								{
									let convertedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.convertUnits(attrM.muzzleyUnit, targetUnitKey: attrM.targetImperial, value: attrVM.valueInDefaultUnit!)
									attrVM.valueRaw = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.targetImperial, value: convertedValue as! Double) as AnyObject
								}
								
								break
								
							default:
								break
							}
						}
						else
						{
							if(attrVM.valueRaw != nil)
							{
							
								let val = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.muzzleyUnit, value: attrVM.valueRaw as! Double)
								if(val != attrVM.valueRaw as? Double)
								{
									attrVM.valueRaw = val as AnyObject
								}
								attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.muzzleyUnit)
							}
						}
					}
				}
			}
		}
	}
	
	
	fileprivate func processMQTTResponse(_ mqttMessage:MZMQTTMessage)
	{
		var updated = false
		let topicInfo = MZTopicParser.getTopicComponents(MZEndpoints.mqttCoreVersion(), topic: mqttMessage.topic)
		
//        dLog ("processMQTTResponse mqttMessage: \(mqttMessage.topic)\n\(mqttMessage.message)")
        
		if let io = mqttMessage.message["io"] as?  String
		{
			if !io.hasPrefix("i")
			{
//                dLog ("Response ignored - not i or ir")
				return
			}
		}
		else
		{
			return
		}
		
//		if let data: NSDictionary = mqttMessage.message["data"] as? NSDictionary
//		{
			if topicInfo.channelId.isEmpty || topicInfo.componentId.isEmpty || topicInfo.propertyId.isEmpty
			{
				//dLog ("Response ignored!")
				return
			}
						
			let channel:String = topicInfo.channelId
			let component:String = topicInfo.componentId
			let property:String = topicInfo.propertyId
			
			let filteredAreas = devices.filter {
                let filteredTiles = self.filteredTiles($0, channelId: channel)
                return !filteredTiles.isEmpty
			}
						
			for areaVM in filteredAreas
			{
				let filteredTiles = self.filteredTiles(areaVM, channelId: channel)
				for childVM in filteredTiles
				{
					if let tileVM = childVM as? MZTileViewModel
					{
						if !(mqttMessage.message["data"] is NSNull)
						{
							updated = MZDeviceInteractorHelper.setAttrViewModelValue(tileVM.tileInformations, component: component, property: property, value: mqttMessage.message.value(forKey: "data") as AnyObject)
							
							if tileVM.tileActionViewModel != nil && !updated
							{
								updated = MZDeviceInteractorHelper.setAttrViewModelValue([tileVM.tileActionViewModel!], component: component, property: property, value: mqttMessage.message.value(forKey: "data") as AnyObject)
							}
							if tileVM.iconViewModel != nil && !updated
							{
								updated = MZDeviceInteractorHelper.setAttrViewModelValue([tileVM.iconViewModel!], component: component, property: property, value: mqttMessage.message.value(forKey: "data") as AnyObject)
							}
							
							if updated
							{
								break;
							}
						}
					}
					
					if updated
					{
						break;
					}
				}
			}
//		}
		
		if updated
		{
			self.delegate?.deviceViewModelsDidUpdate?(self.devices)
		}
	}
    
    
    func getVideoStreamURL(_ tileVM : MZTileViewModel)
    {
        let videoStreamClass = "com.muzzley.properties.url.stream"
        self.getValueForProperty(tileVM, propertyClass:videoStreamClass)
    }
	
    
    func getAudioStreamURL(_ tileVM : MZTileViewModel)
    {
        let audioStreamClass = "com.muzzley.properties.url.stream.audio"
        self.getValueForProperty(tileVM, propertyClass:audioStreamClass)
    }
	
    func getValueForProperty(_ tileVM : MZTileViewModel, propertyClass : String)
    {
        let tile = tileVM.model as! MZTile
        
        for component in tile.components
        {
            if component.propertiesClasses.contains(propertyClass)
            {
                var filteredProperty = component.properties.filter({ (property) -> Bool in
                    property.classes.contains(propertyClass)
                })
                
                if !filteredProperty.isEmpty
                {
                    
                }
            }
        }
    }
}
