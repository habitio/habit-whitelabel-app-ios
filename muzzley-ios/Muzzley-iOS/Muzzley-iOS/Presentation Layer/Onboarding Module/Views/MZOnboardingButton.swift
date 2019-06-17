//
//  MZOnboardingButton.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 16/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZOnboardingButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
            } else {
                self.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 0.85)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 0.85)
        self.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 1.0), for: UIControlState())
        self.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 1.0), for: .highlighted)
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.masksToBounds = true
    }

}
