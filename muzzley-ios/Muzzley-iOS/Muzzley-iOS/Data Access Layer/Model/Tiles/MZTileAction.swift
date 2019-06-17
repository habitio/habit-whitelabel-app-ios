//
//  MZTileAction.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZTileAction: MZBaseTileAttr
{
    static let key_property         = "property"
    static let key_type             = "type"
    static let key_componentType    = "componentType"
    static let key_options          = "options"
    static let key_outputPath       = "outputPath"
    static let key_mappings         = "mappings"
    static let key_icon             = "icon"
    static let valid_type           = "tri-state"
    
    static let type_triState        = "tri-state"
    
    var icon: String                    = ""
    var outputPath: String              = ""
    var mappings: [String: AnyObject]?

    enum Option_icon : String
    {
        case on_off = "on_off"
        case home = "home"
        case lock = "lock"
    }
    
    override init(dictionary: NSDictionary)
    {
        super.init(dictionary: dictionary)
		if (dictionary.isKind(of: NSDictionary.self))
        {
            if let options: NSDictionary = dictionary[MZTileAction.key_options] as? NSDictionary {
                if let icon: String = options[MZTileAction.key_icon] as? String {
                    self.icon = icon
                }
                if let outputPath: String = options[MZTileAction.key_outputPath] as? String {
                    self.outputPath = outputPath
                }
                if let mappings: [String: AnyObject] = options[MZTileAction.key_mappings] as? [String: AnyObject] {
                    self.mappings = mappings
                }
            }
        }
    }
}
