	//
//  MZServicesDataManager.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 06/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import RxSwift
//import RxCocoa

let MZServicesDataManagerErrorDomain = "MZServicesDataManagerErrorDomain";

class MZServicesDataManager
{
	let disposeBag = DisposeBag()
	
	class var sharedInstance : MZServicesDataManager {
		struct Singleton {
			static let instance = MZServicesDataManager()
		}
		return Singleton.instance
	}
	
	func getObservableOfServiceSubscriptions (_ userId: String) -> Observable<(NSDictionary)>
	{
		
		return Observable.create({ (observer) -> Disposable in
			
			MZServicesWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
			
			let observable = MZServicesWebService.sharedInstance.getServiceSubscriptionsObservable(userId)
			
			observable.subscribe(
				onNext: { (result) -> Void in
					if let servicesDict: NSDictionary = result as? NSDictionary
					{
						observer.onNext(servicesDict)
						observer.onCompleted()
					}
					else
					{
						observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
					}
					
				}, onError: { (errorType) -> Void in
					observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
				}, onCompleted: { () -> Void in
					
			}).addDisposableTo(self.disposeBag)
			
			return Disposables.create {
				
			} 
		})
	}
	
	
	// Add service observables
	
	func getObservableOfAllServices () -> Observable<(NSDictionary)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			MZServicesWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
			
			let observable = MZServicesWebService.sharedInstance.getAllServicesObservable()
			
			observable.subscribe(
				onNext: { (result) -> Void in
				if let bundlesAndServicesDic: NSDictionary = result as? NSDictionary
				{
					observer.onNext(bundlesAndServicesDic)
					observer.onCompleted()
				}
				else
				{
					observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
				}
				
				}, onError: { (errorType) -> Void in
					observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
				}, onCompleted: { () -> Void in
					
			}).addDisposableTo(self.disposeBag)
			
			return Disposables.create {}
		})
	}

	func getObservableOfProfileById (_ profileId: String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			MZServicesWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
			
			let observable = MZServicesWebService.sharedInstance.getProfileByIdObservable(profileId)
			
			observable.subscribe(
				onNext: { (result) -> Void in
					
					if let prof: NSDictionary = result as? NSDictionary
					{
                        let channelTemplate = MZChannelTemplate()
                        channelTemplate.convertProfileToChannelTemplate(dictionary: prof)
						observer.onNext(channelTemplate)
						observer.onCompleted()
					}
					else
					{
						observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
					}
					
				}, onError: { (errorType) -> Void in
					observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
				}, onCompleted: { () -> Void in
					
			}).addDisposableTo(self.disposeBag)
			
			return Disposables.create {}
		})
	}
    
    func getObservableOfChannelTemplateById (_ channelTemplateId: String) -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            MZServicesWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
            
            let observable = MZServicesWebService.sharedInstance.getChannelTemplateByIdObservable(channelTemplateId)
            
            observable.subscribe(
                onNext: { (result) -> Void in
                    
                    if let template: NSDictionary = result as? NSDictionary
                    {
                        let channelTemplate = MZChannelTemplate(dictionary: template)
                        
                        observer.onNext(channelTemplate)
                        observer.onCompleted()
                    }
                    else
                    {
                        observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
                    }
                    
            }, onError: { (errorType) -> Void in
                observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
            }, onCompleted: { () -> Void in
                
            }).addDisposableTo(self.disposeBag)
            
            return Disposables.create {}
        })
    }
	
	
	func getObservableOfServiceAuthorizationUrl (_ serviceId: String) -> Observable<(AnyObject)>
	{
		
		return Observable.create({ (observer) -> Disposable in
			
			MZServicesWebService.sharedInstance.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
			
			let observable = MZServicesWebService.sharedInstance.getServiceAuthorizationUrlObservable(serviceId)
			
			observable.subscribe(
				onNext: { (result) -> Void in
					
					let error = result as? NSError
					if(error != nil)
					{
						if(error?.userInfo["location"] != nil)
						{
							if let authorizationUrl: String = ((result as? NSError)?.userInfo["location"] as! String)
							{
								observer.onNext(authorizationUrl as AnyObject)
								observer.onCompleted()
							}
							else
							{
								observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
							}
						}
					}
					
				}, onError: { (error) -> Void in
					observer.onError(error)
				}).addDisposableTo(self.disposeBag)
			
			return Disposables.create {}
		})
	}

	
	func getObservableOfChannelsSubscriptionsByProfile (_ profileId: String) -> Observable<(AnyObject)>
	{
		return Observable.create({ (observer) -> Disposable in
			
			
			let observable = MZServicesWebService.sharedInstance.getChannelsSubscriptionsByProfileObservable(profileId)
			
			observable.subscribe(
				onNext: { (result) -> Void in
					
					if let channels: NSArray = result as? NSArray
					{
						var subscriptions = [MZChannelSubscription]()
						for chan in channels
						{
							subscriptions.append(MZChannelSubscription(dictionary: chan as! NSDictionary))
						}
						
						observer.onNext(subscriptions as AnyObject)
						observer.onCompleted()
					}
					else
					{
						observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
					}
					
				}, onError: { (errorType) -> Void in
					observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
				}, onCompleted: { () -> Void in
					
			}).addDisposableTo(self.disposeBag)
			
			return Disposables.create {}
		})
	}
	
	func getObservableOfChannelsFilteredByProfile (_ profileId: String) -> Observable<(AnyObject)>
	{
		
		let userId : String = MZSession.sharedInstance.authInfo!.userId

		
		return Observable.create({ (observer) -> Disposable in
			
			
			let observable = MZServicesWebService.sharedInstance.getChannelsFilteredByProfileObservable(userId, profileId: profileId)
			
			observable.subscribe(
				onNext: { (result) -> Void in
					
					if let channelsObj : NSDictionary = result as? NSDictionary
					{
					
						if let channels: NSArray = channelsObj["channels"] as? NSArray
						{
						
							var channelsArray = [MZChannel]()
							for chan in channels
							{
								channelsArray.append(MZChannel(dictionary: chan as! NSDictionary))
							}
						
							observer.onNext(channelsArray as AnyObject)
							observer.onCompleted()
						}
						else
						{
							observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
						}
					}
					
				}, onError: { (errorType) -> Void in
					observer.onError(NSError(domain: MZServicesDataManagerErrorDomain, code: 0, userInfo: nil))
				}, onCompleted: { () -> Void in
					
			}).addDisposableTo(self.disposeBag)
			
			return Disposables.create {}
		})
	}
	
	func subscribeToService (_ serviceId: String, payload: NSDictionary, completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
	{
		
		MZServicesWebService.sharedInstance.subscribeToService(serviceId, payload: payload) { (result, error) in
			if(error == nil)
			{
				completion(result, nil)
			}
			else
			{
				completion(nil, error)
			}
		}
		
	}
}
