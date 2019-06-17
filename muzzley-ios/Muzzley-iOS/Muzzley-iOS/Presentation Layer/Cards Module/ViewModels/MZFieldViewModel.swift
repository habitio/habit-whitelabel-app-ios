//
//  MZFieldViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 24/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

class MZFieldViewModel: NSObject
{
    static let key_location     = "location"
    static let key_time         = "time"
    static let key_deviceChoice = "device-choice"
    static let key_text         = "text"
    static let key_singleChoice = "single-choice"
    static let key_multiChoice  = "multi-choice"
    static let key_adsList      = "ads-list"
    
    var placeholders: [AnyObject] = [AnyObject]()
    var type: String = ""
    var label: String = ""
    var filters : [[String:AnyObject]]  = [[String:AnyObject]]()
    var values: [AnyObject] = [AnyObject]()
    
    var fieldModel : MZStageField?
    
    convenience init(model : MZStageField)
    {
        self.init()
        self.fieldModel = model
        self.type = model.type
        self.label = model.label
        self.filters = model.filters
        self.values = placeholders
    }
    
    
    func valuesUpdated (_ values : [AnyObject])
    {
        fieldModel!.value = [[String:AnyObject]]()
        for value : AnyObject in values
        {
            if let locationPH : MZLocationPlaceholderViewModel = value as? MZLocationPlaceholderViewModel
            {
                fieldModel!.value!.append([MZStageField.key_latitude : locationPH.latitude as AnyObject, MZStageField.key_longitude : locationPH.longitude as AnyObject])
            } else if let timePH : MZTimePlaceholderViewModel = value as? MZTimePlaceholderViewModel
            {
                fieldModel!.value!.append([MZStageField.key_time : timePH.timeServer as AnyObject, MZStageField.key_weekDays : timePH.weekDays as AnyObject])
            } else if let devicePH : MZDeviceChoicePlaceholderViewModel = value as? MZDeviceChoicePlaceholderViewModel
            {
                fieldModel!.value!.append([MZStageField.key_component : devicePH.componentId as AnyObject, MZStageField.key_profileId : devicePH.profileId as AnyObject, MZStageField.key_remoteId : devicePH.remoteId as AnyObject, MZStageField.key_classes: devicePH.classes as AnyObject])
            } else if let textPH : MZTextPlaceholderViewModel = value as? MZTextPlaceholderViewModel
            {
                fieldModel!.value!.append([MZStageField.key_text : textPH.string as AnyObject])
            } else if let choicePH : MZChoicePlaceholderViewModel = value as? MZChoicePlaceholderViewModel
            {
                fieldModel!.value!.append([MZStageField.key_label:choicePH.label as AnyObject, MZStageField.key_value : choicePH.value != nil ? choicePH.value as AnyObject: "" as AnyObject, MZStageField.key_selected : choicePH.selected as AnyObject])
            }
        }
    }
    
    
    
    func setValue(_ value : AnyObject)
    {
        if let array = value as? [AnyObject] {
            self.values = array
        } else {
            self.values = [value]
        }
        
        valuesUpdated(self.values)
    }
    
    
    func getValue () -> AnyObject?
    {
        if self.values.isEmpty
        {
            return nil
        } else {
            return self.values as AnyObject
        }
    }
}
