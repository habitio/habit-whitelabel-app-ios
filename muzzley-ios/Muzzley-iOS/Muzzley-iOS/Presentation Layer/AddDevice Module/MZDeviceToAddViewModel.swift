//
//  MZServiceDeviceViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 26/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
// Delegate to update UI
// ViewStateUpdated - Hides and shows appropriate views
public enum MZViewStateEnum
{
	case normal
	case error
	case loading
}

class MZDeviceToAddViewModel
{
	var requiresPassword = false
	var setNewPassword = false
	var password = ""
	
	var deviceImage = ""
	var deviceName = ""
	var channelId = ""
	var showError = false
	var isSelected = false
	
	var profile : MZChannelTemplate?
	var channelSubscription : MZChannelSubscription?
    
	var errorMessage = NSLocalizedString("add_bundle_device_not_found", comment: "")
	
	var loadingMessage = NSLocalizedString("bundle_loading_device_message", comment: "")
	
	var currentStepStr = "" // 1/5...
	
	
	var viewState = MZViewStateEnum.normal // Default on start
		{
		didSet
		{
			switch(viewState)
			{
				
				case MZViewStateEnum.normal:
					break
				
				case MZViewStateEnum.error:
					break
	
			default:
				break
			}
		}
	}
	
	init(profile: MZChannelTemplate)
	{
		self.profile = profile
		self.deviceName = profile.name
		if(profile.photoUrlSquared != nil)
		{
			self.deviceImage = profile.photoUrlSquared
		}
		self.viewState = MZViewStateEnum.normal
		if(profile.identifier == "57d948c63872c4f17cea6db3")
		{
			self.requiresPassword = true
		}
		else
		{
			self.requiresPassword = false
		}
	}
	
	init(profile: MZChannelTemplate, channelSubscription: MZChannelSubscription)
	{
		self.profile = profile
		self.channelSubscription = channelSubscription
        
		self.deviceName = channelSubscription.content
		self.deviceImage = channelSubscription.photoUrl
		self.viewState = MZViewStateEnum.normal
		

        self.requiresPassword = false
	}
}
