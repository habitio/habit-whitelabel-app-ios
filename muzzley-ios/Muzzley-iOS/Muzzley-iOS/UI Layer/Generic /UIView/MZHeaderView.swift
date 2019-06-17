//
//  MZHeaderView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 06/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZHeaderView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.superview?.bringSubview(toFront: self)
        self.layer.shadowColor = UIColor.muzzleyGrayColor(withAlpha: 0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 3.0
                
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
}
