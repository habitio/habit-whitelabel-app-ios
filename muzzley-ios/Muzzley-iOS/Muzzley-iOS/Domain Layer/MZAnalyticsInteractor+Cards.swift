//
//  MZAnalyticsInteractor+Cards.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 12/04/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - Cards Events
    
    class func cardViewedEvent(_ cardId: String, cardClass: String, cardType: String)
    {
        self.trackEvent(MIXPANEL_EVENT_SUGGESTION_VIEW, properties: [
            MIXPANEL_PROPERTY_SUGGESTION_ID: cardId,
            MIXPANEL_PROPERTY_CLASS: cardClass,
            MIXPANEL_PROPERTY_TYPE: cardType])
    }
    
    class func cardUserEngagedEvent(_ cardId: String, cardClass: String, cardType: String, actionType: String, stageIndex: Int)
    {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_SUGGESTION_ID: cardId,
            MIXPANEL_PROPERTY_CLASS: cardClass,
            MIXPANEL_PROPERTY_TYPE: cardType,
            MIXPANEL_PROPERTY_ACTION_TYPE: actionType]
        
        if stageIndex > -1 {
            properties.updateValue(stageIndex, forKey: MIXPANEL_PROPERTY_STAGE_INDEX)
        }
        
        self.trackEvent(MIXPANEL_EVENT_SUGGESTION_USER_ENGAGE, properties: properties)
    }
    
    class func cardFinishEvent(_ cardId: String, cardClass: String, cardType: String, action: String?, detail: String?)
    {
        var properties: [String: Any] = [MIXPANEL_PROPERTY_SUGGESTION_ID: cardId,
                                               MIXPANEL_PROPERTY_CLASS: cardClass,
                                               MIXPANEL_PROPERTY_TYPE: cardType]
        if action != nil {
            properties.updateValue(action!, forKey: MIXPANEL_PROPERTY_ACTION_TYPE)
        }
        if detail != nil {
            properties.updateValue(MIXPANEL_VALUE_ERROR, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(detail!, forKey: MIXPANEL_PROPERTY_DETAIL)
        } else {
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_STATUS)
            properties.updateValue(MIXPANEL_VALUE_SUCCESS, forKey: MIXPANEL_PROPERTY_DETAIL)
        }
        self.trackEvent(MIXPANEL_EVENT_SUGGESTION_FINISH, properties: properties)
    }
    
    class func cardHideEvent(_ cardId: String, cardClass: String, cardType: String, value: String)
    {
        self.trackEvent(MIXPANEL_EVENT_SUGGESTION_HIDE, properties: [
            MIXPANEL_PROPERTY_SUGGESTION_ID: cardId,
            MIXPANEL_PROPERTY_CLASS: cardClass,
            MIXPANEL_PROPERTY_TYPE: cardType,
            MIXPANEL_PROPERTY_VALUE: value])
    }
    
}
