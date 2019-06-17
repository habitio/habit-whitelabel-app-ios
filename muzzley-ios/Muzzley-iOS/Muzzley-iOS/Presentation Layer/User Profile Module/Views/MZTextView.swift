//
//  MZTextView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZTextView: UITextView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = CORNER_RADIUS
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 0.3).cgColor
        self.layer.masksToBounds = true
    }

}
 
