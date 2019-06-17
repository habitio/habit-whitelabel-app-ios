//
//  MZWorker.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 13/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZWorker: NSObject
{
    static let key_trigger  = "trigger"
    static let key_action   = "action"
    static let key_state    = "state"
    
    static let key_id               = "id"
    static let key_label            = "label"
    static let key_categoryImage    = "categoryImage"
    static let key_clientImage      = "clientImage"
    static let key_enabled          = "enabled"
    static let key_lastRun          = "lastRun"
    static let key_description      = "description"
    static let key_category         = "category"
    static let key_categoryColor    = "categoryColor"
    static let key_devicesText      = "devicesText"
    static let key_actions          = "actions"
    static let key_triggers         = "triggers"
    static let key_states           = "states"
    static let key_unsorted         = "unsorted"
    static let key_execute          = "execute"
    static let key_editable         = "editable"
    static let key_invalid          = "invalid"
	static let key_forceDisabled    = "forceDisabled"
	static let key_deletable		= "deletable"
    static let key_allowdisable		= "allowdisable"
	static let key_forceDisabled_status = "forceDisabled"
	static let key_forceDisabled_message = "forceDisabledMessage"
	
    var identifier: String      = ""
    var label: String           = ""
    var enabled: Bool           = false
    var lastRun: String         = ""
    var desc: String            = ""
    var category: String        = ""
    var categoryColor: UIColor  = UIColor.muzzleyBlackColor(withAlpha: 1)
    var devicesText: String     = ""
    var triggerDevices: [MZBaseWorkerDevice] = []
    var actionDevices: [MZBaseWorkerDevice] = []
    var stateDevices: [MZBaseWorkerDevice] = []
    var unsortedDevices: [MZBaseWorkerDevice] = []
    var executeCommands: [NSDictionary] = []
    var isEditable: Bool        = true
    var isValid: Bool           = true
	
	var categoryImage : URL? = nil
	var clientImage :  URL? = nil
	var forceDisabledStatus : Bool = false
	var forceDisabledMessage : String = ""
	var deletable = true
    var allowdisable = false

    var dictionaryRepresentation: NSDictionary = NSDictionary()
	
    convenience init(dictionary: NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let identifier : String = dictionary[MZWorker.key_id] as? String {
                self.identifier = identifier
            }
            if let label : String = dictionary[MZWorker.key_label] as? String {
                self.label = label
            }
            if let enabled: Bool = dictionary[MZWorker.key_enabled] as? Bool {
                self.enabled = enabled
            }
            if let lastRun : String = dictionary[MZWorker.key_lastRun] as? String {
                self.lastRun = lastRun
            }
            if let desc : String = dictionary[MZWorker.key_description] as? String {
                self.desc = desc
            }
            if let category : String = dictionary[MZWorker.key_category] as? String {
                self.category = category
            }
            if let categoryColorStr : String = dictionary[MZWorker.key_categoryColor] as? String {
                self.categoryColor = UIColor(hex: categoryColorStr)
            }
            if let devicesText : String = dictionary[MZWorker.key_devicesText] as? String {
                self.devicesText = devicesText
            }
            if let executeCommands : [NSDictionary] = dictionary[MZWorker.key_execute] as? [NSDictionary] {
                self.executeCommands = executeCommands
            }
            if let editable: Bool = dictionary[MZWorker.key_editable] as? Bool {
                self.isEditable = editable
            }
            if let isInvalid: Bool = dictionary[MZWorker.key_invalid] as? Bool {
                self.isValid = !isInvalid
            }
			
            if let categoryImage: String = dictionary[MZWorker.key_categoryImage] as? String {
                self.categoryImage = !categoryImage.isEmpty ? URL(string: categoryImage)! : nil
            }

            if let clientImage: String = dictionary[MZWorker.key_clientImage] as? String  {
                self.clientImage =  !clientImage.isEmpty ? URL(string: clientImage)! : nil
            }

			if let forceDisabledStatus: Bool = dictionary[MZWorker.key_forceDisabled_status] as? Bool {
				self.forceDisabledStatus = forceDisabledStatus
			}
			if let forceDisabledMessage: String = dictionary[MZWorker.key_forceDisabled_message] as? String {
					self.forceDisabledMessage = forceDisabledMessage
			}
			else
			{
				self.forceDisabledMessage = NSLocalizedString("mobile_worker_force_disabled_text", comment: "")
			}
			
			if let deletable: Bool = dictionary[MZWorker.key_deletable] as? Bool {
				self.deletable = deletable
			}
            
            if let allowdisable: Bool = dictionary[MZWorker.key_allowdisable] as? Bool {
                self.allowdisable = allowdisable
            }
        }
    }
}



