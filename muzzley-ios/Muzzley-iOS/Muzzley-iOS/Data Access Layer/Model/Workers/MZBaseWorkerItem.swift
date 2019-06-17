//
//  MZBaseWorkerItem.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 17/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZBaseWorkerItem: NSObject
{
    static let key_label        = "label"

    var label : String = ""
        
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    init(dictionary: NSDictionary)
    {
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let label : String = dictionary[MZBaseWorkerItem.key_label] as? String {
                self.label = label
            }
        }
    }
}
