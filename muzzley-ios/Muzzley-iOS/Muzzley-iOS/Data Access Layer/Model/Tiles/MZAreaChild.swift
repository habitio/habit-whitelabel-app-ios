//
//  MZChild.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZAreaChild: NSObject
{
    static let key_id       = "id"
    static let key_label    = "label"
    
    var identifier: String = ""
    var label : String = ""
    var interfaceUUID : String = ""
    var interfaceETAG : String = ""
    var native: [MZNativeComponent] = []
    
    var parent : AnyObject?
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    init(dictionary: NSDictionary)
    {
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary

            if let identifier: String = dictionary[MZAreaChild.key_id] as? String {
                self.identifier = identifier
            }
            if let label: String = dictionary[MZAreaChild.key_label] as? String {
                self.label = label
            }
        }
        
    }
}
