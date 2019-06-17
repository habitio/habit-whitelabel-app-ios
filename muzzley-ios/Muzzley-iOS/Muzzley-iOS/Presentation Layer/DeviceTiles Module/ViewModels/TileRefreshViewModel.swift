//
//  TileRefreshViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation

let TileRefreshViewModelKeyAnimating = "TileRefreshViewModelKeyAnimating"

class TileRefreshViewModel : NSObject {
    var animating: Bool = true
    
    override init() {}
    
    init(dictionary: Dictionary<String,Any>) {
        if let validAnimating: Bool = dictionary[TileRefreshViewModelKeyAnimating] as? Bool {
            self.animating = validAnimating
        }
    }
}