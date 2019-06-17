//
//  MZRangeStyle.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZRangeStyle: NSObject
{
    static let key_bold           = "bold"
    static let key_underline      = "underline"
    static let key_italic         = "italic"
    static let key_color          = "color"
    static let key_fontSize       = "fontSize"
    static let key_range          = "range"


    var dictionaryRepresentation: NSDictionary = NSDictionary()

    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
        }
    }
}
