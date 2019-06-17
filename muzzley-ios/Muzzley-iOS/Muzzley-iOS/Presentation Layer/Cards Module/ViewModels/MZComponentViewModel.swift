//
//  MZComponentViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 18/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZComponentViewModel: NSObject {
    var title: String = ""
    
    var model : MZComponent?
        
    override init () {}
    
    convenience init(model: MZComponent)
    {
        self.init()
        self.model = model
        //TODO
        self.title = model.type
    }

}
