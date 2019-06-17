//
//  MZStageField.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

class MZStageField: NSObject
{
    static let key_id               = "id"
    static let key_label            = "label"
    static let key_type             = "type"
    static let key_filter           = "filter"
    static let key_placeholder      = "placeholder"
    static let key_value            = "value"
    
    static let key_latitude         = "latitude"
    static let key_longitude        = "longitude"
    static let key_text             = "text"
    static let key_time             = "time"
    static let key_weekDays         = "weekDays"
    
    static let key_component        = "component"
    static let key_profileId        = "profileId"
    static let key_remoteId         = "remoteId"
    static let key_tile             = "tile"
    static let key_classes          = "classes"
    static let key_componentClasses = "componentClasses"
    static let key_propertyClasses  = "propertyClasses"
    
    static let key_selected         = "selected"
    
    static let key_image            = "image"
    static let key_priceRange       = "priceRange"
    static let key_detailUrl        = "detailUrl"
    static let key_highlighted      = "highlighted"
    
    
    enum type : String {
        case location       = "location"
        case time           = "time"
        case text           = "text"
        case devicechoice   = "device-choice"
        case singlechoice   = "single-choice"
        case multichoice    = "multi-choice"
        case adslist        = "ads-list"
    }
    
    var id : String            = ""
    var filters : [[String:AnyObject]]  = [[String:AnyObject]]()
    var type: String           = ""
    var label: String          = ""
    var value : [[String:AnyObject]]?
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let id = dictionary[MZStageField.key_id] as? String {
                self.id = id
            }
            if let label = dictionary[MZStageField.key_label] as? String {
                self.label = label
            }
            if let type = dictionary[MZStageField.key_type] as? String {
                self.type = type
            }
            if let filters : [[String:AnyObject]] = dictionary[MZStageField.key_filter] as? [[String:AnyObject]] {
                self.filters = filters
            }
        }
    }
    
}
