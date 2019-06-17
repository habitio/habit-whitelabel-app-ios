//
//  ToggleButton.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 13/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

@IBDesignable
class MZToggleButton: UIButton, UIGestureRecognizerDelegate {
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var onColor: UIColor?
    @IBInspectable var onTextColor: UIColor?
    @IBInspectable var offColor: UIColor?
    @IBInspectable var offTextColor: UIColor?

    var currentStatus: Bool?
    
    var dateFormatter: DateFormatter = DateFormatter()
    var gestureRecognizer: UITapGestureRecognizer?

    var delegate: ToggleButtonDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit ()
    }

    
    func commonInit() {
        self.dateFormatter = DateFormatter()
        
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MZToggleButton.toggle))
        self.gestureRecognizer!.delegate = self
        self.addGestureRecognizer(self.gestureRecognizer!)
        
        self.dateFormatter.dateFormat = "EEE"
    }

    
    override func layoutSubviews () {
        self.titleLabel?.preferredMaxLayoutWidth = self.bounds.size.width;
    }
    
    func setStatus (_ status: Bool) {
        if (status == true) {
            self.backgroundColor = self.onColor
            self.titleLabel?.textColor = self.onTextColor
        } else {
            self.backgroundColor = self.offColor
            self.titleLabel?.textColor = self.offTextColor
        }
        self.currentStatus = status
        delegate?.toggleButtonTapped(self.tag, currentStatus: status)
    }
    
    func toggle () {
        setStatus(!self.currentStatus!)
    }
}

@objc protocol ToggleButtonDelegate {
    func toggleButtonTapped(_ btnIndex: Int, currentStatus: Bool)
}
