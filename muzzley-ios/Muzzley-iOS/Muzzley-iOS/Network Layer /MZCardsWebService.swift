//
//  MZCardsWebService.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

class MZCardsWebService: MZBaseWebService
{
    static let key_elements         = "elements"
    static let key_cardId           = "cardId"
    static let key_feedback         = "feedback"
    static let key_fields           = "fields"
    static let key_triggeredAction  = "triggeredAction"
    static let key_clickedAction    = "clickedAction"

	static let key_request_url_params		= "urlParams"
	
    static let NSURLErrorConflit    = 409
    
    static let key_capabilitiesGraphical    = "muz-capabilities-graphical"
    static let key_capabilitiesFunctional   = "muz-capabilities-functional"
	
	
	
    //TO USE MOCK
    static let use_mock : Bool = false
    
	class var sharedInstance : MZCardsWebService
    {
		struct Singleton
        {
			static let instance = MZCardsWebService()
		}
		return Singleton.instance
	}
	
    func getCardsObservableForCurrentUser (_ parameters : NSDictionary) -> Observable<(AnyObject)>
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        return Observable.create({ (observer) -> Disposable in
          
            var path = MZEndpoints.Cards(parameters[KEY_USER] as! String)
			
			if let urlParams = parameters[MZCardsWebService.key_request_url_params] as? String
			{
				path = path + urlParams
				path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
			}

            #if DEBUG
            if MZCardsWebService.use_mock
            {
                path = "https://jsonblob.com/api/b87e00b9-c632-11e8-b911-bb59e56ce918" //full list
            }
            #endif
            
            // https://bitbucket.org/muzzley/muzzley-wiki/wiki/muzzley-postman/Cards
           // let payload : [String: AnyObject] = [MZCardsWebService.key_capabilitiesGraphical: "browse,reply,done,create-shortcut,dismiss,show-info,share,no-image,create-usecase",
            //    MZCardsWebService.key_capabilitiesFunctional: "picker-location,picker-device,picker-time-weekday,picker-text,picker-single-choice,picker-multi-choice,picker-ads-list"];
			
			self.httpGet(path, parameters: nil, success: { (sessionManager, responseObject) in
				observer.onNext(responseObject as AnyObject)
				observer.onCompleted()
			}, failure: { (sessionManager, error) in
				if let err = error as? NSError
				{
				if (err.code == NSURLErrorCancelled) { return; }
				observer.onError(err)
				}
			})
			
            return Disposables.create {}
        })
    }
    
    
    func postCardFeedback (_ parameters : NSDictionary, completion : ((_ error : NSError?) -> Void)?) -> Void
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path = MZEndpoints.CardFeedback(parameters[KEY_USER] as! String, cardId: parameters[MZCardsWebService.key_cardId] as! String)
		
        var payload : [String: AnyObject] = ["id" : parameters[MZCardsWebService.key_cardId]! as AnyObject]
        if let fields : NSArray = parameters[MZCardsWebService.key_fields] as? NSArray
        {
            payload["fields"] = fields
        }
        if let actionTriggered: NSDictionary = parameters[MZCardsWebService.key_triggeredAction] as? NSDictionary
        {
            payload["triggeredAction"] = actionTriggered
        }
        if let actionClicked: NSDictionary = parameters[MZCardsWebService.key_clickedAction] as? NSDictionary
        {
            payload["clickedAction"] = actionClicked
        }
        if let feedback : NSString = parameters[MZCardsWebService.key_feedback] as? NSString
        {
            payload["feedback"] = feedback
        }

		
		self.httpPost(path, parameters: payload as AnyObject, success: { (sessionManager, result) in
			completion?(nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				if(err.code == NSURLErrorCancelled) { return }
				if (err.code == MZCardsWebService.NSURLErrorConflit)
				{
					completion?(nil)
					return
				}
				completion?(err)
			}
		}
    }
    
    
    
    func deleteAutomationCards (completion : ((_ error : NSError?) -> Void)?) -> Void
    {
        self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
        
        let path = MZEndpoints.CardsType(MZSession.sharedInstance.authInfo!.userId, "automation")
        
        self.httpDelete(path, parameters: nil, success: { (sessionManager, result) in
            completion?(nil)
        }) { (sessionManager, error) in
            if let err = error as? NSError
            {
                if(err.code == NSURLErrorCancelled) { return }
                if (err.code == MZCardsWebService.NSURLErrorConflit)
                {
                    completion?(nil)
                    return
                }
                completion?(err)
            }
        }
    }
    
    
    func getProductDetail(_ detailUrl: String, location: (latitude: Double, longitude: Double), completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        #if DEBUG
        if MZCardsWebService.use_mock
        {
			
			self.httpGet("https://api.myjson.com/" + detailUrl, parameters: nil, success: { (sessionDataTask, result) in
				completion(result as AnyObject, nil)

			}, failure: { (session, error) in
				if let err = error as? NSError
				{
					completion(nil, err)
				}
			})
			return
        }
        #endif
        
        let path = "/" + detailUrl
		
		self.httpPost(path, parameters: ["latitude": location.latitude, "longitude": location.longitude] as AnyObject, success: { (sessionManager, result) in
			completion(result as AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				completion(nil, err)
			}
		}
    }
    
    func setCardViewFeedback(_ parameters : NSDictionary, cardId: String, storeId: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path =  MZEndpoints.CardAdsView(parameters[KEY_USER] as! String, cardId: cardId, adId: storeId)
		
		self.httpPost(path, parameters: nil, success: { (sessionManager, result) in
			completion(result as? AnyObject, nil)
			
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				completion(nil, err)
			}
		}
    }
    
    func setCardClickFeedback(_ parameters : NSDictionary, cardId: String, storeId: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
		
		self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)

        let path =  MZEndpoints.CardAdsClick(parameters[KEY_USER] as! String, cardId: cardId, adId: storeId)
		
		self.httpPost(path, parameters: nil, success: { (sessionManager, result) in
			completion(result as? AnyObject, nil)
		}) { (sessionManager, error) in
			if let err = error as? NSError
			{
				completion(nil, err)
			}
		}
    }
}
