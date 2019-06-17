//
//  MZButton.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

@IBDesignable
class MZButton: UIButton {
    
    @IBInspectable internal var invertedButton: Bool = false {
        didSet {
            self.commonInit()
            self.setNeedsDisplay()
        }
    }
    @IBInspectable internal var normalBorderColor: UIColor = UIColor.muzzleyBlueColorWithAlpha(1) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var enabled: Bool {
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
    
    private func commonInit() {
        if self.invertedButton {
            self.setTitleColor(UIColor.muzzleyWhiteColorWithAlpha(1), forState: .normal)
            self.setTitleColor(UIColor.muzzleyWhiteColorWithAlpha(1), forState: .Disabled)
        } else {
            self.setTitleColor(UIColor.muzzleyBlueColorWithAlpha(1), forState: .normal)
            self.setTitleColor(UIColor.muzzleyBlueColorWithAlpha(0.6), forState: .Disabled)
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.height / 2.0)
        if self.invertedButton {
            UIColor.muzzleyBlueColorWithAlpha(self.isEnabled ? 1 : 0.6).setFill()
            path.fill()
        } else {
            UIColor.clearColor().setFill()
            path.fill()
            path.lineWidth = 1.0 / UIScreen.main().scale
            self.normalBorderColor.setStroke()
            path.stroke()
        }
    }

}
