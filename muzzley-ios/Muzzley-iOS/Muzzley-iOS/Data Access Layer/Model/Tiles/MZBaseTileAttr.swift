//
//  MZBaseTileAttr.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 28/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZBaseTileAttr: NSObject {
    var propertyId : String     = ""
    var type : String           = ""
    var componentId: String     = ""
    var componentType: String   = ""
    var inputPath: String       = ""

    init(dictionary: NSDictionary)
    {
		if (dictionary.isKind(of: NSDictionary.self))
        {
            if let propertyId : String = dictionary[MZTileInformation.key_property] as? String {
                self.propertyId = propertyId
            }
            if let type : String = dictionary[MZTileInformation.key_type] as? String {
                self.type = type
            }
            if let componentType : String = dictionary[MZTileInformation.key_componentType] as? String {
                self.componentType = componentType
            }
            if let options : NSDictionary = dictionary[MZTileInformation.key_options] as? NSDictionary {
                if let inputPath: String = options[MZTileInformation.key_inputPath] as? String {
                    self.inputPath = inputPath
                }
            }
        }
    }

}
