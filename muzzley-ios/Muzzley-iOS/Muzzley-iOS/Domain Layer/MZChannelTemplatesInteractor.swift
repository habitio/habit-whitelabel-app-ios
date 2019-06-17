//
//  MZChannelTemplatesInteractor
//  Muzzley-iOS
//
//  Created by Ana Figueira on 15/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZChannelTemplatesInteractor: NSObject {

	override init()
	{
	
	}
	
	func getProfiles(completion: @escaping (_ result: AnyObject?,_ error: NSError?) -> Void)
	{
		MZChannelsWebService.sharedInstance.getProfiles { (profiles, error) in
			if(error == nil)
			{
				if(profiles != nil)
				{
					completion(profiles, nil)
				}
				else
				{
					completion(NSArray(), nil)
				}
			}
			else
			{
				completion(nil,error)
			}
		}
	}
    
    
    func getChannelTemplates(completion: @escaping (_ result: AnyObject?,_ error: NSError?) -> Void)
    {
        MZChannelsWebService.sharedInstance.getChannelTemplates { (channelTemplates, error) in
            if(error == nil)
            {
                if(channelTemplates != nil)
                {
                    completion(channelTemplates, nil)
                }
                else
                {
                    completion(NSArray(), nil)
                }
            }
            else
            {
                completion(nil,error)
            }
        }
    }
    
}
