//
//  MZDeviceListInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

import RxSwift

class MZDeviceListInteractor: MZBaseInteractor
{
    let disposeBag = DisposeBag()
    
    func getAllDevicesVM (_ completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void, parameters: NSDictionary? = nil)
    {
        self.getAllDevices ({ (results, error) -> Void in
            if error == nil {
                var areaViewModels = [MZTileAreaViewModel] ()
                
                if let arrayResults : [AnyObject] = results as? [AnyObject]
                {
                    let resultTiles : [MZArea] = arrayResults[0] as! [MZArea]
                    if let resultChannels : [String : MZChannel] = arrayResults[1] as? [String : MZChannel]
                    {
                        if !resultChannels.isEmpty
                        {
                            for area : MZArea in resultTiles
                            {
                                if let areaVM : MZTileAreaViewModel = self.processArea(area, channels: resultChannels)
                                {
                                    areaViewModels.append(areaVM)
                                }
                            }
                        }
                    }
                }
                completion(areaViewModels as AnyObject, nil)
            } else {
                completion(nil, error)
            }
            }, parameters: parameters)
    }
    
    func getAllDevices(_ completion: @escaping (_ results: Any?, _ error: NSError?) -> Void, parameters: NSDictionary? = nil)
    {
        let tilesDM : MZTilesDataManager = MZTilesDataManager.sharedInstance
        let channelDM : MZChannelsDataManager = MZChannelsDataManager.sharedInstance
		
        var tasks: [Observable<Any>] = []
        
        tasks.append(tilesDM.getObservableOfTilesByAreaForCurrentUser(parameters))
        tasks.append(channelDM.getObservableOfChannelForCurrentUser(parameters))

		Observable<Any>.zip(tasks) {return $0}
			.subscribe(onNext: { (results)  in
					completion(results, nil)
				}, onError: { (error) in
					completion(nil, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
				}, onCompleted: {
				}, onDisposed: {}
			)
			.addDisposableTo(disposeBag)
    }
    
    func processArea (_ area: MZArea, channels: [String : MZChannel]) -> MZTileAreaViewModel?
    {
        let areaVM: MZTileAreaViewModel = MZTileAreaViewModel(model: area)
        var groupVM: MZTileGroupViewModel?
        
        for child in area.children! as NSMutableArray
        {
            if let group : MZGroup = child as? MZGroup
            {
                groupVM = MZTileGroupViewModel (model: group)
                groupVM!.title = group.label
                groupVM!.state = TileState.loaded
                groupVM!.parentViewModel = areaVM
                areaVM.tilesViewModel.append(groupVM!)
                
                var channelsJSON: [NSDictionary] = []
                var tilesJSON: [NSDictionary] = []
                
                for groupChild in group.children
                {
                    if let tile : MZTile = groupChild
                    {
                        if tile.updateWithChannel(channels)
                        {
                            let tileVM : MZTileViewModel = self.setTileVM(tile)
                            groupVM!.tilesViewModel.append(tileVM)
                            tileVM.parentViewModel = groupVM!
                            
                            channelsJSON.append(tile.channel!.dictionaryRepresentation)
                            tilesJSON.append(tile.dictionaryRepresentation)
                            
                            if groupVM!.interfaceETAG!.isEmpty
                            {
                                groupVM?.interfaceUUID = tile.interfaceUUID
                                groupVM?.interfaceETAG = tile.interfaceETAG
                                groupVM?.channelID = tile.channel!.identifier
                            }
                            
                        }
                    }
                }
                
                groupVM?.bridgeOptions = ["channels" : channelsJSON as AnyObject, "tiles": tilesJSON as AnyObject, "capabilities": MZHardwareCapabilities.supportedCapabilities as AnyObject]
            }
            else if let tile : MZTile = child as? MZTile
            {
                if tile.updateWithChannel(channels)
                {
                    
                    let tileVM : MZTileViewModel = self.setTileVM(tile)
                    areaVM.tilesViewModel.append(tileVM)
                    tileVM.parentViewModel = areaVM
                }
            }
        }
        
        if(!areaVM.tilesViewModel.isEmpty)
        {
            return areaVM
        }
        
        return nil
    }
    
    
    func setTileVM(_ tile : MZTile) -> MZTileViewModel
    {
        let tileVM : MZTileViewModel = MZTileViewModel (model: tile as MZAreaChild)
        tileVM.state = TileState.loaded
        
        //TODO should move to MZTileViewModel init?
        if(tile.informations.count > 0)
        {
            var i = 0
            var info = tile.informations[i]
            
            if info.type == MZTileInformation.type_icon
            {
                let infoVM : TileIconViewModel = TileIconViewModel (model: info)
                tileVM.iconViewModel = infoVM
                i += 1
            }
            
            while i < tile.informations.count
            {
                info = tile.informations[i]
                let infoVM : TileInfoViewModel = TileInfoViewModel (model: info)
                tileVM.tileInformations.append(infoVM)
                i += 1
            }
        }
        
        for action in tile.actions
        {
            if action.type == MZTileAction.valid_type
            {
                let actionVM : TileActionViewModel = TileActionViewModel (model: action)
                tileVM.tileActionViewModel = actionVM
            }
        }
        
        
        for component in tile.components
        {
            for property in component.properties
            {
                let propertyVM : MZPropertyViewModel = MZPropertyViewModel (model: property)
                tileVM.tileProperties.append(propertyVM)
            }
        }
        
        
		tileVM.bridgeOptions = ["channels": [tile.channel!.dictionaryRepresentation],
		                        "tiles": [tile.dictionaryRepresentation],
		                        "capabilities": MZHardwareCapabilities.supportedCapabilities]
		
        return tileVM
    }
    
    
    func addDeviceViewModelToArea (_ area : MZArea, channels : [String : MZChannel], filterClasses: [AnyObject] = []) -> MZAreaViewModel?
    {
        let areaVM : MZAreaViewModel = MZAreaViewModel(model: area)
        
        for child in area.children! as NSMutableArray
        {
            if let tile : MZTile = child as? MZTile
            {
                if isTileValid(tile)
                {
                    if let deviceVM: MZDeviceViewModel = self.getDeviceViewModel(tile, channels: channels, areaVM: areaVM, filterClasses:filterClasses)
                    {
                        areaVM.devicesViewModel.append(deviceVM)
                    }
                }
            } else {
                let group: MZGroup = child as! MZGroup
                for tile in group.children
                {
                    if isTileValid(tile)
                    {
                        if let deviceVM: MZDeviceViewModel = self.getDeviceViewModel(tile, channels: channels, areaVM: areaVM, filterClasses:filterClasses)
                        {
                            areaVM.devicesViewModel.append(deviceVM)
                        }
                    }
                }
            }
        }
        
        if(!areaVM.devicesViewModel.isEmpty)
        {
            return areaVM
        }
        
        return nil
    }
    
    
    func getDeviceViewModel(_ tile:MZTile, channels : [String : MZChannel], areaVM: MZAreaViewModel, filterClasses: [AnyObject]) -> MZDeviceViewModel?
    {
        if tile.updateWithChannel(channels)
        {
            let result = MZBaseInteractor.isArrayContainsAnyArray(tile.componentClasses as [AnyObject], lookFor: filterClasses)
            if !result && !filterClasses.isEmpty
            {
                return nil
            }
            let deviceVM: MZDeviceViewModel = MZDeviceViewModel (model: tile as MZTile)
            deviceVM.parent = areaVM
            return deviceVM
        }
        return nil
    }
    
    
	func getDevicesByArea(_ input:AnyObject?, completion: @escaping (_ result:AnyObject?, _ error:NSError?) -> Void)
    {
        //
    }
    
    func isTileValid(_ tile: MZTile) -> Bool
    {
        return true
    }
    
    func getFilteredDevices(_ device: MZDeviceViewModel, devices:[MZAreaViewModel], selectedDevices:[MZDeviceViewModel]) -> [MZAreaViewModel]?
    {
        return nil
    }
    
}
