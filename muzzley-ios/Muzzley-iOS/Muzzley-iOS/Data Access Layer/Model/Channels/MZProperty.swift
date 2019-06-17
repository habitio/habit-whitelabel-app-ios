//
//  MZProperty.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/12/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

class MZProperty: NSObject {
    
    static let key_id           = "id"
    static let key_label        = "label"
    static let key_components   = "components"
    static let key_classes      = "classes"
    static let key_isActionable = "isActionable"
    static let key_isTriggerable  = "isTriggerable"
    static let key_isStateful   = "isStateful"
    static let key_requiredCapabilities      = "requiredCapabilities"
	static let key_unitsOptions = "unitsOptions"
    
    var identifier: String      = ""
    var label: String           = ""
    var components: [String]    = []
    var classes: [String]       = []
    var requiredCapabilities: [String]       = [NONE_CAPABILITY]
    var isActionable : Bool     = false
    var isTriggable : Bool      = false
    var isStateful : Bool       = false
	var unitsOptions : NSDictionary = NSDictionary()
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    init(dictionary: NSDictionary)
    {
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let identifier: String = dictionary[MZProperty.key_id] as? String {
                self.identifier = identifier
            }
            if let label: String = dictionary[MZProperty.key_label] as? String {
                self.label = label
            }
            if let components: [String] = dictionary[MZProperty.key_components] as? [String] {
                self.components = components
            }
            if let classes: [String] = dictionary[MZProperty.key_classes] as? [String] {
                self.classes = classes
            }
			
            if let requiredCapabilities: [String] = dictionary[MZProperty.key_requiredCapabilities] as? [String] {
                if requiredCapabilities.count > 0
                {
                    self.requiredCapabilities = requiredCapabilities
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
			
			if let unitOpts: NSDictionary = dictionary[MZProperty.key_unitsOptions] as? NSDictionary {
				self.unitsOptions = unitOpts
			}
        }
    }
}
