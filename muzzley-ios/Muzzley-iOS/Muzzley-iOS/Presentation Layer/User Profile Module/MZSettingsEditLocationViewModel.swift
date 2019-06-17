//
//  MZSettingsEditLocationViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 12/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation


class MZSettingsEditLocationViewModel
{
	var name : String = ""
	var wifi : String = ""
	var wifiInfo : MZWifi = MZWifi()
	var placeVM : MZPlaceViewModel = MZPlaceViewModel()
	var address : String = ""
	var longitude : Double = Double.NaN
	var latitude : Double = Double.NaN
	
	init(place : MZPlaceViewModel)
	{
		self.placeVM = place
		self.name = place.name
		self.wifiInfo = place.wifi
		self.address = place.address
		self.wifi = self.wifiInfo.ssid
		self.longitude = place.longitude
		self.latitude = place.latitude
	}
	
	func saveLocation(completion: (result: Bool) -> Void)
	{
		
		let payload : [String: AnyObject] = ["id" : self.placeVM.id, "name" : self.name, "address" : self.address , "latitude" : self.latitude, "longitude" : self.longitude, "wifi" : [[ "ssid" : self.wifiInfo.ssid, "bssid" : self.wifiInfo.bssid]]]
		
		MZSessionDataManager.sharedInstance.updatePlace(placeVM.id, updatedPlace: payload ) { (result, error) in
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
	
	func deleteLocation(completion: (result: Bool) -> Void)
	{
		MZSessionDataManager.sharedInstance.deletePlace(placeVM.id) { (result, error) in
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