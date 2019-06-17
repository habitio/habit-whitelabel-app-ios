//
//  MZChannelSubscription.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 03/11/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation


class MZChannelSubscription : NSObject
{
	static let key_deviceId   = "device_id"
    static let key_id   = "id"
	static let key_content   = "content"
	static let key_photoUrl   = "photoUrl"
	
    var deviceID: String = ""
	var channelID: String = ""
	var content: String = ""
	var photoUrl: String = ""
	
    override init() {
        
    }
    init (dictionary: NSDictionary)
	{
        
        if let _deviceId = dictionary[MZChannelSubscription.key_deviceId] as? String {
            self.deviceID = _deviceId
        }
        
        if let _id = dictionary[MZChannelSubscription.key_id] as? String {
            self.channelID = _id
        }
        if let _content = dictionary[MZChannelSubscription.key_content] as? String {
            self.content = _content
        }

        if let _photoUrl = dictionary[MZChannelSubscription.key_photoUrl] as? String {
            self.photoUrl = _photoUrl
        }
    }
    

}
