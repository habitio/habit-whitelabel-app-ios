//
//  MZCoreClientHelper.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 13.01.17.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZCoreClientHelper: NSObject
{
    
    static func getStringValue(_ response : MZResponseMessage? ) -> String?
    {
        if let value = getValue(response) as? String
        {
            return value
        }

        return nil
    }
    
    static func getDictionaryValue(_ response : MZResponseMessage? ) -> NSDictionary?
    {
        if let value = getValue(response) as? NSDictionary
        {
            return value
        }
        
        return nil
    }
    
    
    static func getValue(_ response : MZResponseMessage? ) -> AnyObject?
    {
        if response != nil
        {
            let responseDict:NSDictionary = response!.toDictionary() as! NSDictionary
            
            if let d:NSDictionary = responseDict["d"] as? NSDictionary
            {
                if let p:NSDictionary = d["p"] as? NSDictionary
                {
                    if let data:NSDictionary = p["data"] as? NSDictionary
                    {
                        
                        if p["profile"] == nil || p["channel"] == nil || p["component"] == nil || p["property"] == nil
                        {
                            print ("Response ignored!")
                            return nil
                        } else {
                            return data["value"] as! AnyObject
                        }
                    }
                }
            }
        }
        return nil
    }


}
