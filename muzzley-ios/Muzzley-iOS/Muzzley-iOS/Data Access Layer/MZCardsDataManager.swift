//
//  MZCardsDataManager.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 26/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

let MZCardsDataManagerErrorDomain = "MZCardsDataManagerErrorDomain";


class MZCardsDataManager
{
    var cards = NSMutableArray ()
    
    class var sharedInstance : MZCardsDataManager
	{
        struct Singleton
		{
            static let instance = MZCardsDataManager()
        }
        return Singleton.instance
    }
    
    func getObservableOfCardsForCurrentUser (_ parameters : NSDictionary) -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            if MZSession.sharedInstance.authInfo == nil
            {

            }
            else
            {
                let userId : String = MZSession.sharedInstance.authInfo!.userId
                let mutableDict = NSMutableDictionary(dictionary: parameters)
                mutableDict.addEntries(from: [KEY_USER : userId])
                
                let observable = MZCardsWebService.sharedInstance.getCardsObservableForCurrentUser(mutableDict)
                observable.subscribe(
                    onNext: { (results) -> Void in
                        
                        self.cards = NSMutableArray ()
                        
                        if(results is NSDictionary)
                        {
                            if let resultCards : NSArray = (results as! NSDictionary).value(forKey: MZCardsWebService.key_elements) as! NSArray
                            {
                                self.cards = NSMutableArray ()
                                
                                var newCard : MZCard
                                for card in resultCards
                                {
                                    newCard = MZCard(dictionary: card as! NSDictionary);
                                    self.cards.add(newCard)
                                }
                            }
                        }
                        observer.onNext(self.cards)
                        observer.onCompleted()
                    },
                    onError: { (error) -> Void in
                        observer.onError(NSError(domain: MZCardsDataManagerErrorDomain, code: 0, userInfo: nil))
                        observer.onCompleted()
                    })
               
            }
             return Disposables.create()
		})
    }
    
    
 
    func deleteAutomationCards (completion : ((_ error : NSError?) -> Void)?) -> Void
    {
        MZCardsWebService.sharedInstance.deleteAutomationCards(completion: { (error) in
            completion!(error)
        })
    }
    
    func sendCardFeedback (_ parameters : NSMutableDictionary, completion : ((_ error : NSError?) -> Void)?) -> Void
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId

        parameters[KEY_USER] = userId
        
        if let action : MZStageAction = parameters[KEY_ACTION] as? MZStageAction
        {
            parameters[MZCardsWebService.key_triggeredAction] = action.dictionaryRepresentation
        }

        MZCardsWebService.sharedInstance.postCardFeedback(parameters) { (error) -> Void in
            completion?(error) 
        }
    }
    
    func sendCardNotify (_ parameters : NSMutableDictionary) -> Void
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId
        
		
        parameters[KEY_USER] = userId
        
        if let action : MZStageAction = parameters[KEY_ACTION] as? MZStageAction
        {
            parameters[MZCardsWebService.key_clickedAction] = action.dictionaryRepresentation
        }
        
        MZCardsWebService.sharedInstance.postCardFeedback(parameters) { (error) -> Void in }
    }
    
    func getProductDetail(_ detailUrl: String, location: (Double, Double), completion: @escaping (_ result: MZProduct?, _ error: NSError?) -> Void)
    {
        MZCardsWebService.sharedInstance.getProductDetail(detailUrl, location: location) { (result, error) -> Void in
            if error == nil {
                let product: MZProduct = MZProduct(dictionary: result as! NSDictionary)
                completion(product, error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func setCardViewFeedback(_ cardId: String, storeId: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId

        MZCardsWebService.sharedInstance.setCardViewFeedback([KEY_USER : userId], cardId: cardId, storeId: storeId) { (result, error) -> Void in
            // TODO: deal with response
            if error == nil {
                completion(result, error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func setCardClickFeedback(_ cardId: String, storeId: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        let userId : String = MZSession.sharedInstance.authInfo!.userId

        MZCardsWebService.sharedInstance.setCardClickFeedback([KEY_USER : userId],cardId: cardId, storeId: storeId) { (result, error) -> Void in
            // TODO: deal with response
            if error == nil
			{
                completion(result, error)
            }
			else
			{
                completion(nil, error)
            }
        }
    }
}
