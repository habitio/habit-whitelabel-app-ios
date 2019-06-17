//
//  MZTileAreaViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZTileAreaViewModel : NSObject {
    var title: String = ""
    var tilesViewModel : [MZAreaChildViewModel] = [MZAreaChildViewModel]()
    
    var model : MZArea?
    
    override init () {}
    
    convenience init(model : MZArea)
    {
        self.init()
        self.model = model
        
        self.title = model.label
    }
}