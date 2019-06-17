//
//  MZServiceDevicesSelectionViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 26/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZDevicesSelectionViewModel
{
	var hiddenDevicesByProfile = [MZProfileDevicesViewModel]()

	var groupedDevicesByProfile = [MZProfileDevicesViewModel]()
	
	var label = NSLocalizedString("bundle_searching_devices_message", comment: "")
	
	var title = NSLocalizedString("bundle_devices_selection_title", comment: "")

	var buttonLabel = NSLocalizedString("bundle_devices_selection_button", comment: "")
	
	var isButtonHidden = true

	var _profiles : [MZChannelTemplate]
	
	var _service : MZService?
	
	init(service: MZService, profiles: [MZChannelTemplate])
	{
		self._profiles = profiles
		self._service = service
		self.groupedDevicesByProfile.removeAll()
		
		for p in self._profiles
		{
			var addToGroupedDevices = true
			var occurrences = 0
			for bp in (_service?.profiles)!
			{
				if(p.identifier == bp.id)
				{
					occurrences = bp.occurrences

					if(bp.occurrences == -1) // -1 hidden. 0 -No minimum
					{
						hiddenDevicesByProfile.append(MZProfileDevicesViewModel(profile: p, occurrences: occurrences, loading: true))
						addToGroupedDevices = false
						break
					}
					break
				}
			}
			if(addToGroupedDevices)
			{
				groupedDevicesByProfile.append(MZProfileDevicesViewModel(profile: p, occurrences: occurrences, loading: true))
			}
		}
	}
	
	init(profiles: [MZChannelTemplate])
	{
		self._profiles = profiles
		self._service = nil
		self.groupedDevicesByProfile.removeAll()
		
		for p in self._profiles
		{
			groupedDevicesByProfile.append(MZProfileDevicesViewModel(profile: p, occurrences: 0, loading: true))
		}
	}
}






