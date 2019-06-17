//
//  MZPlaceViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 05/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZPlaceViewModel {
	var id : String = ""
	var place : MZPlace? = nil
	var name : String = ""
	var address : String = ""
	var latitude : Double = Double.nan
	var longitude : Double = Double.nan
	var wifi : MZWifi = MZWifi()
	
	init()
	{
		id = ""
		place = nil
		name = ""
		address = ""
		latitude = Double.nan
		longitude = Double.nan
		wifi = MZWifi()
	}
	
	init (pl : MZPlace)
	{
		self.place = pl
		self.id = pl.id
		self.name = pl.name
		self.address = pl.address
		self.latitude = pl.latitude
		self.longitude = pl.longitude
		
		if(pl.wifi.count > 0)
		{
			self.wifi = pl.wifi[0]
		}
	}
}
