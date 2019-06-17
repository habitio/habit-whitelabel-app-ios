//
//  UIViewExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/02/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//


extension UIView {
    
    func dropShadow(cornerRadius : CGFloat = 3) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        layer.shadowRadius = 0.5
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
   
    
    
//    // OUTPUT 1
//    func dropShadow(scale: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.5
//        layer.shadowOffset = CGSize(width: -1, height: 1)
//        layer.shadowRadius = 1
//
//        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
//
//    // OUTPUT 2
//    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
//        layer.masksToBounds = false
//        layer.shadowColor = color.cgColor
//        layer.shadowOpacity = opacity
//        layer.shadowOffset = offSet
//        layer.shadowRadius = radius
//
//        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//    }
}
