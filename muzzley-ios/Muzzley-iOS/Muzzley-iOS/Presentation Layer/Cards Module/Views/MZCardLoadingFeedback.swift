//
//  MZCardLoadingFeedback.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZCardLoadingFeedback: UIView
{

    @IBOutlet weak var loadingLbl: UILabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!

    
    var colorTextAndIndicator: UIColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.loadingLbl.text = NSLocalizedString("mobile_cards_loading", comment: "").uppercased()
        self.loadingLbl.textColor = self.colorTextAndIndicator
        self.loadingLbl.font = UIFont.mediumFontOfSize(12)
        self.backgroundColor = UIColor.clear
        self.activityInd.color = self.colorTextAndIndicator
    }
}
