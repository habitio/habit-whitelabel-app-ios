//
//  MZComponent.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 18/12/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

class MZComponent: NSObject {
    
    static let key_id       = "id"
    static let key_type     = "type"
    static let key_label    = "label"
    static let key_classes  = "classes"
    static let key_capabilities = "requiredCapabilities"
    
    var type: String                    = ""
    var identifier: String              = ""
    var label: String                   = ""
    var classes: [String]               = [String]()
    var capabilities: [String]          = []
    var propertiesClasses : [String]    = [String] ()
	var properties : [MZProperty]       = [MZProperty]()
    
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    init(dictionary: NSDictionary)
    {
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let identifier: String = dictionary[MZComponent.key_id] as? String {
                self.identifier = identifier
            }
            if let type: String = dictionary[MZComponent.key_type] as? String {
                self.type = type
            }
            if let label: String = dictionary[MZComponent.key_label] as? String {
                self.label = label
            }
            if let classes: [String] = dictionary[MZComponent.key_classes] as? [String] {
                self.classes = classes
            }
        }
    }
}
