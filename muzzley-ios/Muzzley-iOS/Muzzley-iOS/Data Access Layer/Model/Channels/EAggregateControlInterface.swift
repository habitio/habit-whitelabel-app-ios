//
//  EAggregateControlInterface.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 6/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

import Foundation

class EAggregateControlInterface: NSObject {
   
    enum EAggregateControlInterfaceKey: NSString {
        case uuid = "uuid"
        case name = "name"
        case description = "description"
        case icon = "icon"
        case source = "src"
        case channels = "channels"
    }
    
    // MARK: Properties
    var uuid: String = ""
    var name: String = ""
    var aggregateDescription: String = ""
    var iconUrlString: String = ""
    var sourceUrlString: String = ""
    var childChannels: NSMutableDictionary = NSMutableDictionary()

    // MARK: Class Initializers
    class func aggregateInterfaceWithDictionaryRepresentation(_ dictionary : NSDictionary) -> EAggregateControlInterface {
        
        // Create channel interface
        let interface:EAggregateControlInterface  = EAggregateControlInterface()
        
        // Validate values
        if let uuid = dictionary[EAggregateControlInterfaceKey.uuid.rawValue] as? String {
            interface.uuid = uuid
        }
        if let name = dictionary[EAggregateControlInterfaceKey.name.rawValue] as? String {
            interface.name = name
        }
        if let description = dictionary[EAggregateControlInterfaceKey.description.rawValue] as? String {
            interface.aggregateDescription = description
        }
        if let icon = dictionary[EAggregateControlInterfaceKey.icon.rawValue] as? String {
            interface.iconUrlString = icon
        }
        if let source = dictionary[EAggregateControlInterfaceKey.source.rawValue] as? String {
            interface.sourceUrlString = source
        }
        if let channelsArray = dictionary[EAggregateControlInterfaceKey.channels.rawValue] as? NSArray {
            for item in channelsArray {
                if let channelDictionary = item as? NSDictionary {
                    if let channel: MZChannel = MZChannel (dictionary: channelDictionary) {
                        interface.childChannels.setObject(channel, forKey: channel.identifier as NSCopying)
                    }
                }
            }
        }
        
        return interface
    }
}
