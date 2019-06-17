//
//  MZRadioItemView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 26/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZRadioItemView: UIView {

    @IBOutlet weak var textLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    internal var textAlignment: NSTextAlignment = .center
    internal var text: String = ""
    internal var subtitle: String = ""
    internal var borderColor: UIColor = UIColor.muzzleyGrayColor(withAlpha: 1)
    internal var buttonColor: UIColor = UIColor.muzzleyBlueColor(withAlpha: 1)
    internal var isSelected: Bool! {
        didSet {
            self.setNeedsDisplay()
            self.setNeedsLayout()
        }
    }
    
    fileprivate var button: UIBezierPath?
    fileprivate var radio: UIBezierPath?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: configure label text attributes
        self.textLabel?.text = self.text
        self.subtitleLabel?.text = self.subtitle
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.button = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width - 8.0 - (self.frame.size.height - 2.0) / 2.0, y: 1.0 / UIScreen.main.scale + self.frame.size.height / 2.0), radius: 9, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
        self.button?.lineWidth = 1.0 / UIScreen.main.scale
        self.borderColor.setStroke()
        self.button?.stroke() 
        UIColor.clear.setFill()
        self.button?.fill()
        
        if self.radio == nil {
            self.radio = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width - 8.0 - (self.frame.size.height - 2.0) / 2.0, y: 1.0 / UIScreen.main.scale + self.frame.size.height / 2.0), radius: 7, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
        }
        
        if self.isSelected! {
            self.buttonColor.setFill()
        } else {
            UIColor.clear.setFill()
        }
        self.radio?.fill()
    }

}
