//
//  MZFeedbackButton.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

@IBDesignable
class MZFeedbackButton: UIButton {

    @IBInspectable var select: Bool = false {
        didSet {
            self.setNeedsDisplay()
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
        self.setTitleColor(UIColor.muzzleyGray2Color(withAlpha: 1), for: UIControlState())
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect) 
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: CORNER_RADIUS)
        if self.select {
            UIColor.muzzleyWhiteColor(withAlpha: 0.65).setFill()
            path.fill()
        } else {
            UIColor.muzzleyWhiteColor(withAlpha: 1).setFill()
            path.fill()
            path.lineWidth = 1.0 / UIScreen.main.scale
            UIColor.muzzleyGrayColor(withAlpha: 0.5).setStroke()
            path.stroke()
        }
        
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor = UIColor.muzzleyBlackColor(withAlpha: 1).cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowPath = path.cgPath
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true
    }

}
