//
//  EChannelCategory.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

import Foundation

class EChannelCategory: NSObject {
    
    enum EChannelCategoryKey: NSString {
        case identifier = "id"
        case label = "label"
        case interface = "interface"
    }
    
    let identifier: String!
    let label: String!
    let interface: MZControlInterface?
    let childChannels: NSMutableDictionary!
    
    override var description: String {
        return NSString(format: "label:%@ children:%d", label, childChannels.allKeys.count) as String
    }
    
    init?(identifier: String, label: String, interface: MZControlInterface?) {
        
        self.identifier = identifier
        self.label = label
        self.interface = interface
        self.childChannels = NSMutableDictionary()
        super.init()
        
        if identifier.isEmpty { return nil }
        if label.isEmpty { return nil }
    }
    
    class func categoryWithDictionaryRepresentation(_ dictionary : NSDictionary) -> EChannelCategory? {
        
        // Validate values
        var validIdentifier: String!
        var validLabel : String!
        var validInterface: MZControlInterface?
        
        if !dictionary.isKind(of: NSDictionary.self) {
            return nil;
        }
        
        if let identifier = dictionary[EChannelCategoryKey.identifier.rawValue] as? String {
            validIdentifier = identifier
        } else { return nil }
        
        if let interfaceDict = dictionary[EChannelCategoryKey.interface.rawValue] as? NSDictionary {
            validInterface = MZControlInterface.interfaceWithDictionaryRepresentation(interfaceDict);
        }
        
        if let label = dictionary[EChannelCategoryKey.label.rawValue] as? String {
            validLabel = label
        } else { return nil }
    
        // Create channel category
        if let category = EChannelCategory(identifier: validIdentifier, label: validLabel, interface: validInterface) {
            return category
        }
        return nil
    }
    
}
