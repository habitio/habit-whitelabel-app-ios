//
//  MZWifi.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 01/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZWifi
{
	var ssid : String = ""
	var bssid : String = ""
	
	init()
	{}
	
	init(SSID : String, BSSID : String)
	{
		self.ssid = SSID
		self.bssid = BSSID
	}
}
