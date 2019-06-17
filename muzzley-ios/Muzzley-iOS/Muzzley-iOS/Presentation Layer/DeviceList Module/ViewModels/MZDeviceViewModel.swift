//
//  MZDeviceViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 26/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZDeviceViewModel: NSObject {
    var title: String = ""
    var imageUrlAlt: URL?
    var id: String = ""

    var model : MZTile?
    
    var parent: MZAreaViewModel?
    
    override init () {}
    
    convenience init(model : MZTile)
    {
        self.init()
        self.model = model
        self.id = model.identifier
        self.title = model.label
        self.imageUrlAlt = model.photoUrlAlt
    }
}
