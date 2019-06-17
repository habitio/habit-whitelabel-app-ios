//
//  MZServiceProfileDevicesViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 26/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZProfileDevicesViewModel
{
	var devices = [MZDeviceToAddViewModel]()
	
	
	var showTerms = false
	
	var acceptedTerms = false
	
	var termsDisabled = false // overlay over terms
	
	var profile : MZChannelTemplate
	
	var channelsSubscriptions = [MZChannelSubscription]()
	var occurrences = 0
	
	var isLoading = true
	
	var loadingTopText = ""
	var loadingSideText = ""
	var numberOfSteps = -1;
	
	var showGroupError = false
	
	
	init(profile: MZChannelTemplate, occurrences: Int, loading: Bool)
	{
		devices.removeAll()
		
		self.profile = profile
		self.occurrences = occurrences

        if(self.profile.termsUrl != nil && !self.profile.termsUrl.isEmpty)
		{
			self.showTerms = true
		}
		else
		{
			self.showTerms = false
		}
		
		self.channelsSubscriptions.removeAll()
		self.isLoading = loading
		if(self.occurrences > 0)
		{
			for _ in 1...self.occurrences
			{
				let dev = MZDeviceToAddViewModel(profile: profile)
				dev.showError = false
				devices.append(dev)
			}
		}
		else
		{
			let dev = MZDeviceToAddViewModel(profile: profile)
			dev.showError = false
			devices.append(dev)
		}
	}

	func updateChannelsSubscriptions(_ channelsSubs: [MZChannelSubscription])
	{
		devices.removeAll()
		
		self.channelsSubscriptions = channelsSubs
		if(channelsSubs.count == 0)
		{
			
			if(self.occurrences > 0)
			{
				for _ in 1...self.occurrences
				{
					let dev = MZDeviceToAddViewModel(profile: profile)
					dev.showError = true
					devices.append(dev)
					showGroupError = true
				}
			}
			else
			{
				let dev = MZDeviceToAddViewModel(profile: profile)
				dev.showError = true
				devices.append(dev)
				showGroupError = true
			}
		}
		else
		{
			for chan in channelsSubs
			{
				let dev = MZDeviceToAddViewModel(profile: profile, channelSubscription: chan)
				dev.showError = false
				devices.append(dev)
			}
			
			if(self.occurrences > 0 && devices.count < occurrences)
			{
				for _ in 1...(self.occurrences - devices.count)
				{
					let dev = MZDeviceToAddViewModel(profile: profile)
					dev.showError = true
					devices.append(dev)
				}
				
				showGroupError = true
			}
			else
			{
				showGroupError = false
				if devices.count == occurrences
				{
					for dev in devices
					{
						dev.isSelected = true
					}
				}
				
				if devices.count > occurrences
				{
					for dev in devices
					{
						dev.isSelected = false
					}
				}
			}
		}
	}
    
	
	func isGroupValid() -> Bool
	{
		let nSelected = self.devices.filter{$0.isSelected}.count
		
		let nWithError = self.devices.filter{$0.showError}.count
		if(nWithError > 0)
		{
			return false
		}
		
		if(nSelected == 0)
		{
			return false
		}
		
		if(occurrences > 0 && occurrences != nSelected)
		{
			return false
		}
		
		if(self.showTerms && !self.acceptedTerms)
		{
			return false
		}
		
		return true
	}
}
