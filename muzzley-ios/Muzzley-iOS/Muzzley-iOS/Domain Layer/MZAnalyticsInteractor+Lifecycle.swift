//
//  MZAnalyticsInteractor+Lifecycle.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 31/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

extension MZAnalyticsInteractor {

    // MARK: - App Lifecycle Events
    
    class func startAppEvent()
    {
//        MZSession.sharedInstance.loadFromCache { (cachedSessionFound) in
//            var userAuthInfo : MZUserAuthInfo?
//            if cachedSessionFound
//            {
//                userAuthInfo = MZSession.sharedInstance.authInfo
//			}
//			

			self.configureIdentity(MZSession.sharedInstance.authInfo)

            self.trackEvent(MIXPANEL_EVENT_START_APP)
			
//		}
    }
    
    class func exitAppEvent() {
        self.trackEvent(MIXPANEL_EVENT_EXIT_APP)
    }
    
    class func navigateToEvent(_ screen: String) {
        self.trackEvent(MIXPANEL_EVENT_NAVIGATE_TO, properties: [MIXPANEL_PROPERTY_SCREEN: screen])
    }
    
    
    // MARK: - Force Update
    
    class func forceUpdateShowEvent() {
        self.trackEvent(MIXPANEL_EVENT_FORCE_UPDATE_SHOW)
    }
    
    class func forceUpdateRedirectStoreEvent() {
        self.trackEvent(MIXPANEL_EVENT_FORCE_UPDATE_REDIRECT_STORE)
    }
    
}
