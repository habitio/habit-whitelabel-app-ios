//
//  MZContentStylesViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 24/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZRangeStyleViewModel: NSObject {
    
    var bold: Bool = false
    var underline: Bool = false
    var italic: Bool = false
    var color: String = ""
    var fontSizeScale: Float = 1.0
    var range: Array<Int> = Array()

    var startIndex: Int = 0
    var endIndex: Int = 0
    var len: Int = 0
    
    init (ranges: [Int])
    {
        self.range = ranges
        startIndex = ranges[0]
        endIndex = ranges[1]
        
        len = endIndex - startIndex
    }
}