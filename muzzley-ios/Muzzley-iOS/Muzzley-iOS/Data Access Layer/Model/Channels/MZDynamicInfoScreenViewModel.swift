//
//  MZDynamicScreenInfoViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 09/01/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation

class MZDynamicInfoScreenViewModel : NSObject
{
    var topImageUrl: String?
    var bottomImageUrl: String?
    var navigationBarTitle : String?
    var title : String?
    var text : String?
    var buttonText : String?
    var infoUrl : String?

    var isBackButtonEnabled = false
    
    init(navigationBarTitle: String?, topImageUrl : String?, bottomImageUrl: String?, title: String?, text: String?, buttonText: String?, infoUrl: String?, isBackButtonEnabled : Bool)
    {
        self.topImageUrl = topImageUrl
        self.bottomImageUrl = bottomImageUrl
        self.navigationBarTitle = navigationBarTitle
        self.title = title
        self.text = text
        self.buttonText = buttonText
        self.infoUrl = infoUrl
        self.isBackButtonEnabled = isBackButtonEnabled
    }
}
