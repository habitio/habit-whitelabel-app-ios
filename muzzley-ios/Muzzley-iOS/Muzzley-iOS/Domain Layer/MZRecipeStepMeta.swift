//
//  MZRecipeStepMeta.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZRecipeStepMeta
{
    var id : String?
    var nextStepUrl : String?
    var variables : NSDictionary?
    
    init(dictionary: NSDictionary)
    {
        if let id = dictionary.value(forKey: MZRecipesKeys.key_nextStepId) as? String
        {
            self.id = id
        }
        
        if let url = dictionary.value(forKey: MZRecipesKeys.key_nextStepUrl) as? String
        {
            self.nextStepUrl = url
        }
        
        if let metaDict = dictionary.value(forKey: MZRecipesKeys.key_meta) as? NSDictionary
        {
            if let variables = metaDict.value(forKey: MZRecipesKeys.key_variables) as? NSDictionary
            {
                self.variables = variables
            }
        }
    }
}
