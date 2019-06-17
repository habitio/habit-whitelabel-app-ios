//
//  MZStage.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZStage : NSObject
{
    static let key_title            = "title"
    static let key_actions          = "actions"
    static let key_fields           = "fields"
    static let key_graphics         = "graphics"
    static let key_image            = "image"
    static let key_icon             = "icon"
    static let key_text             = "text"
    static let key_content          = "content"
    static let key_rangeStyles      = "rangeStyles"
    static let key_contentStyles    = "contentStyles"

    
    var title : String                      = ""
    var actions : [MZStageAction]           = [MZStageAction]()
    var fields : [MZStageField]             = [MZStageField]()
    var imageURL : NSURL?                   = nil
    var iconURL : NSURL?                    = nil
    var content : String                    = ""
    var rangeStyles : [MZRangeStyle]        = [MZRangeStyle]()
    var contentStyles : [MZContentStyle]    = [MZContentStyle]()

    
    var dictionaryRepresentation: NSDictionary = NSDictionary()

    convenience init(dictionary : NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let actions = dictionary[MZStage.key_actions] as? [NSDictionary]
            {
                for dic in actions
                {
                    if let action : MZStageAction = MZStageAction(dictionary: dic)
                    {
                        self.actions.append(action)
                    }
                }
            }
            if let fields = dictionary[MZStage.key_fields] as? [NSDictionary]
            {
                for dic in fields
                {
                    if let field : MZStageField = MZStageField(dictionary: dic)
                    {
                        self.fields.append(field)
                    }
                }
            }
            if let graphics = dictionary[MZStage.key_graphics] as? NSDictionary
            {
                if let image = graphics[MZStage.key_image] as? String
                {
                    var connector = "?"
                    if image.contains(connector)
                    {
                        connector = "&"
                    }
                    let newURL = "\(image)\(connector)os=ios&size=xxhdpi"
                    self.imageURL = NSURL(string: newURL)
                }
                if let icon = graphics[MZStage.key_icon] as? String
                {
                    self.iconURL = NSURL(string: icon)
                }
            }
            if let text = dictionary[MZStage.key_text] as? NSDictionary
            {
                if let content = text[MZStage.key_content] as? String
                {
                    self.content = content
                }
                if let title = text[MZStage.key_title] as? String {
                    self.title = title
                }
                if let rangeStyles = text[MZStage.key_rangeStyles] as? [NSDictionary]
                {
                    for dic in rangeStyles
                    {
                        if let rangeStype : MZRangeStyle = MZRangeStyle(dictionary: dic)
                        {
                            self.rangeStyles.append(rangeStype)
                        }
                    }
                }
                if let contentStyles = text[MZStage.key_contentStyles] as? [NSDictionary]
                {
                    for dic in contentStyles
                    {
                        if let contentStyle : MZContentStyle = MZContentStyle(dictionary: dic)
                        {
                            self.contentStyles.append(contentStyle)
                        }
                    }
                }
            }
        }
    }
}
