//
//  MZCardsLatencyView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 04/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZCardsLatencyView: UIView {

    let gradientWidth: CGFloat = 162.0
    
    fileprivate var latencyImage: UIImageView!
    fileprivate var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1.0)
        
        self.latencyImage = UIImageView(frame: CGRect(x: 8.0, y: 0.0, width: frame.size.width - 16.0, height: frame.size.height - 8.0))
        self.latencyImage.image = UIImage(named: "latency")
        self.latencyImage.contentMode = .scaleToFill
        self.latencyImage.layer.masksToBounds = true
        self.addSubview(self.latencyImage)
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer.frame = CGRect(x: -self.gradientWidth, y: 0.0, width: self.gradientWidth, height: frame.size.height)
        self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.gradientLayer.colors = [UIColor.muzzleyDarkWhiteColor(withAlpha: 0.0).cgColor, UIColor.muzzleyDarkWhiteColor(withAlpha: 1.0).cgColor, UIColor.muzzleyDarkWhiteColor(withAlpha: 0.0).cgColor]
        
        self.start()
    }
    
    deinit {
        self.stop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func start() {
        let slide: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        slide.fromValue = -self.gradientWidth
        slide.toValue = self.frame.size.width + self.gradientWidth
        slide.duration = 1.0
        slide.repeatCount = HUGE
        self.gradientLayer.add(slide, forKey: "slideAnimation")
        self.latencyImage.layer.addSublayer(self.gradientLayer)
    }
    
    internal func stop() {
        self.gradientLayer?.removeAllAnimations()
        self.gradientLayer?.removeFromSuperlayer()
    }

}
