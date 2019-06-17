//
//  MZPlaceholderViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZDeviceChoicePlaceholderViewModel: NSObject {
    
    static let key_component = "component"
    static let key_profileId = "profileId"
    static let key_remoteId = "remoteId"
    static let key_classes = "classes"

    var deviceId: String = ""
    var componentId: String = ""
    var profileId: String = ""
    var remoteId: String = ""
    var classes: [String] = [String]()

    var deviceTitle: String = ""
    var componentTitle: String = ""
    
    var availableComponents:[MZComponentViewModel] = []
    var selectedComponents:[MZComponentViewModel] = []
    
    var model: MZTile?
    
    override init()
    {
        
    }
    
    convenience init(model:MZTile) {
        self.init()
        self.model = model
        self.deviceId = model.identifier
    }
    
    func convertToDeviceViewModel() -> MZDeviceViewModel? {
        if self.model != nil {
            let deviceVM: MZDeviceViewModel = MZDeviceViewModel(model: self.model!)
            deviceVM.title = self.deviceTitle
            deviceVM.id = self.deviceId
            
            return deviceVM
        } else {
            return nil
        }
    }
    
}
