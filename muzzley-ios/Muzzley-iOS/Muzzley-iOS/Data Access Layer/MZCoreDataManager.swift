//
//  MZCoreDataManager.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 24/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

let MZCoreDataManagerErrorDomain = "MZCoreDataManagerErrorDomain";

class MZCoreDataManager : NSObject
{
    class var sharedInstance : MZCoreDataManager {
        struct Singleton {
            static let instance = MZCoreDataManager()
        }
        return Singleton.instance
    }
    
    func publish(_ params: [String:AnyObject], completion: @escaping (_ result: NSDictionary?, _ error : NSError?) -> Void)
    {
        
        MZCoreWebService.sharedInstance.publish(params as NSDictionary, completion: { (result, error) -> Void in
            if error == nil {
                completion(result as? NSDictionary, nil)
            } else {
                completion(nil, error)
            }
        })
    }
}
