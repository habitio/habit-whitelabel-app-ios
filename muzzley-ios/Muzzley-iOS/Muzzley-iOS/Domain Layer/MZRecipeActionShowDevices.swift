//
//  MZRecipeActionShowDevices.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/01/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//


class MZRecipeActionShowDevices
{
    let key_action = "action"
    let key_cancelType = "cancel_type"
    let key_cancelLocalKey = "cancel_local_key"
    
    var action : String?
    var cancelType : String?
    var cancelLocalKey : String?
    
    init(dictionary : NSDictionary)
    {
        if let action = dictionary.value(forKey: self.key_action) as? String
        {
            self.action = action
        }
        if let cancelType = dictionary.value(forKey: self.key_cancelType) as? String
        {
            self.cancelType = cancelType
        }
        
        if let cancelLocalKey = dictionary.value(forKey: self.key_cancelLocalKey) as? String
        {
            self.cancelLocalKey = cancelLocalKey
        }
    }
}
