//
//  MZRecipesWebservice.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import RxSwift



class MZRecipesWebservice : MZBaseWebService
{
    
    let key_location = "Location"
    let key_custom_headers = "CustomHeaders"
    
    let use_mock = false
    
    class var sharedInstance : MZRecipesWebservice
    {
        struct Singleton {
            static let instance = MZRecipesWebservice()
        }
        return Singleton.instance
    }
    
    
    func postRecipeMetadaObservable (_ recipeId : String) -> Observable<(AnyObject)>
    {
        self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
        
        return Observable.create({ (observer) -> Disposable in
            
            var path = MZEndpoints.RecipeMetadata(recipeId)
            
            if self.use_mock
            {
                path = "https://jsonblob.com/api/jsonblob/1a19b219-ff69-11e7-84aa-4380cfd17dbe"
                
                self.httpGet(path, parameters: nil, success: { (sessionManager, responseObject) in
                    if responseObject == nil
                    {
                        observer.onNext(NSDictionary())
                    }
                    else
                    {
                        observer.onNext(responseObject as AnyObject)
                    }
                    observer.onCompleted()
                }, failure: { (sessionManager, error) in
                    if let err = error as? NSError
                    {
                        if (err.code == NSURLErrorCancelled) { return; }
                        observer.onError(err)
                    }
                })
            }
            else
            {
                self.httpPost(path, parameters: nil, success: { (sessionManager, responseObject) in
                
                    if responseObject == nil
                    {
                        observer.onNext(NSDictionary())
                    }
                    else
                    {
                        observer.onNext(responseObject as AnyObject)
                    }
                    observer.onCompleted()
                }, failure: { (sessionManager, error) in
                    if let err = error as? NSError
                    {
                        if (err.code == NSURLErrorCancelled) { return; }
                        observer.onError(err)
                    }
                })
            }
            return Disposables.create {}
        })
    }
    
    func postRecipeStepObservable (_ url: String, parameters: NSDictionary) -> Observable<(AnyObject)>
    {
        self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
        
        return Observable.create({ (observer) -> Disposable in
            
            var path =  MZEndpoints.RecipeExecute(url)
            
            if self.use_mock
            {
                path = url
                
                self.httpGet(path, parameters: parameters, success: { (sessionManager, responseObject) in
                    
                    if responseObject == nil
                    {
                        observer.onNext(NSDictionary())
                    }
                    else
                    {
                        observer.onNext(responseObject as AnyObject)
                    }
                    observer.onCompleted()
                }, failure: { (sessionManager, error) in
                    if let err = error as? NSError
                    {
                        if (err.code == NSURLErrorCancelled) { return; }
                        observer.onError(err)
                    }
                })

            }
            else
            {
                self.httpPost(path, parameters: parameters, success: { (sessionManager, responseObject) in
                    
                    if responseObject == nil
                    {
                        observer.onNext(NSDictionary())
                    }
                    else
                    {
                        observer.onNext(responseObject as AnyObject)
                    }
                    observer.onCompleted()
                }, failure: { (sessionManager, error) in
                    if let err = error as? NSError
                    {
                        if (err.code == NSURLErrorCancelled) { return; }
                        observer.onError(err)
                    }
                })
            }
            return Disposables.create {}
        })
    }
    
    
    
    func getAuthorizationWithURLObservable (_ url : String) -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            self.setupAuthorization(accessToken: MZSession.sharedInstance.authInfo!.accessToken)
            
            let params = NSDictionary(dictionary: ["policy": "one"])
            
            self.httpGet(url, parameters: params, success: { (sessionDataTask, responseObject) in
                observer.onNext(responseObject as AnyObject)
                observer.onCompleted()
            }, failure: { (sessionManager, error) in
                if let err = error as? NSError
                {
                    let allHeaderFields : NSDictionary = (sessionManager?.currentRequest as! URLRequest).allHTTPHeaderFields as! NSDictionary
                    let locationHeaderString : String? = allHeaderFields.value(forKey: self.key_location) as? String
                    let customHeadersString : String? = allHeaderFields.value(forKey: self.key_custom_headers) as? String
                    
                    var newError : NSError
                    if(locationHeaderString != nil && !locationHeaderString!.isEmpty)
                    {
                        if(customHeadersString != nil && !customHeadersString!.isEmpty)
                        {
                            newError = NSError(domain: "HTTPDomain", code: 303, userInfo: [self.key_location : locationHeaderString, self.key_custom_headers: customHeadersString])
                        }
                        else
                        {
                            newError = NSError(domain: "HTTPDomain", code: 303, userInfo: [self.key_location : locationHeaderString])
                        }
                        
                        observer.onError(newError)
                        return
                    }
                    
                    observer.onError(err)
                }
                
            })
            self.sessionManager.setTaskWillPerformHTTPRedirectionBlock({ (session, task, response, request) -> URLRequest in
                
                if(response == nil)
                {
                    return request
                }
                
                let allHeaderFields : NSDictionary = (response as! HTTPURLResponse).allHeaderFields as NSDictionary
                let locationHeaderString : String? = allHeaderFields.value(forKey: self.key_location) as? String
                
                if(locationHeaderString != nil && !locationHeaderString!.isEmpty)
                {
                    var customHeaders = NSMutableDictionary()
                    let headerPrefix = "X-Webview-"
                    for header in allHeaderFields.allKeys
                    {
                        if((header as! String).contains(headerPrefix))
                        {
                            let subHeader = (header as! String).substring(from: headerPrefix.endIndex)
                            customHeaders.setObject(allHeaderFields[header], forKey: subHeader as NSCopying)
                        }
                    }
                    
                    var newRequest = request
                    
                    newRequest.addValue(locationHeaderString!, forHTTPHeaderField: self.key_location)
                    
                    if(customHeaders != nil && customHeaders.allKeys.count > 0)
                    {
                        newRequest.addValue(MZJsonHelper.JSONStringify(customHeaders), forHTTPHeaderField: self.key_custom_headers)
                    }
                    
                    task.cancel()
                    return newRequest
                }
                
                return request
            })
            return Disposables.create {}
            }
        )
    }
    
}
