//
//  MZRecipeActionGrantAppAccess.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/01/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//

class MZRecipeActionGrantAppAccess
{
    let key_action = "action"
    
    var action : String?
    
    init(dictionary : NSDictionary)
    {
        if let action = dictionary.value(forKey: self.key_action) as? String
        {
            self.action = action
        }
    }
}
