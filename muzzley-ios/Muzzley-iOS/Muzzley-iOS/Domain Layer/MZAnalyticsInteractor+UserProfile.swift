//
//  MZAnalyticsInteractor+UserProfile.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 08/04/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - User Profile Events
    // MARK: - Feedback Events
    
    class func feedbackStartEvent() {
        self.trackEvent(MIXPANEL_EVENT_FEEDBACK_START)
    }
    
    class func feedbackFinishEvent(_ questionId: String, optionId: String, detail: String?) {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_QUESTION_ID: questionId]
        if optionId != "" {
            properties.updateValue(optionId, forKey: MIXPANEL_PROPERTY_OPTION_ID)
        }
        if detail != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(detail!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_FEEDBACK_FINISH, properties: properties)
    }
    
    
    // MARK: - About Events
    
    class func aboutMuzzleyViewEvent() {
        self.trackEvent(MIXPANEL_EVENT_ABOUT_VIEW)
    }
    
}
