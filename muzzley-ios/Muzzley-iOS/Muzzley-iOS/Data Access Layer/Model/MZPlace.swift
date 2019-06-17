//
//  MZPlace.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 01/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZPlace
{
	let key_id = "id"
	let key_name = "name"
	let key_address = "address"
	let key_latitude = "latitude"
	let key_longitude = "longitude"
	
	let key_wifi = "wifi"
	let key_wifi_ssid = "ssid"
	let key_wifi_bssid = "bssid"
	
	
	var id : String = ""
	var name : String = ""
	var address : String = ""
	var latitude : Double = Double.nan
	var longitude : Double = Double.nan
	var wifi : [MZWifi] = [MZWifi]()
	
	init(json: [String : Any])
	{
		self.id = json[key_id] as! String
		self.name = json[key_name] as! String
		if let add = json[key_address] as? String
		{
			self.address = add
		}
		else
		{
			self.address = ""
		}
		self.latitude = json[key_latitude] as! Double
		self.longitude = json[key_longitude] as! Double
		let wifis = json[key_wifi] as! [NSDictionary]
		for w in wifis
		{
			wifi.append(MZWifi(SSID: w[key_wifi_ssid] as! String, BSSID: w[key_wifi_bssid] as! String))
		}
	}
}
