//
//  MZCard.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

class MZCard: NSObject
{
    static let key_id               = "id"
    static let key_title            = "title"
    static let key_feedback         = "feedback"
    static let key_interaction      = "interaction"
    static let key_stages           = "stages"
    static let key_colors           = "colors"
    static let key_mainColor        = "main"
    static let key_actionBarColor   = "actionBar"
    static let key_background       = "background"
    static let key_text             = "text"
    static let key_type             = "type"
    static let key_class            = "class"
    static let key_updated          = "updated"

    
    var identifier : String                 = ""
    var title : String                      = ""
    var feedback : [String]                 = [String]()
    var stages : [MZStage]                  = [MZStage]()
    var colorMainBackground : UIColor       = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
    var colorMainTitle : UIColor            = UIColor.muzzleyBlackColor(withAlpha: 1.0)
    var colorMainText : UIColor             = UIColor.muzzleyBlackColor(withAlpha: 1.0)
    var colorActionBarBackground : UIColor  = UIColor.muzzleyBlueishWhite2Color(withAlpha: 1.0)
    var colorActionBarText : UIColor        = UIColor.muzzleyBlueColor(withAlpha: 1.0)
    var type : String                       = ""
    var className : String                  = ""
    var updatedTS : String                  = ""

    var dictionaryRepresentation: NSDictionary = NSDictionary()

    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let identifier = dictionary[MZCard.key_id] as? String {
                self.identifier = identifier
            }
            
            if let type = dictionary[MZCard.key_type] as? String {
                self.type = type
            }
            
            if let className = dictionary[MZCard.key_class] as? String {
                self.className = className
            }
            
            if let title = dictionary[MZCard.key_title] as? String {
                self.title = title
            }
            
            if let feedback = dictionary[MZCard.key_feedback] as? [String] {
                self.feedback = feedback
            }
            
            if let colors = dictionary[MZCard.key_colors] as? NSDictionary {
                if let main = colors[MZCard.key_mainColor] as? NSDictionary {
                    if let colorMainBackground = main[MZCard.key_background] as? String {
                        self.colorMainBackground = UIColor(hex:colorMainBackground)
                    }
                    if let colorMainTitle = main[MZCard.key_title] as? String {
                        self.colorMainTitle = UIColor(hex:colorMainTitle)
                    }
                    if let colorMainText = main[MZCard.key_text] as? String {
                        self.colorMainText = UIColor(hex:colorMainText)
                    }
                }
                if let action = colors[MZCard.key_actionBarColor] as? NSDictionary {
                    if let colorActionBarBackground = action[MZCard.key_background] as? String {
                        self.colorActionBarBackground = UIColor(hex:colorActionBarBackground)
                    }
                    if let colorActionBarText = action[MZCard.key_text] as? String {
                        self.colorActionBarText = UIColor(hex:colorActionBarText)
                    }
                }
            }
        
            if let interaction = dictionary[MZCard.key_interaction] as? NSDictionary {
                if let stages = interaction[MZCard.key_stages] as? NSArray {
                    for element in stages {
                        if let stageDict = element as? NSDictionary {
                            if let stage : MZStage = MZStage(dictionary: stageDict) {
                                self.stages.append(stage)
                            }
                        }
                    }
                }
            }
            
            if let updatedTS = dictionary[MZCard.key_updated] as? String {
                self.updatedTS = updatedTS
            }
        }
    }
}
