//
//  MZChannelDataManager.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 24/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

let MZChannelsDataManagerErrorDomain = "MZChannelsDataManagerErrorDomain"

class MZChannelsDataManager
{
    var channels = NSMutableDictionary ()

    class var sharedInstance : MZChannelsDataManager {
        struct Singleton {
            static let instance = MZChannelsDataManager()
        }
        return Singleton.instance
    }


    func getObservableOfChannelForCurrentUser (_ parameters: NSDictionary?) -> Observable<(Any)>
    {
		
        return Observable.create({ (observer) -> Disposable in
			
			let userId : String = MZSession.sharedInstance.authInfo!.userId

            //let webservice = (self.webservice as? MZChannelsWebServiceOLD)!
            
            let channelsParams : NSMutableDictionary = NSMutableDictionary()
    
            channelsParams[KEY_USER] =  userId
            channelsParams[KEY_INCLUDE] = "context,specs,channelProperties"
    
            if parameters != nil
            {
                if let include:String = parameters![MZTilesWebService.key_include] as? String
                {
                    channelsParams[MZTilesWebService.key_include] = "\(include),\(channelsParams[MZTilesWebService.key_include]!)"
                }
            }
			
		
			
            MZChannelsWebService.sharedInstance.getChannels(parameters, completion: { (result, error) in
		
                if (error != nil)
                {
                    observer.onError(error!)
                }
				else
				{
                    
                    if(result is NSDictionary)
                    {
                        var resultArray : NSArray = NSArray()
                        
                        if let array = (result as! NSDictionary)[KEY_CHANNELS] as? NSArray
						{
                            resultArray = array
                        }
                        
                        self.channels = NSMutableDictionary()

                        for channelDic in resultArray
						{
                            if (channelDic is NSDictionary)
                            {
                                let channel: MZChannel = MZChannel (dictionary: channelDic as! NSDictionary)
                                self.channels[channel.identifier] = channel
                            }
                        }
                        
                        observer.onNext(self.channels)
                        observer.onCompleted()
                    }
					else
					{
                        observer.onError(NSError( domain: MZChannelsDataManagerErrorDomain, code: 0, userInfo: nil))
                    }
                }

            	})
			return Disposables.create {}
        })
    }
}
