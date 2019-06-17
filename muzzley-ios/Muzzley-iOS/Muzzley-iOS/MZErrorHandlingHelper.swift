//
//  ErrorHandlingHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 28/09/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZErrorHandlingHelper : NSObject
{
    static func getErrorCode(error: Error) -> String
    {
        var xcode : String? = ""
        if((error as! NSError).userInfo["com.alamofire.serialization.response.error.response"]  != nil)
        {
            if (error as! NSError).userInfo["com.alamofire.serialization.response.error.response"] is HTTPURLResponse
            {
                xcode = ((error as! NSError).userInfo["com.alamofire.serialization.response.error.response"] as! HTTPURLResponse).allHeaderFields["X-Error"] as? String
                if xcode == nil
                {
                    xcode = ""
                }
            }
        }
        return xcode!

    }
}
