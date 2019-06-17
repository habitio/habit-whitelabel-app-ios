//
//  MZAreaViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 26/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZAreaViewModel: NSObject {
    var title: String = ""
    var devicesViewModel: [MZDeviceViewModel] = [MZDeviceViewModel]()
    
    var model : MZArea?

    override init () {}
    
    convenience init(model : MZArea)
    {
        self.init()
        self.model = model
        
        self.title = model.label
    }
}