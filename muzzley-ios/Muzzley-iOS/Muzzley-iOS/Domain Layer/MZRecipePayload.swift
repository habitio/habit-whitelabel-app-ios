//
//  MZRecipePayload.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZRecipePayload : NSObject
{
    var process : String?
    var channelTemplateId : String?
    var clientId : String?
    
    init (process: String, channelTemplateId : String, clientId: String)
    {
        self.process = process
        self.channelTemplateId = channelTemplateId
        self.clientId = clientId
    }
}
