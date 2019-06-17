//
//  MZStageViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 24/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZStageViewModel: NSObject {
    
    var fields: Array<MZFieldViewModel> = Array()
    var actions: Array<MZActionViewModel> = Array()
    var imageUrl: NSURL?
    var iconUrl: NSURL?
    
    var title : String?
    var text: MZTextViewModel = MZTextViewModel()
    
    var unfoldedFieldsIndex: Int = 0
    

    var stageModel : MZStage?
    
    init(model : MZStage)
    {
        self.stageModel = model
        self.imageUrl = model.imageURL
        self.iconUrl = model.iconURL
        self.title = model.title
        
        self.unfoldedFieldsIndex = 0
    }
}
