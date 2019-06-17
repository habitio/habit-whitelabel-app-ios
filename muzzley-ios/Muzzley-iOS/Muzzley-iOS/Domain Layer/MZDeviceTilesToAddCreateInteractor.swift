//
//  MZDeviceTilesToAddCreateInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 05/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//


class MZDeviceTilesToAddCreateInteractor: MZDeviceTilesInteractor {
    
    static let key_areaId = "areaId"

	override func getDevicesByArea(_ input:AnyObject?, completion: @escaping (_ result:AnyObject?, _ error:NSError?) -> Void)
    {
        var filters:[String:AnyObject]? = input as? [String:AnyObject]
        var areaId = ""
        if filters != nil
        {
            if let filterAreaId:String = filters![MZDeviceTilesToAddCreateInteractor.key_areaId] as? String
            {
               areaId = filterAreaId
            }
        }
        
        self.getNonGroupedDevicesFilterByArea(areaId) { (result, error) -> Void in
            completion(result, error)
        }
    }
	
    
    func getNonGroupedDevicesFilterByArea(_ filterAreaId: String, filterClasses: [String] = [], completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        self.getAllDevices ({ (results, error) -> Void in
            if error == nil
            {
                if let arrayResults : [AnyObject] = results as? [AnyObject]
                {
                    let resultTiles : [MZArea] = arrayResults[0] as! [MZArea]
                    let resultChannels : [String : MZChannel] = arrayResults[1] as! [String : MZChannel]
                    var areaViewModels = [MZAreaViewModel] ()
                    
                    for area : MZArea in resultTiles
                    {
                        if self.isAreaValid(area, filterAreaId: filterAreaId)
                        {
                            if let areaVM : MZAreaViewModel = self.addDeviceViewModelToArea(area, channels: resultChannels, filterClasses: filterClasses as [AnyObject])
                            {
                                if self.isAreaViewValid(areaVM)
                                {
                                    areaViewModels.append(areaVM)
                                }
                            }
                        }
                    }
                    completion(areaViewModels as AnyObject, nil)
                }
            } else {
                completion(nil, error)
            }
        })
    }

    
    func isAreaValid(_ area: MZArea, filterAreaId: String) -> Bool
    {
        return true
    }
    
    func isAreaViewValid(_ areaVM : MZAreaViewModel) -> Bool
    {
        return true
    }
    
    override func isTileValid(_ tile: MZTile) -> Bool
    {
        if let _ = tile.parent as? MZArea
        {
			return tile.isGroupable
        }
        
        return false
    }
}
