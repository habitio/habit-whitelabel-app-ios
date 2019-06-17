//
//  MZRecipeActionOAuth.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 26/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZRecipeActionOAuth
{
    let key_action = "action"
    let key_authorizationUrl = "authorization_url"
    let key_cancelType = "cancel_type"
    let key_cancelLocalKey = "cancel_local_key"

    
    var action : String?
    var authorizationUrl : String?
    var cancelType : String?
    var cancelLocalKey : String?

    init(dictionary : NSDictionary)
    {
        if let action = dictionary.value(forKey: self.key_action) as? String
        {
            self.action = action
        }
        
        if let authorizationUrl = dictionary.value(forKey: self.key_authorizationUrl) as? String
        {
            self.authorizationUrl = authorizationUrl
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
