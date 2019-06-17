//
//  MZUnitsViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 13/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import RxSwift

class MZUnitsViewModel
{
	// Used to handle the MZUnitsViewController
	
	enum ViewShown
	{
		case loading
		case error
		case mainView
	}
	
		
	var currentView = ViewShown.mainView // Use did set to update view
	
	var errorMessage = String("") // "Couldn't update your settings right now" or something like this
	
	var units = String("")
	var isMetricSelected = Bool(false)
	var isImperialSelected = Bool(false)
	
	// To be used to be binded from the UI RadioButtons
	// (Consider just using one variable as in IsMetric and just return !IsMetric for Imperial
	
	init()
	{
		units = MZSessionDataManager.sharedInstance.session.userProfile.preferences.units
		if(units == "metric")
		{
			isMetricSelected = true
			isImperialSelected = false
		}
		else
		{
			isMetricSelected = true
			isImperialSelected = false
		}
		
		// Bind the units to the  MZModelManager.sessionDM.session.value.userSettings.value.units to listen to changes
	}
	
	func updateVM(_ newUnits: String)
	{
		switch newUnits
		{
			case "metric":
				isMetricSelected = true
				isImperialSelected = false
				setMetricSystem()
			
			case "imperial":
				isMetricSelected = false
				isImperialSelected = true
				setImperialSystem()
			
			default:
				break
				//Shouldn't happen but lets keep it just in case
		}
	}
	
	func setMetricSystem()
	{
		MZSessionDataManager.sharedInstance.session.userProfile.preferences.units = "metric"
		// wait for this and then update VMS
	}
	
	func setImperialSystem()
	{
		MZSessionDataManager.sharedInstance.session.userProfile.preferences.units = "imperial"
		
		// wait for this and then update VMS
	}
	
	
	
}
