//
//  MZArea.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZArea : NSObject
{
    static let key_id       = "id"
    static let key_label    = "label"
    static let key_tiles    = "tiles"
    static let key_groups   = "groups"
    
    var identifier : String
    var label : String
    var children : NSMutableArray?
    
    override init()
    {
        identifier = ""
        label = ""
        children = NSMutableArray()
        
        super.init()
    }
    
    
    convenience init(dictionary: NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {        
            if let identifier: String = dictionary[MZArea.key_id] as? String {
                self.identifier = identifier
            }
            if let label: String = dictionary[MZArea.key_label] as? String {
                self.label = label
            }
        }
        
    }
    
}
