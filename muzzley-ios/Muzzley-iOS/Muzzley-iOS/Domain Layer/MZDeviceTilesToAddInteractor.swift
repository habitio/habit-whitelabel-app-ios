//
//  MZDeviceTilesToAddInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 15/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZDeviceTilesToAddInteractor: MZDeviceTilesToAddCreateInteractor
{
    static let key_classes = "classes"

    
	override func getDevicesByArea(_ input:AnyObject?, completion: @escaping (_ result:AnyObject?, _ error:NSError?) -> Void)
    {
        var filters:[String:AnyObject]? = input as? [String:AnyObject]
        var classes = [String]()
        var areaId = ""
        if filters != nil
        {
            if let filterClasses:[String] = filters![MZDeviceTilesToAddInteractor.key_classes] as? [String]
            {
                classes = filterClasses
            }
            
            if let filterAreaId:String = filters![MZDeviceTilesToAddCreateInteractor.key_areaId] as? String
            {
                areaId = filterAreaId
            }
        }
        
        self.getNonGroupedDevicesFilterByArea(areaId, filterClasses: classes) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    override func isAreaValid(_ area: MZArea, filterAreaId: String) -> Bool
    {
        return area.children!.count > 0 && (area.identifier == filterAreaId || filterAreaId.isEmpty)
    }
    

}
