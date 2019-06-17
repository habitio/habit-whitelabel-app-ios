//
//  MZTextViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 24/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZTextViewModel: NSObject {
    
    var content: String = ""
    var rangeStyles: Array<MZRangeStyleViewModel> = Array()
    var contentStyles: Array<MZContentStyleViewModel> = Array()
    var totalTextViewHeight: CGFloat = 0.0

}