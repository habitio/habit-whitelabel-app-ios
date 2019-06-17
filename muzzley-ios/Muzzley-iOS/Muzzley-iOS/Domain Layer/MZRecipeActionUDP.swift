//
//  MZRecipeActionUDP.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/01/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//

class MZRecipeActionUDP
{
    let key_action = "action"
    let key_action_version = "action_version"
    let key_broadcast = "broadcast"
    let key_channelTemplateId = "channeltemplate_id"
    let key_clientId = "client_id"
    let key_ownerId = "owner_id"
    let key_interface = "interface"
    let key_ip = "ip"
    let key_data = "data"
    let key_data_converter = "data_converter"
    let key_port = "port"
    let key_prefixLength = "prefix_length"
    let key_process = "process"
    let key_expectResponse = "expect_response"
    let key_ttl = "ttl"
    let key_response_type = "response_type"
    
    var action : String?
    var actionVersion : String? = ""
    var broadcast: Bool?
    var ip : String?
    var channelTemplateId : String?
    var clientId : String?
    var ownerId : String?
    var data : String?
    var dataConverter : String?
    var expectResponse : Bool?
    var port : UInt?
    var prefixLength : Bool?
    var process : String?
    var responseType : String?
    var ttl : Int?
    
   
    
    init?(dictionary : NSDictionary)
    {
        if let channelTemplateId = dictionary.value(forKey: self.key_channelTemplateId) as? String
        {
            self.channelTemplateId = channelTemplateId
        }
        
        if let ownerId = dictionary.value(forKey: self.key_ownerId) as? String
        {
            self.ownerId = ownerId
        }

        if let clientId = dictionary.value(forKey: self.key_clientId) as? String
        {
            self.clientId = clientId
        }

        if let process = dictionary.value(forKey: self.key_process) as? String
        {
            self.process = process
        }
        
        if let action = dictionary.value(forKey: self.key_action) as? String
        {
            self.action = action
        }
        
        if let actionVersion = dictionary.value(forKey: self.key_action_version) as? String
        {
            self.actionVersion = actionVersion
        }
        
        if let broadcast = dictionary.value(forKey: self.key_broadcast) as? Bool
        {
            self.broadcast = broadcast
        }
        
        if let ip = dictionary.value(forKey: self.key_ip) as? String
        {
            self.ip = ip
        }
        
        if let port = dictionary.value(forKey: self.key_port) as? UInt
        {
            self.port = port
        }
        
        if let data = dictionary.value(forKey: self.key_data) as? String
        {
            self.data = data
        }
        
        if let dataConverter = dictionary.value(forKey: self.key_data_converter) as? String
        {
            self.dataConverter = dataConverter
        }
        
        if let expectResponse = dictionary.value(forKey: self.key_expectResponse) as? Bool
        {
            self.expectResponse = expectResponse
        }
        
        if let prefixLength = dictionary.value(forKey: self.key_prefixLength) as? Bool
        {
            self.prefixLength = prefixLength
        }
        
        if let ttl = dictionary.value(forKey: self.key_ttl) as? Int
        {
            self.ttl = ttl
        }
        
        if let responseType = dictionary.value(forKey: self.key_response_type) as? String
        {
            self.responseType = responseType
        }
        
        
    }
    
}
