//
//  MZDeviceTilesToCreateInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 15/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZDeviceTilesToCreateInteractor: MZDeviceTilesToAddCreateInteractor
{
    override func isAreaValid(_ area: MZArea, filterAreaId: String) -> Bool
    {
        return area.children!.count > 1  && (area.identifier == filterAreaId || filterAreaId.isEmpty)
    }
    
    override func isAreaViewValid(_ areaVM : MZAreaViewModel) -> Bool
    {
        return areaVM.devicesViewModel.count > 1
    }
    
    override func getFilteredDevices(_ device: MZDeviceViewModel, devices:[MZAreaViewModel], selectedDevices:[MZDeviceViewModel]) -> [MZAreaViewModel]?
    {
        if devices.isEmpty
        {
            return nil
        }
        
        let filteredAreas = devices.filter{$0.model!.identifier == device.parent!.model!.identifier}
        if !filteredAreas.isEmpty
        {
            var validClasses: [AnyObject] = (selectedDevices[0].model?.componentClasses)! as [AnyObject]
            selectedDevices.forEach({ (selectedDevice) -> () in
                validClasses = MZBaseInteractor.array(ofCommonElements: selectedDevice.model!.componentClasses as [AnyObject], lookFor: validClasses) as! [AnyObject]
            })
            
            let filteredDevices = filteredAreas[0].devicesViewModel.filter{
                MZBaseInteractor.isArrayContainsAnyArray($0.model!.componentClasses as [AnyObject], lookFor: validClasses)
            }
            
            let result = MZAreaViewModel(model:filteredAreas[0].model!)
            result.devicesViewModel = filteredDevices
            return [result]
        }
        
        return nil
    }
}
