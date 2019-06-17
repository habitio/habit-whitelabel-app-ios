//
//  MZAnalyticsInteractor+Workers.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 31/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - workers Events
    
    class func workerEnableEvent(_ workerId: String, errorMessage: String?, enable: Bool) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_ROUTINE_ID: workerId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(enable ? MIXPANEL_EVENT_ENABLE_ROUTINE : MIXPANEL_EVENT_DISABLE_ROUTINE, properties: properties)
    }
    
    
    class func workerExecuteEvent(_ workerId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
                                               MIXPANEL_PROPERTY_SOURCE: MIXPANEL_VALUE_MANUAL,
                                               MIXPANEL_PROPERTY_WHERE: MIXPANEL_VALUE_APP]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EXECUTE_ROUTINE, properties: properties)
    }
    
    // MARK: Remove
    
    class func workerRemoveStartEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_REMOVE_ROUTINE_START, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerRemoveCancelEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_REMOVE_ROUTINE_CANCEL, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerRemoveFinishEvent(_ workerId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_ROUTINE_ID: workerId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_REMOVE_ROUTINE_FINISH, properties: properties)
    }
    
    // MARK: - worker Create
    
    class func workerCreateStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_START)
    }
    
    class func workerCreateCancelEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_CANCEL)
    }
    
    class func workerCreateFinishEvent(_ workerId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_ROUTINE_ID: workerId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_FINISH, properties: properties)
    }
    
    // MARK: Triggers
    
    class func workerCreateAddTriggerStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_ADD_TRIGGER_START)
    }
    
    class func workerCreateAddTriggerDoneEvent(_ profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_ADD_TRIGGER_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func workerCreateEditTriggerStartEvent(triggerName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_TRIGGER_START, properties: [MIXPANEL_PROPERTY_TRIGGER: triggerName])
//    }
    
//    class func workerCreateEditTriggerDoneEvent(triggerName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_TRIGGER_FINISH, properties: [MIXPANEL_PROPERTY_TRIGGER: triggerName])
//    }
    
    class func workerCreateDeleteTriggerDoneEvent(_ profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_TRIGGER_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    // MARK: Actions
    
    class func workerCreateAddActionStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_ADD_ACTION_START)
    }
    
    class func workerCreateAddActionDoneEvent(_ profileID: String, deviceName: String)
    {
       self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_ADD_ACTION_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func workerCreateEditActionStartEvent(actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_ACTION_START, properties: [MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
//    class func workerCreateEditActionDoneEvent(actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_ACTION_FINISH, properties: [MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
    class func workerCreateDeleteActionDoneEvent(_ profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_ACTION_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    class func workerCreateDeleteRuleActionDoneEvent(_ profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_RULE_ACTION_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    // MARK: State
    
    class func workerCreateAddStateStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_ADD_STATE_START)
    }
    
    class func workerCreateAddStateDoneEvent(_ profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_ADD_STATE_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func workerCreateEditStateStartEvent(stateName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_STATE_START, properties: [MIXPANEL_PROPERTY_STATE: stateName])
//    }
    
//    class func workerCreateEditStateDoneEvent(stateName: String) {
//        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_STATE_FINISH, properties: [MIXPANEL_PROPERTY_STATE: stateName])
//    }
    
    class func workerCreateDeleteStateDoneEvent(_ profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_STATE_FINISH, properties:
            [MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    
    // MARK: - Agent Edit
    
    class func workerEditStartEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_START, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerEditCancelEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_CANCEL, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerEditFinishEvent(_ workerId: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_ROUTINE_ID: workerId]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_FINISH, properties: properties as [String : AnyObject])
    }
    
    // MARK: Triggers
    
    class func workerEditAddTriggerStartEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_ADD_TRIGGER_START, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerEditAddTriggerDoneEvent(_ workerId: String, profileID: String, deviceName: String)
    {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_ADD_TRIGGER_FINISH, properties:
            [MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
                MIXPANEL_PROPERTY_PROFILE_ID: profileID,
                MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func workerEditEditTriggerStartEvent(workerId: String, triggerName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_TRIGGER_START, properties: [
//            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
//            MIXPANEL_PROPERTY_TRIGGER: triggerName])
//    }
    
//    class func workerEditEditTriggerDoneEvent(workerId: String, triggerName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_TRIGGER_DONE, properties: [
//            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
//            MIXPANEL_PROPERTY_TRIGGER: triggerName])
//    }
    
    class func workerEditDeleteTriggerDoneEvent(_ workerId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_TRIGGER_FINISH, properties: [
            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    // MARK: Actions
    
    class func workerEditAddActionStartEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_ADD_ACTION_START, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerEditAddActionDoneEvent(_ workerId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_ADD_ACTION_FINISH, properties: [
            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName ])
    }
    
//    class func workerEditEditActionStartEvent(workerId: String, actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_ACTION_START, properties: [
//            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
//            MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
//    class func workerEditEditActionDoneEvent(workerId: String, actionName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_ACTION_FINISH, properties: [
//            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
//            MIXPANEL_PROPERTY_ACTION: actionName])
//    }
    
    class func workerEditDeleteActionDoneEvent(_ workerId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_ACTION_FINISH, properties: [
            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    class func workerEditDeleteRuleActionDoneEvent(_ workerId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_RULE_ACTION_FINISH, properties: [
            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
    // MARK: State
    
    class func workerEditAddStateStartEvent(_ workerId: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_ADD_STATE_START, properties: [MIXPANEL_PROPERTY_ROUTINE_ID: workerId])
    }
    
    class func workerEditAddStateDoneEvent(_ workerId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_ADD_STATE_FINISH, properties: [
            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
//    class func workerEditEditStateStartEvent(workerId: String, stateName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_STATE_START, properties: [
//            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
//            MIXPANEL_PROPERTY_STATE: stateName])
//    }
    
//    class func workerEditEditStateDoneEvent(workerId: String, stateName: String) {
//        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_STATE_FINISH, properties: [
//            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
//            MIXPANEL_PROPERTY_STATE: stateName])
//    }
    
    class func workerEditDeleteStateDoneEvent(_ workerId: String, profileID: String, deviceName: String) {
        self.trackEvent(MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_STATE_FINISH, properties: [
            MIXPANEL_PROPERTY_ROUTINE_ID: workerId,
            MIXPANEL_PROPERTY_PROFILE_ID: profileID,
            MIXPANEL_PROPERTY_DEVICE_NAME: deviceName])
    }
    
}
