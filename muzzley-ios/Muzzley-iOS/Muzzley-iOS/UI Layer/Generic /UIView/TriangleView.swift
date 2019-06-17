//
//  TriangleView.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 11/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TriangleView: UIView {
    
    let facingUp: Bool!
    
    init(frame: CGRect, facingUp: Bool) {
        self.facingUp = facingUp
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        
        self.facingUp = false
        super.init(coder: aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        clipsToBounds = false
        let shape = CAShapeLayer()
        shape.frame = self.layer.bounds
        
        let width = self.layer.frame.size.width
        let height = self.layer.frame.size.height
        
        let path = CGMutablePath()
        
        if (!self.facingUp) {
			path.move(to: CGPoint(x: 0, y: 0))
			path.addLine(to: CGPoint(x: 0, y: 2))
			path.addLine(to: CGPoint(x: width * 0.5, y: 0))
			path.addLine(to: CGPoint(x: width, y: height - 2))
			path.addLine(to: CGPoint(x: width, y: height))

//            CGPathMoveToPoint(path, nil, 0, 0)
//            CGPathAddLineToPoint(path, nil, 0, 2)
//            CGPathAddLineToPoint(path, nil, width * 0.5, height)
//            CGPathAddLineToPoint(path, nil, width, 2)
//            CGPathAddLineToPoint(path, nil, width, 0)
        } else {
			
			path.move(to: CGPoint(x: 0, y: height))
			path.addLine(to: CGPoint(x: 0, y: height - 2))
			path.addLine(to: CGPoint(x: width * 0.5, y: 0))
			path.addLine(to: CGPoint(x: width, y: height - 2))
			path.addLine(to: CGPoint(x: width, y: height))
			
			
//            CGPathMoveToPoint(path, nil, 0, height)
//            CGPathAddLineToPoint(path, nil, 0, height - 2)
//            CGPathAddLineToPoint(path, nil, width * 0.5, 0)
//            CGPathAddLineToPoint(path, nil, width, height - 2)
//            CGPathAddLineToPoint(path, nil, width, height)
        }
        
        
        shape.path = path
        self.layer.mask = shape
        
        let shapeBorder = CAShapeLayer()
        shapeBorder.frame = self.bounds
        
        let borderPath = CGMutablePath()
        if (!self.facingUp) {
			
			path.move(to: CGPoint(x: 0, y: 2))
			path.addLine(to: CGPoint(x: width * 0.5, y: height))
			path.addLine(to: CGPoint(x: width, y: 2))
//			
//            CGPathMoveToPoint(borderPath, nil, 0, 2)
//            CGPathAddLineToPoint(borderPath, nil, width * 0.5, height)
//            CGPathAddLineToPoint(borderPath, nil, width, 2)
        } else {
			path.move(to: CGPoint(x: 0, y: height - 2))
			path.addLine(to: CGPoint(x: width * 0.5, y: 0))
			path.addLine(to: CGPoint(x: width, y: height - 2))
			
//            CGPathMoveToPoint(borderPath, nil, 0, height - 2)
//            CGPathAddLineToPoint(borderPath,nil, width * 0.5, 0)
//            CGPathAddLineToPoint(borderPath, nil, width, height - 2)
        }
        
        shapeBorder.path = borderPath
        shapeBorder.lineWidth = 2
        shapeBorder.contentsScale = UIScreen.main.scale
        shapeBorder.lineCap = "round"
        shapeBorder.strokeColor = UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1).cgColor
        shapeBorder.fillColor = UIColor.clear.cgColor
        
        if (self.layer.sublayers?.count > 0) {
            let firstLayer: CALayer = self.layer.sublayers?.first as CALayer!
            self.layer.replaceSublayer(firstLayer, with: shapeBorder)
        } else {
            self.layer.addSublayer(shapeBorder)
        }
    }
}
