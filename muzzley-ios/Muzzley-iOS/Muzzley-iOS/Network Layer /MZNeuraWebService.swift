//
//  MZNeuraWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 12/04/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//


class MZNeuraWebService : MZBaseWebService
{
    
    static let shared = MZNeuraWebService()
    
    func sendNeuraUser(userId: String, neuraUserId : String, neuraToken : String, _ completion: @escaping (_ response: Any?, _ error: Error?) -> Void)
    {
        self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
        
        var payload = [String : String]()
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        if deviceId != nil
        {
            payload["device_id"] = deviceId
        }
        
        payload["user_id"] = userId
        payload["neura_user_id"] = neuraUserId
        payload["neura_app_token"] = neuraToken
        
        let path = MZEndpoints.NeuraInbox()
        
        self.httpPost(path, parameters: payload as AnyObject, success: { (dataTask, responseObj) in
            completion(responseObj, nil)
        }) { (dataTask, error) in
            completion(nil, error)
        }
      
        
    
      
    }
}
