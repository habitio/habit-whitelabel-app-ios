//
//  MZGroup.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZGroup: MZAreaChild
{
    static let key_tiles    = "tiles"
    static let key_parent   = "parent"
    
    var children : [MZTile]
    
    override init(dictionary: NSDictionary)
    {
        children = [MZTile] ()
        super.init(dictionary: dictionary)
    }
}
