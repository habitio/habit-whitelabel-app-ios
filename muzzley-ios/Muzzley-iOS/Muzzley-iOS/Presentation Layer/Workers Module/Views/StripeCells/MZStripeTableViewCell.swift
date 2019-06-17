//
//  MZStripeTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 17/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZStripeTableViewCell: UITableViewCell {

    internal var isHalfHeight: Bool = false {
        didSet {
            self.drawStripe()
        }
    }
    
    internal var isBottomHalfHeight: Bool = false {
        didSet {
            self.drawStripe()
        }
    }
    
    internal var hasStripe: Bool = true {
        didSet {
            self.drawStripe()
        }
    }

    fileprivate var stripeLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        
        self.drawStripe()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.isHalfHeight = false
        self.isBottomHalfHeight = false
        self.hasStripe = true
    }
    
    internal func drawStripe() {
        self.stripeLayer?.removeFromSuperlayer()
        if self.hasStripe {
            self.stripeLayer = CAShapeLayer()
            self.stripeLayer!.path = UIBezierPath(rect: CGRect(x: 50.0, y: self.isBottomHalfHeight ? 40.0 : 0.0, width: 10.0, height: self.isBottomHalfHeight ? self.bounds.size.height - 40.0 : self.bounds.size.height / (self.isHalfHeight ? 2.0 : 1.0))).cgPath
            self.stripeLayer!.fillColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
            self.layer.insertSublayer(self.stripeLayer!, at: 0)
        }
    }

}
