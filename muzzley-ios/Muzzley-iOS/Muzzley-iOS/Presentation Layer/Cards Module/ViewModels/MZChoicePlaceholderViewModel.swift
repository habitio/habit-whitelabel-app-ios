//
//  MZSingleChoicePlaceholderViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 10/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

class MZChoicePlaceholderViewModel: NSObject
{
    static let key_label    = "label"
    static let key_value    = "value"
    static let key_selected = "selected"

    var label : String          = ""
    var value : AnyObject!
    var selected : Bool         = false
    var multiSelection : Bool   = false
    
    init(dictionary : NSDictionary)
    {
        if let label: String = dictionary[MZStageField.key_label] as? String {
            self.label = label
        }
        if let value: AnyObject = dictionary[MZStageField.key_value] as? AnyObject! {
            self.value = value
        }
        if let selected: Bool = dictionary[MZStageField.key_selected] as? Bool {
            self.selected = selected
        }

    }

}
