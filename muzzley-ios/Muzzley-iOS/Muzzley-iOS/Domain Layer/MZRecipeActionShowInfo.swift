//
//  MZRecipeActionShowInfo.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 24/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZRecipeActionShowInfo
{
    let key_action = "action"
    let key_navigationBarTitle = "navigation_bar_title"
    let key_title = "title"
    let key_message = "message"
    let key_topImageUrl = "top_image_url"
    let key_bottomImageUrl = "bottom_image_url"
    let key_cancelType = "cancel_type"
    let key_cancelLocalKey = "cancel_local_key"
    let key_nextLocalKey = "next_local_key"
    let key_infoUrl = "info_url"
    
    var action : String?
    var navigationBarTitle : String?
    var title : String?
    var message : String?
    var topImageUrl : String?
    var bottomImageUrl : String?
    var cancelType : String?
    var cancelLocalKey : String?
    var nextLocalKey : String?
    var infoUrl : String?
    
    init(dictionary : NSDictionary)
    {
        if let action = dictionary.value(forKey: self.key_action) as? String
        {
            self.action = action
        }
        
        if let navBarTitle = dictionary.value(forKey: self.key_navigationBarTitle) as? String
        {
            self.navigationBarTitle = navBarTitle
        }
        
        if let title = dictionary.value(forKey: self.key_title) as? String
        {
            self.title = title
        }
        
        if let message = dictionary.value(forKey: self.key_message) as? String
        {
            self.message = message
        }
        
        if let topImageUrl = dictionary.value(forKey: self.key_topImageUrl) as? String
        {
            self.topImageUrl = topImageUrl
        }
        
        if let bottomImageUrl = dictionary.value(forKey: self.key_bottomImageUrl) as? String
        {
            self.bottomImageUrl = bottomImageUrl
        }

        if let cancelType = dictionary.value(forKey: self.key_cancelType) as? String
        {
            self.cancelType = cancelType
        }
        
        if let cancelLocalKey = dictionary.value(forKey: self.key_cancelLocalKey) as? String
        {
            self.cancelLocalKey = cancelLocalKey
        }
        
        if let nextLocalKey = dictionary.value(forKey: self.key_nextLocalKey) as? String
        {
            self.nextLocalKey = nextLocalKey
        }
        
        if let infoUrl = dictionary.value(forKey: self.key_infoUrl) as? String
        {
            self.infoUrl = infoUrl
        }
    }
    
}
