//
//  TileProblemViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation

let TileProblemViewModelKeyIconName = "TileProblemViewModelKeyIconName"
let TileProblemViewModelKeyMessage = "TileProblemViewModelKeyMessage"
let TileProblemViewModelKeyRetryTitle = "TileProblemViewModelKeyRetryTitle"
let TileProblemViewModelKeyCancelTitle = "TileProblemViewModelKeyCancelTitle"

class TileProblemViewModel : NSObject {
    
    var iconName: String = "IconAlert"
    var message: String = NSLocalizedString("mobile_device_update_error", comment: "")
    var retryTitle: String = NSLocalizedString("mobile_retry", comment: "")
    var cancelTitle : String = NSLocalizedString("mobile_cancel", comment: "")
    
    override init() {}
    
    init(dictionary: Dictionary<String,Any>) {
      
        if let validName: String = dictionary[TileProblemViewModelKeyIconName] as? String {
            self.iconName = validName
        }
        if let validMessage: String = dictionary[TileProblemViewModelKeyMessage] as? String {
            self.message = validMessage
        }
        if let validRetryTitle: String = dictionary[TileProblemViewModelKeyRetryTitle] as? String {
            self.retryTitle = validRetryTitle
        }
        if let validCancelTitle: String = dictionary[TileProblemViewModelKeyCancelTitle] as? String {
            self.cancelTitle = validCancelTitle
        }
    }
}
