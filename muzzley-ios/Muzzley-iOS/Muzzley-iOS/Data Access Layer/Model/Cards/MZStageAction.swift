//
//  MZStageAction.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZPubMQTT : NSObject
{
    static let key_topic		= "topic"
    static let key_payload		= "payload"
    
    var topic : String              = ""
    var payload : NSDictionary      = NSDictionary()
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()

    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            if let topic = dictionary[MZPubMQTT.key_topic] as? String {
                self.topic = topic
            }
            if let payload = dictionary[MZPubMQTT.key_payload] as? NSDictionary {
                self.payload = payload
            }
        }
    }
}

class MZStageAction: NSObject
{
    static let key_id               = "id"
    static let key_label            = "label"
    static let key_icon             = "icon"
    static let key_type             = "type"
    static let key_role             = "role"
    static let key_notifyOnClick    = "notifyOnClick"
    static let key_refreshAfter     = "refreshAfter"
    static let key_args             = "args"
    static let key_pubMQTT          = "pubMQTT"
    
    static let key_primary          = "primary"
    static let key_secondary        = "secondary"
    static let key_aside            = "aside"
    
    static let key_info             = "info"

    
    var id : String             = ""
    var label : String          = ""
    var icon : String           = ""
    var role : String           = ""
    var type : String           = ""
    var notifyOnClick : Bool    = false
    var refreshAfter: Bool      = false
    var pubMQTT : MZPubMQTT?
    var args : MZArgs?
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let id = dictionary[MZStageAction.key_id] as? String {
                self.id = id
            }
            if let label = dictionary[MZStageAction.key_label] as? String {
                self.label = label
            }
            if let icon = dictionary[MZStageAction.key_icon] as? String {
                self.icon = icon
            }
            if let type = dictionary[MZStageAction.key_type] as? String {
                self.type = type
            }
            if let role = dictionary[MZStageAction.key_role] as? String {
                self.role = role
            }
            if let notifyOnClick = dictionary[MZStageAction.key_notifyOnClick] as? Bool {
                self.notifyOnClick = notifyOnClick
            }
            if let refreshAfter = dictionary[MZStageAction.key_refreshAfter] as? Bool {
                self.refreshAfter = refreshAfter
            }
            if let args = dictionary[MZStageAction.key_args] as? NSDictionary {
                self.args = MZArgs(dictionary: args)
            }
            if let pubMQTT = dictionary[MZStageAction.key_pubMQTT] as? NSDictionary {
                self.pubMQTT = MZPubMQTT(dictionary: pubMQTT)
            }
        }
    }

}
