//
//  MZEditButton.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZEditButton: UIButton {

    internal var editIcon: UIImage = UIImage(named: "IconEdit")!
    internal var onEditingLabel: String = NSLocalizedString("mobile_done", comment: "")
    internal var normalColor: UIColor = UIColor.muzzleyWhiteColor(withAlpha: 0.8)
    internal var onEditColor: UIColor = UIColor.muzzleyBlueColor(withAlpha: 1)
    internal var isEditing: Bool = false {
        didSet {
            if self.isEditing {
                self.backgroundColor = self.onEditColor
            } else {
                self.backgroundColor = self.normalColor
            }
            self.setNeedsDisplay()
            self.setNeedsLayout()
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
        self.setTitleColor(UIColor.muzzleyWhiteColor(withAlpha: 1), for: UIControlState())
        self.setTitleShadowColor(UIColor.muzzleyWhiteColor(withAlpha: 1), for: UIControlState())
        self.adjustsImageWhenHighlighted = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = rect.size.height / 2.0
        self.layer.borderColor = UIColor.muzzleyWhiteColor(withAlpha: 0.8).cgColor
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.layer.masksToBounds = true
        
        if self.isEditing {
            self.setImage(UIImage(), for: UIControlState())
            self.setTitle(" " + self.onEditingLabel + " ", for: UIControlState())
        } else {
            self.tintColor = UIColor.muzzleyGrayColor(withAlpha: 0.6)
            self.setTitle("", for: UIControlState())
            self.setImage(self.editIcon, for: UIControlState())
        }
    }
    
}
