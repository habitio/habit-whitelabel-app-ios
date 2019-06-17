//
//  File.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import RxSwift



class MZRecipesDataManager
{
    class var sharedInstance : MZRecipesDataManager {
        struct Singleton {
            static let instance = MZRecipesDataManager()
        }
        return Singleton.instance
    }

    func getObservableOfRecipeMetada (_ recipeId : String) -> Observable<(MZRecipeMetadata)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            let observable = MZRecipesWebservice.sharedInstance.postRecipeMetadaObservable(recipeId)
            observable.subscribe(
                onNext: { (result) -> Void in
                    // Check if is valid
                    let metadata = MZRecipeMetadata(dictionary: result as! NSDictionary)
                    observer.onNext(metadata)
                    observer.onCompleted()
            },
                onError: { (error) -> Void in
                    observer.onError(NSError(domain: "MZRecipesDataManagerErrorDomain", code: 0, userInfo: nil))
            })
            return Disposables.create()
        })
    }
    
    
    func getObservableOfRecipeStep (_ url : String, parameters : NSDictionary) -> Observable<(MZRecipeStep)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            let observable = MZRecipesWebservice.sharedInstance.postRecipeStepObservable(url, parameters: parameters)
            observable.subscribe(
                onNext: { (result) -> Void in
                    // Check if is valid
                    print(result)
                    let step = MZRecipeStep(dictionary: result as! NSDictionary)
                    observer.onNext(step)
                    observer.onCompleted()
            },
                onError: { (error) -> Void in
                    observer.onError(NSError(domain: "MZRecipesDataManagerErrorDomain", code: 0, userInfo: nil))
            })
            return Disposables.create()
        })
    }
    
    
    func getObservableOfAuthorizationWithURL (_ url : String) -> Observable<(Any)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            let observable = MZRecipesWebservice.sharedInstance.getAuthorizationWithURLObservable(url)
            observable.subscribe(
                onNext: { (result) -> Void in
                    observer.onNext(result)
                    observer.onCompleted()
            },
                onError: { (error) -> Void in
                    observer.onError(error)
            })
            return Disposables.create()
        })
    }
}
