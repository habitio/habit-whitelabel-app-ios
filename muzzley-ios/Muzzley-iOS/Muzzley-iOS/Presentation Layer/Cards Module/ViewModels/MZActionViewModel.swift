//
//  MZInteractionViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 24/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

@objc enum ActionRole: Int {
    case primary = 0, secondary, aside
}

@objc enum ActionIcon: Int {
    case none = 0, info
}

class MZPubMQTTViewModel: NSObject {
    var topic: String           = ""
    var payload: NSDictionary   = NSDictionary()
    
    init(model:MZPubMQTT)
    {
        self.topic = model.topic
        self.payload = model.payload
    }
}

class MZActionViewModel: NSObject {
    
    static let key_gotoStage      = "gotoStage"
    static let key_reply          = "reply"
    static let key_browse         = "browse"
    static let key_done           = "done"
    static let key_dismiss        = "dismiss"
    static let key_navigate       = "navigate"
    static let key_createWorker   = "createWorker"
    static let key_showInfo       = "showInfo"
    

	
    var id : String             = ""
    var label: String           = ""
    var type: String            = ""
    var role: ActionRole        = .primary
    var icon: ActionIcon        = .none
    var notifyOnClick : Bool    = false
    var refreshAfter : Bool     = false
    var args: MZArgsViewModel   = MZArgsViewModel()
    var pubMQTT: MZPubMQTTViewModel?

    var actionModel : MZStageAction
    
    init(model : MZStageAction)
    {
        self.actionModel = model
        self.id = model.id
        self.label = model.label
        self.type = model.type
        self.notifyOnClick = model.notifyOnClick
        self.refreshAfter = model.refreshAfter
        
        switch model.role
        {
        case MZStageAction.key_primary:
            role = .primary
            break
        case MZStageAction.key_secondary:
            role = .secondary
            break
        case MZStageAction.key_aside:
            role = .aside
            break
        default:
            break
        }
        
        switch model.icon
        {
        case MZStageAction.key_info:
            icon = .info
            break
        default:
            break
        }
        
        if model.pubMQTT != nil
        {
            self.pubMQTT = MZPubMQTTViewModel(model: model.pubMQTT!)
        }
    }
    
}
