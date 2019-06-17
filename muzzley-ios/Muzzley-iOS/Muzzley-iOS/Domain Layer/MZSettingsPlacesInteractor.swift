//
//  MZSettingsPlacesInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 30/08/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZSettingsPlacesInteractor
{
	var name : String = ""
	var wifi : String = ""
	var wifiInfo : MZWifi = MZWifi()
	var placeVM : MZPlaceViewModel = MZPlaceViewModel()
	var address : String = ""
	var longitude : Double = Double.nan
	var latitude : Double = Double.nan
	
	init()
	{
	}
	
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
	
	func addLocation(_ completion: @escaping (_ result: Bool) -> Void)
	{
		
		var payload : [String: Any]
		if(self.wifiInfo.ssid.isEmpty)
		{
			payload = ["name" : self.name,
			           "address" : self.address,
			           "latitude" : self.latitude as! Double,
			           "longitude" : self.longitude as! Double,
			           "wifi" : []]
		}
		else
		{
			payload = ["name" : self.name,
			           "address" : self.address,
			           "latitude" : self.latitude as! Double,
			           "longitude" : self.longitude as! Double,
			           "wifi" : [["ssid" : self.wifiInfo.ssid,
						"bssid" : self.wifiInfo.bssid]]]
		}
		
		MZSessionDataManager.sharedInstance.addPlace(payload) { (result, error) in
			if(error == nil)
			{
				completion(true)
			}
			else
			{
				completion(false)
			}
		}
	}
	
	func updateLocation(_ completion: @escaping (_ result: Bool) -> Void)
	{
		
		
		var payload : [String: Any]
		
		if(self.wifiInfo.ssid.isEmpty)
		{
			payload = ["id" : self.placeVM.id,
			           "name" : self.name,
			           "address" : self.address,
			           "latitude" : self.latitude,
			           "longitude" : self.longitude,
			           "wifi" : []]
		}
		else
		{
			payload = ["id" : self.placeVM.id,
			           "name" : self.name,
			           "address" : self.address,
			           "latitude" : self.latitude,
			           "longitude" : self.longitude,
			           "wifi" : [["ssid" : self.wifiInfo.ssid,
						"bssid" : self.wifiInfo.bssid]]]
		}
		
		MZSessionDataManager.sharedInstance.updatePlace(placeVM.id, updatedPlace: payload as NSDictionary ) { (result, error) in
			if(error == nil)
			{
//                dLo: "addPlace \(result)")

				completion(true)
			}
			else
			{
//                dLog(message: "addPlace \(error)")

				completion(false)
			}
		}
	}
	
	func deleteLocation(_ completion: @escaping (_ result: Bool) -> Void)
	{
		MZSessionDataManager.sharedInstance.deletePlace(placeVM.id) { (result, error) in
			if(error == nil)
			{
				completion(true)
			}
			else
			{
				completion(false)
			}
		}
	}
	
	func placeIsValid() -> Bool
	{
		if  latitude == Double.nan ||
			longitude == Double.nan ||
			name.isEmpty ||
			address.isEmpty
		{
			return false
		}
		
		return true
	}
}
