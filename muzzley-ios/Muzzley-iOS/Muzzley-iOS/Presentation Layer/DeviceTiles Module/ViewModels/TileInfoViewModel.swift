//
//  TileInfoViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 20/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class TileInfoViewModel : TileAttrViewModel {
    var label: String = ""
    var unit: String = ""
	
    override init(model: MZBaseTileAttr)
    {
        super.init(model: model)
        let infoModel = model as! MZTileInformation
		
		self.suffix = infoModel.unit
        self.label = infoModel.label
        self.unit = infoModel.unit
    }
}