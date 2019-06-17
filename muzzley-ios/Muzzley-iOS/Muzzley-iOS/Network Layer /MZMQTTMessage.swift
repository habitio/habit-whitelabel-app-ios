//
//  MZMQTTMessage.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

open class MZMQTTMessage : NSObject
{
	open var topic : String
	open var message: NSDictionary
	
	init(topic : String, message : NSDictionary)
	{
		self.topic = topic
		self.message = message
	}
	
	override init()
	{
		self.topic = ""
		self.message = NSDictionary()
	}
}
