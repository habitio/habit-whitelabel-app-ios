//
//  MZNotificationCenterTokens.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 01/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

struct MZNotificationKeys
{
	struct UserProfile
	{
		static let UnitsSystemUpdated = "UnitsSystemUpdated"
		static let HourFormatUpdated = "HourFormatUpdated"
		static let SettingsUpdated = "SettingsUpdated"
		static let DebugLogEnabled = "DebugLogEnabled"
	}
	
	struct Places
	{
		static let PlaceAdded = "PlaceAdded"
		static let PlaceUpdated = "PlaceUpdated"
		static let PlaceDeleted = "PlaceDeleted"
	}
	struct Tiles
	{
		static let Reload = "Reload"
		static let TileAdded = "TileAdded"
		static let TileUpdated = "TileUpdated"
		static let TileRemoved = "TileRemoved"
	}

	struct Workers
	{
		static let WorkerAdded = "WorkerAdded"
		static let WorkerUpdated = "WorkerUpdated"
		static let WorkerRemoved = "WorkerRemoved"
	}
	
	
	struct Shortcuts
	{
		static let ShortcutAdded = "ShortcutAdded"
		static let ShortcutUpdated = "ShortcutUpdated"
		static let ShortcutRemoved = "ShortcutRemoved"
	}
	
	struct NativeView
	{
		static let StartBackgroundAudioStream = "StartBackgroundAudioStream"
		static let StopBackgroundAudioStream = "StopBackgroundAudioStream"
        static let PauseBackgroundAudioStream = "PauseBackgroundAudioStream"
        static let SetupBackgroundAudioStream = "SetupBackgroundAudioStream"
        static let EndBackgroundAudioStream = "EndBackgroundAudioStream"
	}
}
