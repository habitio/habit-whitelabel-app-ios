//
//  MZRecipeVariable.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 22/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZRecipeVariable
{
    var name: String?
    var type : String?
    var required : Bool?
}



class MZRecipeVariables
{
    var dictionary : NSDictionary?
    
    
    func processVariables(dictionary : NSDictionary)
    {
     
        var dictionary2 = NSDictionary(dictionary: ["variables" : ["payload.process.id": "string|required", "payload.process.name": "string|required", "payload.channel_template_id": "string|required", "payload.client_id": "string|required", "header.content-type" : "application/json", "otherKey" : "otherValue"]])
        
        var variablesDict = dictionary2["variables"] as! NSDictionary
        
        var variables = NSMutableDictionary ()
        
        for element in variablesDict
        {
            var variable = NSMutableDictionary()
            var split = (element.key as! String).components(separatedBy: ".")
            split.reverse()
            
            for i in 0...split.count-1
            {
                if variable.object(forKey: split[i]) == nil && i == 0
                {
                    variable.addEntries(from: [split[i] : element.value])
                }
                else
                {
                    variable = NSMutableDictionary(dictionary: [split[i] : variable])
                }
            }
            
            if variables.object(forKey: variable.allKeys[0]) == nil
            {
                variables.addEntries(from: variable as! [AnyHashable : Any])
            }
            else
            {
                (variables[variable.allKeys[0]] as! NSMutableDictionary).addEntries(from: variable.allValues[0] as! [AnyHashable : Any])
            }
        }
    }
    
    func createVariablesDictionary()
    {
    
    }
    
    
}
