//
//  MZContentStyle.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 30/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZContentStyle: NSObject
{
    static let key_margin   = "margin"
    
    
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
