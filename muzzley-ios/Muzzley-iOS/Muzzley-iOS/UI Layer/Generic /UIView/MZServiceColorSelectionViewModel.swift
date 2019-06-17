//
//  MZServiceColorSelectionViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/02/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZServiceColorSelectionViewModel
{
	var profile : String?
	var channels: [String]?

	init(profile: String, channels: [String])
	{
		self.profile = profile
		self.channels = channels
	}
}
