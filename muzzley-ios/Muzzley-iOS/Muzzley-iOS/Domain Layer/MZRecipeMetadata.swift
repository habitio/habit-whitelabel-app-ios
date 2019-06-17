//
//  MZRecipeMetadata.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//


class MZRecipeMetadata: NSObject
{
    
    var totalSteps : Int?
    var nextStepMeta : MZRecipeStepMeta?
    
    init(dictionary : NSDictionary)
    {
        if dictionary != nil
        {
            if let totSteps = dictionary.value(forKey: MZRecipesKeys.key_totalSteps) as! Int?
            {
                self.totalSteps = totSteps
            }
            
            if let nextStepMetaDict = dictionary.value(forKey: MZRecipesKeys.key_nextStep) as! NSDictionary?
            {
                self.nextStepMeta = MZRecipeStepMeta(dictionary: nextStepMetaDict)
            }
        }
    }
}
