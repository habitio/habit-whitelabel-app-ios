//
//  MZSettingsAddLocationViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 12/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZSettingsAddLocationViewModel
{
	var name : String = ""
	var wifi : String = ""
	var wifiInfo : MZWifi = MZWifi()
	var placeVM : MZPlaceViewModel = MZPlaceViewModel()
	var address : String = ""
	var longitude : Double = Double.NaN
	var latitude : Double = Double.NaN
	
	init()
	{}
	
	init(place : MZPlaceViewModel)
	{
		
		self.placeVM = place
		self.name = place.name
		self.wifiInfo = place.wifi
		self.address = place.address
		print(self.wifiInfo)
		self.wifi = self.wifiInfo.ssid
		self.longitude = place.longitude
		self.latitude = place.latitude
		
	}
	
	func addLocation(completion: (result: Bool) -> Void)
	{
		let payload : [String: AnyObject] = ["name" : self.name, "address" : self.address , "latitude" : self.latitude, "longitude" : self.longitude, "wifi" : [[ "ssid" : self.wifiInfo.ssid, "bssid" : self.wifiInfo.bssid]]]
		
		MZSessionDataManager.sharedInstance.addPlace(payload) { (result, error) in
			if(error == nil)
			{
				completion(result: true)
			}
			else
			{
				completion(result: false)
			}
		}
	}
	
	
	func isPlaceValid() -> Bool
	{
		if  latitude == Double.NaN ||
			longitude == Double.NaN ||
			name.isEmpty ||
			address.isEmpty
		{
			return false
		}
		
		return true
	}
}