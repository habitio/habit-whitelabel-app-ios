//
//  MZRecipeStepInfo.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZRecipeStep : NSObject
{
    
    var nextStep : MZRecipeStepMeta?
    var action : String?
    var actionVersion : String?
    var payload : Any?
    
    init(dictionary : NSDictionary)
    {
        if let nextStepDict = dictionary.value(forKey: MZRecipesKeys.key_nextStep)
        {
            self.nextStep = MZRecipeStepMeta(dictionary: nextStepDict as! NSDictionary)
        }
        
        if let responseDict = dictionary.value(forKey: MZRecipesKeys.key_response) as? NSDictionary
        {
            if let payload = responseDict.value(forKey: MZRecipesKeys.key_payload) as? NSDictionary
            {
                self.payload = payload
                
                if let action = payload.value(forKey: MZRecipesKeys.key_action) as? String
                {
                    self.action = action
                }
                
                if let actionVer = payload.value(forKey: MZRecipesKeys.key_action_version) as? String
                {
                    self.actionVersion = actionVer
                }
                else
                {
                    self.actionVersion = ""
                }

            }
        }
    }
}
