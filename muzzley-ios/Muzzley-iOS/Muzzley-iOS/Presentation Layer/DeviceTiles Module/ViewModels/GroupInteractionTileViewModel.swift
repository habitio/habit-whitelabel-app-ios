//
//  GroupInteractionTileViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class GroupInteractionTileViewModel: MZAreaChildViewModel {
    var iconName = "IconControlAll"
    var isDetail: Bool = false
    
    override init()
    {
        super.init()
        self.title = NSLocalizedString("mobile_group_control", comment: "")
    }
    
    override init(model : MZAreaChild)
    {
        super.init(model: model)
        self.title = NSLocalizedString("mobile_group_control", comment: "")
    }
}
