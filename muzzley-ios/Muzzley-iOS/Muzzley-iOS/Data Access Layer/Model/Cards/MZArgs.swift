//
//  MZArgs.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZArgs: NSObject
{
    static let key_nStage       = "nStage"
    static let key_actionValue  = "actionValue"
    static let key_url          = "url"
    static let key_infoText     = "infoText"
    static let key_hashBang     = "hashBang"
    static let key_workerSpec   = "workerSpec"
//	static let key_topic		= "topic"
//	static let key_payload		= "payload"

	
    var nStage: Int      = 0
    var url: String         = ""
    var infoText: String    = ""


    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            if let nStage = dictionary[MZArgs.key_nStage] as? Int {
                self.nStage = nStage
            }
            if let url = dictionary[MZArgs.key_url] as? String {
                self.url = url
            }
        }
    }
}
