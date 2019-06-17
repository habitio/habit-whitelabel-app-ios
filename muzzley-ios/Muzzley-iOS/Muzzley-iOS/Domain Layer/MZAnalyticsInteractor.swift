//
//  MZAnalyticsInteractor.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 31/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import CocoaLumberjack

class MZAnalyticsInteractor: NSObject
{

    class func configure()
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            Mixpanel.sharedInstance(withToken: MZThemeManager.sharedInstance.mixpanel!.projectToken)
        }
    }
    
    class func registerSuperProperties(_ userAuthInfo: MZUserAuthInfo)
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
			let mixpanelApplication = MZThemeManager.sharedInstance.mixpanel!.applicationName!
			if(!mixpanelApplication.isEmpty)
			{
				Mixpanel.sharedInstance().registerSuperProperties([
					MIXPANEL_PROPERTY_USER_NAME: MZSessionDataManager.sharedInstance.session.userProfile.name,
					MIXPANEL_PROPERTY_USER_EMAIL: MZSessionDataManager.sharedInstance.session.userProfile.email,
					MIXPANEL_PROPERTY_USER_ID: userAuthInfo.userId,
					MIXPANEL_PROPERTY_APPLICATION: mixpanelApplication
				])
                Mixpanel.sharedInstance().people.set([
                    "distinct_id": userAuthInfo.userId,
                    "$name": MZSessionDataManager.sharedInstance.session.userProfile.name,
                    "$email": MZSessionDataManager.sharedInstance.session.userProfile.email])
			}
			else
			{
				DDLogDebug("Error importing MixpanelApplication from theme file. Value is nil or empty.");
			}
        }

    }
    
    class func configureIdentity(_  userAuthInfo: MZUserAuthInfo?)
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            if userAuthInfo != nil
            {
                Mixpanel.sharedInstance().identify(userAuthInfo!.userId)
                self.registerSuperProperties(userAuthInfo!)
            }
        }
    }
    
    class func configureAlias(_ aliasId: String,  userAuthInfo: MZUserAuthInfo)
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            Mixpanel.sharedInstance().createAlias(userAuthInfo.userId, forDistinctID: aliasId)
            self.configureIdentity(nil)
            self.registerSuperProperties(userAuthInfo)
        }
    }
    
    class func flush()
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            Mixpanel.sharedInstance().flush()
        }
    }
    
    class func reset()
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            Mixpanel.sharedInstance().reset()
			
			
			let mixpanelApplication = MZThemeManager.sharedInstance.mixpanel!.applicationName!
			if(!mixpanelApplication.isEmpty)
			{
				Mixpanel.sharedInstance().registerSuperProperties([
                MIXPANEL_PROPERTY_APPLICATION: mixpanelApplication])
			}
			else
			{
				DDLogDebug("Error resetting mixpanel. Invalid mixpanel application loaded from theme file.")
			}
        }
    }
    
    class func trackEvent(_ event: String, properties: [String: Any])
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            Mixpanel.sharedInstance().track(event, properties: properties)
        }
    }
    
    class func trackEvent(_ event: String)
    {
        if MZThemeManager.sharedInstance.mixpanel != nil
        {
            if Mixpanel.sharedInstance() != nil
            {
                
                do
                {
                    Mixpanel.sharedInstance().track(event)
                }
                catch
                {
                    
                }
            }
        }
    }
    
}
