//
//  MZNeuraManager.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/12/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import NeuraSDK
import CocoaLumberjack

class MZNeuraManager
{
    static func initializeNeura()
    {
        if MZThemeManager.sharedInstance.neura != nil
        {
            Log.info("Neura Initializing");
            if !NeuraSDK.shared.isAuthenticated()
            {
                let request = NeuraAnonymousAuthenticationRequest()
                
                NeuraSDK.shared.authenticate(with: request) { result in
                    if result.success {
                        #if DEBUG
                        if(NeuraSDK.shared.neuraUserId() != nil)
                        {
                            Log.info("NeuraSDK UserID: " + NeuraSDK.shared.neuraUserId()!, saveInDebugLog: true);
                            Log.info("NeuraSDK Token: " + NeuraSDK.shared.appToken()!)
                        }
                        
                        Log.info("NeuraSDK appId: " + NeuraSDK.shared.appUID!);
                        Log.info("NeuraSDK AppSecret: " + NeuraSDK.shared.appSecret!)

                        #endif
                        NeuraSDK.shared.requireSubscriptions(toEvents: NEURA_MOMENTS_ARRAY, method: NSubscriptionMethod.webhook)
                        NeuraSDK.shared.requireSubscriptions(toEvents: NEURA_PREDICTIONS_ARRAY, method: NSubscriptionMethod.webhook)
                        
                        postUserInfo(userId: MZSession.sharedInstance.authInfo!.userId, neuraUserId: NeuraSDK.shared.neuraUserId()!, neuraToken: NeuraSDK.shared.appToken()!) { (success) in
                            print(success)
                        }
                    }
                    else
                    {
                        if(NeuraSDK.shared.neuraUserId() != nil)
                        {
                            NeuraSDK.shared.requireSubscriptions(toEvents: NEURA_MOMENTS_ARRAY, method: NSubscriptionMethod.webhook)
                            NeuraSDK.shared.requireSubscriptions(toEvents: NEURA_PREDICTIONS_ARRAY, method: NSubscriptionMethod.webhook)
                            
                            self.postUserInfo(userId: MZSession.sharedInstance.authInfo!.userId, neuraUserId: NeuraSDK.shared.neuraUserId()!, neuraToken: NeuraSDK.shared.appToken()!) { (success) in
                                print(success)
                            }
                            
                            #if DEBUG
                            if(NeuraSDK.shared.neuraUserId() != nil)
                            {
                                Log.info("NeuraSDK UserID: " + NeuraSDK.shared.neuraUserId()!, saveInDebugLog: true);
                                Log.info("NeuraSDK Token: " + NeuraSDK.shared.appToken()!)
                            }
                            Log.info("NeuraSDK appId: " + NeuraSDK.shared.appUID!);
                            Log.info("NeuraSDK AppSecret: " + NeuraSDK.shared.appSecret!)
                            #endif
                        }
                        
                        #if DEBUG
                        
                        Log.info("NeuraSDK appId: " + NeuraSDK.shared.appUID!);
                        Log.info("NeuraSDK AppSecret: " + NeuraSDK.shared.appSecret!)
                        #endif
                        
                        
                        // Handle authentication errors if required
                        //                NSLog("login error = %@", result.error);
                        // ****** Don't try to authenticate again here. Log the error and try again later *********
                    }
                }
            }
            else
            {
                #if DEBUG
                if(NeuraSDK.shared.neuraUserId() != nil)
                {
                    Log.info("NeuraSDK UserID: " + NeuraSDK.shared.neuraUserId()!, saveInDebugLog: true);
                    Log.info("NeuraSDK Token: " + NeuraSDK.shared.appToken()!)
                }
                Log.info("NeuraSDK appId: " + NeuraSDK.shared.appUID!);
                Log.info("NeuraSDK AppSecret: " + NeuraSDK.shared.appSecret!)
    
                #endif
                
                NeuraSDK.shared.requireSubscriptions(toEvents: NEURA_MOMENTS_ARRAY, method: NSubscriptionMethod.webhook)
                NeuraSDK.shared.requireSubscriptions(toEvents: NEURA_PREDICTIONS_ARRAY, method: NSubscriptionMethod.webhook)
                
                postUserInfo(userId: MZSession.sharedInstance.authInfo!.userId, neuraUserId: NeuraSDK.shared.neuraUserId()!, neuraToken: NeuraSDK.shared.appToken()!) { (success) in
                    print(success)
                }
            }
            
            Log.info("Neura initialized");
        }
    }
    
    static func postUserInfo(userId: String, neuraUserId : String, neuraToken: String, completion: @escaping (_ success: Bool) -> Void)
    {
        MZNeuraWebService.shared.sendNeuraUser(userId: userId, neuraUserId: neuraUserId, neuraToken: neuraToken, { (response, error) in
            if error != nil
            {
                completion(false)
                return
            }
            else
            {
                completion(true)
                return
            }
        })
    }

}
