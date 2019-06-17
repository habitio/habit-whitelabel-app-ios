//
//  MZRecipeActionConvertForShow.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/01/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//



class MZRecipeActionConvertForShow
{
    let key_action = "action"
    let key_channelTemplateID = "channeltemplate_id"
    let key_clientID = "client_id"
    let key_ownerID = "owner_id"
    let key_process = "process"
    let key_receivedFormat = "received_format"
    let key_devices = "devices"
    
    var action : String?
    var channelTemplateID : String?
    var clientID : String?
    var ownerID : String?
    var process : String?
    var receivedFormat : String?
    var devices : [NSDictionary]?
    
    init(dictionary : NSDictionary)
    {
        if let action = dictionary.value(forKey: self.key_action) as? String
        {
            self.action = action
        }
        
        if let channelTemplateID = dictionary.value(forKey: self.key_channelTemplateID) as? String
        {
            self.channelTemplateID = channelTemplateID
        }
        
        if let clientID = dictionary.value(forKey: self.key_clientID) as? String
        {
            self.clientID = clientID
        }
        
        if let ownerID = dictionary.value(forKey: self.key_ownerID) as? String
        {
            self.ownerID = ownerID
        }
        
        if let process = dictionary.value(forKey: self.key_process) as? String
        {
            self.process = process
        }
        
        if let receivedFormat = dictionary.value(forKey: self.key_receivedFormat) as? String
        {
            self.receivedFormat = receivedFormat
        }
        
        if let devices = dictionary.value(forKey: self.key_devices) as? [NSDictionary]
        {
            self.devices = devices
        }
    }
}
