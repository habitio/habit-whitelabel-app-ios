//
//  MZChannelTemplate.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZProfileKeys
{
    static let key_id = "id"
    static let key_name = "name"
    static let key_termsUrl = "termsUrl"
    static let key_photoUrl = "photoUrl"
    static let key_photoUrlSquared = "photoUrlSquared"
    static let key_provider = "provider"
    static let key_requiredCapability = "requiredCapability"
    static let key_openOauthInBrowser = "openOauthInBrowser"
}

@objc class MZChannelTemplate: NSObject
{
    static let key_id = "id"
    static let key_name = "name"
    static let key_termsUrl = "termsUrl"
    static let key_overlay = "overlay"
    static let key_photoUrl = "image"
    static let key_photoUrlSquared = "image"
    static let key_requiredCapability = "required_capability"
    static let key_openOauthInBrowser = "open_oauth_in_browser"
    static let key_recipeId = "recipe_id"
    
    var identifier : String = ""
    var name : String = ""
    var termsUrl : String = ""
    var overlay : String = ""
    var photoUrl : String = ""
    var photoUrlSquared : String = ""
    var requiredCapability : String = ""
    var shouldOpenOauthInBrowser : Bool = false
    var recipeId : String = ""


    func convertProfileToChannelTemplate(dictionary: NSDictionary)
    {
        
        if let identifier = dictionary[MZProfileKeys.key_id] as? String
        {
            self.identifier = identifier
        }
        
        if let name = dictionary[MZProfileKeys.key_name] as? String
        {
            self.name = name
        }
        
        if let photo = dictionary[MZProfileKeys.key_photoUrl] as? String
        {
            self.photoUrl = photo
        }
        
        if let photoSquared = dictionary[MZProfileKeys.key_photoUrlSquared] as? String
        {
            self.photoUrlSquared = photoSquared
        }
        
        if let requiredCapability =  dictionary[MZProfileKeys.key_requiredCapability] as? String
        {
            self.requiredCapability = requiredCapability
        }
        
        if let shouldOpenOauthInBrowser = dictionary[MZProfileKeys.key_openOauthInBrowser] as? Bool
        {
            self.shouldOpenOauthInBrowser = shouldOpenOauthInBrowser
        }
        
    }
    
    override init()
    {
        self.identifier = ""
        self.name = ""
        self.termsUrl = ""
        self.photoUrl = ""
        self.photoUrlSquared = ""
        self.requiredCapability = ""
        self.shouldOpenOauthInBrowser = false
        self.recipeId = ""

    }
    
    convenience init(dictionary : NSDictionary)
    {
        self.init()
        
        if let recipeId =  dictionary[MZChannelTemplate.key_recipeId] as? String
        {
            self.recipeId = recipeId
        }
        
        if let overlay =  dictionary[MZChannelTemplate.key_overlay] as? String
        {
            self.overlay = overlay
        }
        
        if let template = (dictionary as! NSDictionary).value(forKey: "template") as? NSDictionary
        {
            
            if let identifier = template[MZChannelTemplate.key_id] as? String
            {
                self.identifier = identifier
            }
            
            if let name = template[MZChannelTemplate.key_name] as? String
            {
                self.name = name
            }
            
            if let photo = template[MZChannelTemplate.key_photoUrl] as? String
            {
                self.photoUrl = photo
            }
            
            if let photoSquared = template[MZChannelTemplate.key_photoUrlSquared] as? String
            {
                self.photoUrlSquared = photoSquared
            }
            
            if let requiredCapability =  template[MZChannelTemplate.key_requiredCapability] as? String
            {
                self.requiredCapability = requiredCapability
            }
            
            if let shouldOpenOauthInBrowser = template[MZChannelTemplate.key_openOauthInBrowser] as? Bool
            {
                self.shouldOpenOauthInBrowser = shouldOpenOauthInBrowser
            }
        
        }
    }
}


