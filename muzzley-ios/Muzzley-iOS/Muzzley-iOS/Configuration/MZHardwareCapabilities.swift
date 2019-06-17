//
//  MZHardwareCapabilities.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 19/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZHardwareCapabilities : NSObject
{
    static var supportedCapabilities: [String]
    {
        get {
            return ["location", "push-notifications", "bg-audio", 
                NONE_CAPABILITY]
        }
    }
}
