//
//  SpinnerView.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 28/1/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

import Foundation
import UIKit

class SpinnerView: UIView {
    
    fileprivate var spinnerIcon : UILabel = UILabel()
    var isSpinning : Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.baseInit()
    }
    
    func baseInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(SpinnerView.refreshSpinnerAnimation), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        spinnerIcon.frame = self.bounds
        spinnerIcon.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        spinnerIcon.font = UIFont(name: "ios_ui_icons", size: 20)
        spinnerIcon.textColor = UIColor.black
        spinnerIcon.textAlignment = NSTextAlignment.center
        spinnerIcon.text = "\u{E800}"
        //spinnerIcon.setTranslatesAutoresizingMaskIntoConstraints(false)
        //NSDictionary *views = NSDictionaryOfVariableBindings(_spinnerView);
        //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_spinnerView]|" options:0 metrics:nil views:views]];
        //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_spinnerView]-2-|" options:0 metrics:nil views:views]];
        self.addSubview(spinnerIcon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        spinnerIcon.bounds = self.bounds
        spinnerIcon.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
    }
    
    func startAnimation() {
        self.stopAnimation()
        
        self.isSpinning = true
        
        let fullTurn : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation");
        fullTurn.fromValue = 0.0
        fullTurn.toValue =  2.0 * M_PI
        fullTurn.duration = 1.3;
        fullTurn.repeatCount = Float.infinity;
        
        self.spinnerIcon.layer.add(fullTurn, forKey: "spinAnimation")
    }
    
    func stopAnimation() {
        self.isSpinning = false
        self.spinnerIcon.layer.removeAllAnimations()
    }
    
    func rotateTo(_ angleDegree : CGFloat) {
        if self.isSpinning {
            self.stopAnimation()
        }
        self.spinnerIcon.transform = CGAffineTransform(rotationAngle: angleDegree);
        self.spinnerIcon.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
    }
    
    func refreshSpinnerAnimation() {
        if self.isSpinning {
            self.startAnimation()
        }
    }
}
