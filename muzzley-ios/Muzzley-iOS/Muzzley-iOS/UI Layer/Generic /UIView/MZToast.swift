//
//  MZToast.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 05/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
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


@objc enum MZToastState: Int {
    case none, info, error, warning, success
}

class MZToast: UIView {

    fileprivate let margin: CGFloat = 8.0
    fileprivate let bottomMargin : CGFloat = 5.0
    fileprivate let innerMargin: CGFloat = 12.0
    internal var height: CGFloat = 80.0
    fileprivate let imageSize: CGFloat = 24.0
    
    fileprivate var containerView: UIView!
    fileprivate var imageView: UIImageView!
    fileprivate var messageLabel: UILabel!
    fileprivate var scrollView: UIScrollView?
    fileprivate var timer: Timer?
    
    internal var state: MZToastState = .none
    internal var message: String?
    internal var image: UIImage?
    internal var toastColor: UIColor?
    
    internal var textColor: UIColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0) {
        didSet {
            self.messageLabel.textColor = self.textColor
        }
    }
    
    internal var messageFont: UIFont = UIFont.semiboldItalicFontOfSize(16) {
        didSet {
            self.messageLabel.font = self.messageFont
        }
    }
    
    internal var messageAlign: NSTextAlignment = .left {
        didSet {
            self.messageLabel.textAlignment = self.messageAlign
        }
    }
    
    internal var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.containerView.layer.cornerRadius = self.cornerRadius
        }
    }
    
    internal var hasImage: Bool = true {
        didSet {
            self.setNeedsDisplay()
            self.setNeedsLayout()
        }
    }
    
    internal var hasTimer: Bool = true {
        didSet {
            if !self.hasTimer && self.tintColor != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    internal var timerInterval: TimeInterval = 5.0 {
        didSet {
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
            self.configureTimer()
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
    
    convenience init(withState state: MZToastState) {
        self.init(frame: CGRect.zero)
        
        self.state = state
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.containerView.removeFromSuperview()
        self.containerView.frame = CGRect(x: self.margin, y: self.margin, width: rect.size.width - 2 * self.margin, height: self.height - self.bottomMargin) 
        self.addSubview(self.containerView)
        
        self.imageView.removeFromSuperview()
        self.messageLabel.removeFromSuperview()
        if self.hasImage {
            self.imageView.frame = CGRect(x: self.innerMargin, y: self.height / 2.0 - self.imageSize / 2.0, width: self.imageSize, height: self.imageSize)
            self.containerView.addSubview(self.imageView)
            
            self.messageLabel.frame = CGRect(x: self.imageView.frame.origin.x + self.imageSize + self.innerMargin, y: self.margin, width: self.containerView.frame.size.width - self.imageView.frame.origin.x - self.imageSize - 2 * self.innerMargin, height: self.height - 2 * self.margin)
            self.containerView.addSubview(self.messageLabel)
        } else {
            self.messageLabel.frame = CGRect(x: self.innerMargin, y: self.margin, width: self.containerView.frame.size.width - 2 * self.innerMargin, height: self.height - 2 * self.margin)
            self.containerView.addSubview(self.messageLabel)
        }
        
        self.updateState()
    }
    
    internal func showAboveScrollView(_ scrollView: UIScrollView, withAnimation animation: Bool = true) {
        self.updateState()
        
        self.scrollView = scrollView
        var newFrame: CGRect = self.frame
        newFrame.size.width = UIScreen.main.bounds.size.width
        newFrame.origin.y = (self.scrollView?.frame.origin.y)!
        self.frame = newFrame
        self.backgroundColor = self.scrollView?.backgroundColor
        self.scrollView?.superview?.addSubview(self)
        
        if animation {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                var sFrame: CGRect = (self.scrollView?.frame)!
//                sFrame.origin.y += self.height + self.margin
//                sFrame.size.height -= self.height + self.margin
//                self.scrollView?.frame = sFrame
//                self.scrollView?.contentSize = CGSizeMake((self.scrollView?.contentSize.width)!, (self.scrollView?.contentSize.width)! - self.height)
//                self.scrollView?.translatesAutoresizingMaskIntoConstraints = true
                
                var mFrame: CGRect = self.frame
                mFrame.size.height = self.height + self.margin
                self.frame = mFrame
                }, completion: { (success) -> Void in
                    if self.timer != nil {
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                    self.configureTimer()
            }) 
        } else {
//            var sFrame: CGRect = (self.scrollView?.frame)!
//            sFrame.origin.y += self.height + self.margin
//            sFrame.size.height -= self.height + self.margin
//            self.scrollView?.frame = sFrame
//            self.scrollView?.contentSize = CGSizeMake((self.scrollView?.contentSize.width)!, (self.scrollView?.contentSize.width)! - self.height)
            self.scrollView?.translatesAutoresizingMaskIntoConstraints = true
            
            var mFrame: CGRect = self.frame
            mFrame.size.width = UIScreen.main.bounds.size.width
            mFrame.size.height = self.height + self.margin
            self.frame = mFrame
            
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
            self.configureTimer()
        }
    }
    
    internal func hideWithAnimation(_ animation: Bool = true) {
        if self.scrollView != nil {
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
            
            if animation {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.updateAnotherToasts()
                    
                    var newFrame = self.frame
                    newFrame.size.height = 0
                    self.frame = newFrame
                    
//                    var sFrame: CGRect = (self.scrollView?.frame)!
//                    sFrame.origin.y -= self.height + self.margin
//                    sFrame.size.height += self.height + self.margin
//                    self.scrollView?.frame = sFrame
                    }, completion: { (success) -> Void in
                        self.removeFromSuperview()
                        self.scrollView = nil
                })
            } else {
                self.updateAnotherToasts()
                self.frame = CGRect.zero
//                
//                var sFrame: CGRect = (self.scrollView?.frame)!
//                sFrame.origin.y -= self.height + self.margin
//                sFrame.size.height += self.height + self.margin
//                self.scrollView?.frame = sFrame
                
                self.removeFromSuperview()
                self.scrollView = nil
            }
        }
    }
    
    
    // MARK: - Private Stuff
    
    fileprivate func commonInit() {
        self.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        self.layer.masksToBounds = true
        self.gestureRecognizers?.forEach{ self.removeGestureRecognizer($0) }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZToast.dismiss(_:))))
        
        if self.containerView == nil {
            self.containerView = UIView()
            self.containerView.layer.cornerRadius = self.cornerRadius
            self.containerView.layer.masksToBounds = true
        } else {
            self.containerView.removeFromSuperview()
        }
        
        if self.imageView == nil {
            self.imageView = UIImageView()
            self.imageView.backgroundColor = UIColor.clear
            self.imageView.tintColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        } else {
            self.imageView.removeFromSuperview()
            self.imageView.image = nil
        }
        
        if self.messageLabel == nil {
            self.messageLabel = UILabel()
            self.messageLabel.isUserInteractionEnabled = true
            self.messageLabel.numberOfLines = 0
            self.messageLabel.lineBreakMode = .byWordWrapping
            self.messageLabel.textColor = self.textColor
            self.messageLabel.font = self.messageFont
        } else {
            self.messageLabel.removeFromSuperview()
            self.messageLabel.text = ""
        }
    }
    
    fileprivate func updateState() {
        switch self.state {
        case .info:
            self.containerView.backgroundColor = UIColor.muzzleyBlueColor(withAlpha: 0.9)
            self.imageView.image = UIImage(named: "")
            self.messageLabel.text = "info default"
        case .error:
            self.containerView.backgroundColor = UIColor.muzzleyRedColor(withAlpha: 0.6)
            self.imageView.image = UIImage(named: "icon_alert_red")
            self.messageLabel.text = "error default"
        case .warning:
            self.containerView.backgroundColor = UIColor.yellow.withAlphaComponent(0.8)
            self.imageView.image = UIImage(named: "IconAlert")
            self.messageLabel.text = "warning default"
        case .success:
            self.containerView.backgroundColor = UIColor.green.withAlphaComponent(0.8)
            self.imageView.image = UIImage(named: "success")
            self.messageLabel.text = "success default"
            
        default:
            self.containerView.backgroundColor = UIColor.clear
            self.imageView.image = nil
            self.messageLabel.text = ""
            self.hasImage = false
        }
        
        if self.toastColor != nil {
            self.containerView.backgroundColor = self.toastColor
        }
        
        if self.image != nil {
            self.imageView.image = self.image
        }
        
        if self.message != nil {
            self.messageLabel.text = self.message
        }
    }
    
    fileprivate func configureTimer() {
        if self.timer == nil && self.hasTimer {
            self.timer = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(MZToast.dismiss(_:)), userInfo: nil, repeats: false)
        }
    }
    
    fileprivate func updateAnotherToasts() {
        if self.superview != nil && self.superview?.subviews.count > 0 {
            for view in (self.superview?.subviews)! {
                if view is MZHeaderView {
                    self.superview?.bringSubview(toFront: view)
                } else if view is MZToast && view != self {
                    if view.frame.origin.y > self.frame.origin.y {
                        var newFrame: CGRect = view.frame
                        newFrame.origin.y -= self.height + self.margin
                        view.frame = newFrame
                    } else {
                        self.superview?.bringSubview(toFront: view)
                    }
                }
            }
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.hideWithAnimation()
    }
    
}
