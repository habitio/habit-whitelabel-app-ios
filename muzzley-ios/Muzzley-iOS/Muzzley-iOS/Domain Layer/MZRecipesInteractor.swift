//
//  MZRecipesInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation


class MZRecipesInteractor : NSObject
{

    func requestRecipeMetadata(recipeId: String, completion: @escaping (  _ result: Any?, _ error : NSError?) -> Void)
    {
        let recipeMetadaObservable = MZRecipesDataManager.sharedInstance.getObservableOfRecipeMetada(recipeId)
        
        _ = recipeMetadaObservable.subscribe(
            onNext:{(result) -> Void in
              completion(result, nil)
        }, onError: { error in
            completion(nil, error as? NSError)
        })
    }
    
    
    func executeRecipeStep(url : String, header : NSDictionary?, payload : NSDictionary?, completion: @escaping (  _ result: Any?, _ error : NSError?) -> Void)
    {
        // TODO : Handle headers
    
        let recipeStepObservable = MZRecipesDataManager.sharedInstance.getObservableOfRecipeStep(url, parameters: payload!)
        
        _ = recipeStepObservable.subscribe(
            onNext:{(result) -> Void in
                completion(result, nil)
        }, onError: { error in
            completion(nil, error as? NSError)
        })
    }
    
    
    func getAuthorizationWithURL(url : String, completion: @escaping (  _ result: Any?, _ error : NSError?) -> Void)
    {

        // TODO : Handle headers
        let recipeStepObservable = MZRecipesDataManager.sharedInstance.getObservableOfAuthorizationWithURL(url)
        
        _ = recipeStepObservable.subscribe(
            onNext:{(result) -> Void in
                completion(result, nil)
        }, onError: { error in
            completion(nil, error as? NSError)
        })
    }
}
