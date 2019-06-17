//
//  MZChannel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 6/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation

class MZChannel: NSObject {
    
    static let key_id           = "id"
    static let key_profileId    = "profileId"
    static let key_remoteId     = "remoteId"
    static let key_photoUrl     = "photoUrl"
    static let key_place        = "place"
    static let key_content      = "content"
    static let key_profileName  = "profileName"
    static let key_interface    = "interface"
    static let key_isActionable = "isActionable"
    static let key_isTriggerable  = "isTriggerable"
    static let key_isStateful   = "isStateful"
    static let key_authorized   = "authorized"
    static let key_components   = "components"
    static let key_properties   = "properties"
    static let key_categories   = "categories"
	 
    var identifier: String
    var profileId: String
    var remoteId: String
    var photoUrl: URL?
    var place: String
    var name: String
    var profileName: String
    var interface: MZControlInterface?
    var isActionable : Bool
    var isTriggable : Bool
    var isStateful : Bool
    var authorized: Bool
    
    var components: [MZComponent] = [MZComponent] ()
    var properties: [MZProperty] = [MZProperty] ()
    
    var categoryIds: NSArray?
    
    var dictionaryRepresentation: NSDictionary
    
    override init() {
        
        identifier = ""
        profileId = ""
        remoteId = ""
        photoUrl = nil
        place = ""
        name = ""
        profileName = ""
        interface = nil
        isActionable = false
        isTriggable = false
        isStateful = false
        authorized = false
        components = []
        properties = []

        categoryIds = NSArray()

        dictionaryRepresentation = NSDictionary()
        
        
        
        super.init()
    }
    
    convenience init(dictionary : NSDictionary)
    {
        self.init()
        if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let validIdentifier = dictionary[MZChannel.key_id] as? String {
                self.identifier = validIdentifier
            }
            if let validProfileId = dictionary[MZChannel.key_profileId] as? String {
                self.profileId = validProfileId
            }
            if let validRemoteIdentifier = dictionary[MZChannel.key_remoteId] as? String {
                self.remoteId = validRemoteIdentifier
            }
            if let validPhotoUrlString = dictionary[MZChannel.key_photoUrl] as? String {
                self.photoUrl = URL(string: validPhotoUrlString)
            }
            if let validPlace = dictionary[MZChannel.key_place] as? String {
                self.place = validPlace
            }
            if let validName = dictionary[MZChannel.key_content] as? String {
                self.name = validName
            }
            if let validProfileName = dictionary[MZChannel.key_profileName] as? String {
                self.profileName = validProfileName
            }
            if let validInterface = dictionary[MZChannel.key_interface] as? NSDictionary {
                if let interface = MZControlInterface.interfaceWithDictionaryRepresentation(validInterface) {
                    self.interface = interface
                }
            }
            if let validIsActionable = dictionary[MZChannel.key_isActionable] as? Bool {
                self.isActionable = validIsActionable
            }
            if let validIsTriggable = dictionary[MZChannel.key_isTriggerable] as? Bool {
                self.isTriggable = validIsTriggable
            }
            if let validIsStateful = dictionary[MZChannel.key_isStateful] as? Bool {
                self.isStateful = validIsStateful
            }
            if let validAuthorized = dictionary[MZChannel.key_authorized] as? Bool {
                self.authorized = validAuthorized
            }

            if let validCategories = dictionary[MZChannel.key_categories] as? NSArray {
                self.categoryIds = validCategories
            }
            if let properties: NSArray = dictionary[MZChannel.key_properties] as? NSArray {
                for element in properties as NSArray {
                    if let dict = element as? NSDictionary {
                        if let property : MZProperty = MZProperty (dictionary: dict) {
                            self.properties.append(property)
                        }
                    }
                }
            }
            if let components: NSArray = dictionary[MZChannel.key_components] as? NSArray {
                for element in components as NSArray {
                    if let dict = element as? NSDictionary {
                        if let component : MZComponent = MZComponent (dictionary: dict) {
                            self.components.append(component)
                        }
                    }
                }
            }
        }
    }
}
