//
//  MZCardErrorFeedback.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZCardErrorFeedback: UIView {

    @IBOutlet weak var errorLbl: UILabel!

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.errorLbl.text = NSLocalizedString("mobile_error_title", comment: "").uppercased()
        self.errorLbl.textColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        self.errorLbl.font = UIFont.mediumFontOfSize(12)
        self.backgroundColor = UIColor.muzzleyRed2Color(withAlpha: 1.0)
    }

}
