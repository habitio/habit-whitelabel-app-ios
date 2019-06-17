//
//  MZCardSuccessFeedback.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZCardSuccessFeedback: UIView {

    @IBOutlet weak var successLbl: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.successLbl.text = NSLocalizedString("mobile_thank_you", comment: "").uppercased()
        self.successLbl.textColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        self.successLbl.font = UIFont.mediumFontOfSize(12)
        self.backgroundColor = UIColor.muzzleyGreenColor(withAlpha: 1.0)
    }


}
