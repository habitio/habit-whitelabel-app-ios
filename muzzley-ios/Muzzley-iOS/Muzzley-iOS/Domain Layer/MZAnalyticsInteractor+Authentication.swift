//
//  MZAnalyticsInteractor+Sign.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 31/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - Sign Events
    // MARK: Sign-In
    
    class func signInStartEvent(_ loginType: String) {
        self.trackEvent(MIXPANEL_EVENT_SIGN_IN_START, properties: [
            MIXPANEL_PROPERTY_PLATFORM: loginType])
    }
    
    class func signInFinishEvent(_ loginType: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_PLATFORM: loginType]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        
        self.trackEvent(MIXPANEL_EVENT_SIGN_IN_FINISH, properties: properties)
    }
    
    // MARK: Sign Up
    
    class func signUpStartEvent(_ loginType: String) {
        self.trackEvent(MIXPANEL_EVENT_SIGN_UP_START, properties: [MIXPANEL_PROPERTY_PLATFORM: loginType])
    }
    
    class func signUpFinishEvent(_ loginType: String, errorMessage: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_PLATFORM: loginType]
        if errorMessage != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(errorMessage!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_SIGN_UP_FINISH, properties: properties)
    }
    
    // MARK: Sign-Out
    
    class func signOutEvent(_ email: String) {
        self.trackEvent(MIXPANEL_EVENT_SIGN_OUT)
    }
    
    
    // MARK: - Forgot Password Events
    
    class func forgotPasswordStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_FORGOT_PASSWORD_START)
    }
    
    class func forgotPasswordRequestFinishEvent() {
        self.trackEvent(MIXPANEL_EVENT_FORGOT_PASSWORD_REQUEST_FINISH)
    }
    
}
