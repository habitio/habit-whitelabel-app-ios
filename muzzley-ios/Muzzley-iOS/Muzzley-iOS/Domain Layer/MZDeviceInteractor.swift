//
//  MZDeviceInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 12.01.17.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZDeviceInteractor: MZBaseInteractor
{
    var allDevices : [NSDictionary]?

	override init()
	{
		super.init()
	}
	
    convenience init(otherInteractor:MZDeviceInteractor)
    {
        self.init()
        self.allDevices = otherInteractor.allDevices
    }
    
    func setDevices(_ data:NSDictionary) -> Void
    {
        if let devices = data["devices"] as? [NSDictionary]
        {
            self.allDevices = devices
        }
    }
}
