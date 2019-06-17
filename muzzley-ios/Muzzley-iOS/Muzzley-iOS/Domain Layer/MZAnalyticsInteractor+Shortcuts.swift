//
//  MZAnalyticsInteractor+Shortcuts.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 08/04/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - Shortcuts Events
    
    class func shortcutExecuteEvent(_ shortcutId: String, fromWhere: String, source: String) {
        var mixSource = source
        mixSource = mixSource.capitalized
        
        self.trackEvent(MIXPANEL_EVENT_EXECUTE_SHORTCUT, properties: [
            MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId,
            MIXPANEL_PROPERTY_SHORTCUT_WHERE: fromWhere,
            MIXPANEL_PROPERTY_SHORTCUT_SOURCE: mixSource])
    }
    
    
    // MARK: - Shortcut Create
    
    class func shortcutCreateStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_START)
    }
    
    class func shortcutCreateCancelEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_CANCEL)
    }
    
    class func shortcutCreateFinishEvent(_ shortcutId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_FINISH, properties: properties)
    }
    
    // MARK: Actions
    
    class func shortcutCreateAddActionStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_ADD_ACTION_START)
    }
    
    class func shortcutCreateAddActionDoneEvent(_ profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_ADD_ACTION_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func shortcutCreateEditActionStartEvent(actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_EDIT_ACTION_START, properties: [MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
//    class func shortcutCreateEditActionDoneEvent(actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_EDIT_ACTION_DONE, properties: [MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
    class func shortcutCreateDeleteActionDoneEvent(_ profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_DELETE_ACTION_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    class func shortcutCreateDeleteRuleActionDoneEvent(_ profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_CREATE_SHORTCUT_DELETE_RULE_ACTION_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    
    // MARK: - Shortcut Edit
    
    class func shortcutEditStartEvent(_ shortcutId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_START, properties: [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId])
    }
    
    class func shortcutEditCancelEvent(_ shortcutId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_CANCEL, properties: [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId])
    }
    
    class func shortcutEditFinishEvent(_ shortcutId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_FINISH, properties: properties)
    }
    
    // MARK: Actions
    
    class func shortcutEditAddActionStartEvent(_ shortcutId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_ADD_ACTION_START, properties: [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId])
    }
    
    class func shortcutEditAddActionDoneEvent(_ shortcutId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_ADD_ACTION_FINISH, properties: [
            MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func shortcutEditEditActionStartEvent(shortcutId: String, actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_EDIT_ACTION_START, properties: [
//            MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId,
//            MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
//    class func shortcutEditEditActionDoneEvent(shortcutId: String, actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_EDIT_ACTION_DONE, properties: [
//            MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId,
//            MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
    class func shortcutEditDeleteActionDoneEvent(_ shortcutId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_DELETE_ACTION_FINISH, properties: [
            MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    class func shortcutEditDeleteRuleActionDoneEvent(_ shortcutId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_SHORTCUT_DELETE_RULE_ACTION_FINISH, properties: [
            MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    
    // MARK: - Shortcut Remove
    
    class func shortcutRemoveStartEvent(_ shortcutId: String) {
        self.trackEvent(MIXPANEL_EVENT_REMOVE_SHORTCUT_START, properties: [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId])
    }
    
    class func shortcutRemoveCancelEvent(_ shortcutId: String) {
        self.trackEvent(MIXPANEL_EVENT_REMOVE_SHORTCUT_CANCEL, properties: [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId])
    }
    
    class func shortcutRemoveFinishEvent(_ shortcutId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_SHORTCUT_ID: shortcutId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_REMOVE_SHORTCUT_FINISH, properties: properties)
    }
    
}
