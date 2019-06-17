//
//  MZAnalyticsInteractor+Devices.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 31/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - Devices Events
    
    class func manualInteractionEvent(_ source: String, interactionView: String, groupCount: NSNumber, propertyId: String, profileId: String, errorMessage: String?)
    {
        var properties: [String: Any] = [
            MIXPANEL_PROPERTY_INTERACTION_SOURCE: source,
            MIXPANEL_PROPERTY_WHERE: MIXPANEL_VALUE_APP,
            MIXPANEL_PROPERTY_INTERACTION_VIEW: interactionView,
            MIXPANEL_PROPERTY_INTERACTION_PROPERTY: propertyId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileId]
        
        if groupCount.int32Value > 0
        {
            properties.updateValue(groupCount, forKey: MIXPANEL_PROPERTY_GROUP_COUNT)
        }
        
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        
        self.trackEvent(MIXPANEL_EVENT_MANUAL_INTERACTION, properties: properties)
    }
    
    // MARK: Devices Add
    
    class func deviceAddStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_ADD_DEVICE_START)
    }
    
    class func deviceAddCancelEvent(_ profileID: String?) {
        var properties: [String: Any] = [:]
        if profileID != nil {
            properties.updateValue(profileID!, forKey: MIXPANEL_PROPERTY_PROFILE_ID)
        }
        self.trackEvent(MIXPANEL_EVENT_ADD_DEVICE_CANCEL, properties: properties)
    }
    
    class func deviceAddSelectDeviceEvent(_ profileID: String) {
        self.trackEvent(MIXPANEL_EVENT_ADD_DEVICE_SELECT_DEVICE, properties: [
            MIXPANEL_PROPERTY_PROFILE_ID: profileID])
    }
    
    class func deviceAddSelectChannelEvent(_ profileID: String) {
        self.trackEvent(MIXPANEL_EVENT_ADD_DEVICE_SELECT_CHANNEL, properties: [
            MIXPANEL_PROPERTY_PROFILE_ID: profileID])
    }
    
    class func deviceAddFinishEvent(_ profileID: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_PROFILE_ID: profileID]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage! , forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_ADD_DEVICE_FINISH, properties: properties)
    }
    
    
    // MARK: Devices Edit
    
    class func deviceEditStartEvent(_ deviceModel: MZTile)
    {
        self.trackEvent(MIXPANEL_EVENT_EDIT_DEVICE_START, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: deviceModel.profileId])
    }
    
    class func deviceEditFinishEvent(_ deviceModel: MZTile, errorMessage: String?)
    {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_PROFILE_ID: deviceModel.profileId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EDIT_DEVICE_FINISH, properties: properties)
    }
    
    class func deviceEditDeleteCancelEvent(_ deviceModel: MZTile)
    {
        self.trackEvent(MIXPANEL_EVENT_EDIT_DEVICE_DELETE_CANCEL, properties: [MIXPANEL_PROPERTY_PROFILE_ID: deviceModel.profileId])
    }
    
    class func deviceEditDeleteFinishEvent(_ deviceModel: MZTile, errorMessage: String?)
    {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_PROFILE_ID: deviceModel.profileId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EDIT_DEVICE_DELETE_FINISH, properties: properties)
    }
    
    
    // MARK: - Groups
    // MARK: Group Create
    
    class func groupCreateStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_GROUP_START)
    }
    
    class func groupCreateCancelEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_GROUP_CANCEL)
    }
    
    class func groupCreateFinishEvent(_ errorMessage: String?) {
        var properties: [String: Any] = [:]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_CREATE_GROUP_FINISH, properties: properties)
    }
    
    // MARK: Group Edit
    
    class func groupEditStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_EDIT_GROUP_START)
    }
    
    class func groupEditCancelEvent() {
        self.trackEvent(MIXPANEL_EVENT_EDIT_GROUP_CANCEL)
    }
    
    class func groupEditFinishEvent(_ errorMessage: String?) {
        var properties: [String: Any] = [:]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EDIT_GROUP_FINISH, properties: properties)
    }
    
    class func groupEditUngroupCancelEvent() {
        self.trackEvent(MIXPANEL_EVENT_EDIT_GROUP_UNGROUP_CANCEL)
    }
    
    class func groupEditUngroupFinishEvent(_ errorMessage: String?) {
        var properties: [String: Any] = [:]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EDIT_GROUP_UNGROUP_FINISH, properties: properties)
    }
    
}
