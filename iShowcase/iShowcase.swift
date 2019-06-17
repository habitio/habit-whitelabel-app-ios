//
//  iShowcase.swift
//  iShowcase
//
//  Created by Rahul Iyer on 12/10/15.
//  Copyright © 2015 rahuliyer. All rights reserved.
//  https://cocoapods.org/?q=ishowcase

import UIKit
import Foundation

@objc public protocol iShowcaseDelegate : NSObjectProtocol {
    @objc optional func iShowcaseShown(_ showcase: iShowcase)
    @objc optional func iShowcaseDismissed(_ showcase: iShowcase)
}

@objc open class iShowcase: UIView {
    
    /**
     Type of the highlight for the showcase

     - CIRCLE:    Creates a circular highlight around the view
     - RECTANGLE: Creates a rectangular highligh around the view
     */
    @objc public enum TYPE: Int {
        case circle = 0
        case rectangle = 1
    }
    
    fileprivate enum REGION: Int {
        case top = 0
        case left = 1
        case bottom = 2
        case right = 3
        
        static func regionFromInt(_ region: Int) -> REGION {
            switch (region) {
            case 0:
                return .top
            case 1:
                return .left
            case 2:
                return .bottom
            case 3:
                return .right
            default:
                return .top
            }
        }
    }
    
    fileprivate var showcaseImageView: UIImageView = UIImageView()
    fileprivate var titleLabel: UILabel = UILabel()
    fileprivate var detailsLabel: UILabel = UILabel()
    
    //ADDED BY CRISTINA LOPES
    fileprivate var closeLabel: UILabel = UILabel()
    
    fileprivate let containerView: UIView = (UIApplication.shared.delegate!.window!)!
    fileprivate var showcaseRect: CGRect?
    fileprivate var region: REGION?
    
    /// Font to be used with title. Default is System font of size 24
    open var titleFont: UIFont = UIFont.systemFont(ofSize: 24)
    /// Font to be used with details. Default is System font of size 16
    open var detailsFont: UIFont = UIFont.systemFont(ofSize: 16)
    /// Color of the title text. Default is White Color
    open var titleColor: UIColor = UIColor.white
    /// Color of the details text. Default is White Color
    open var detailsColor: UIColor = UIColor.white

    /// Color of the showcase highlight. Default is #1397C5
    open var highlightColor: UIColor = iShowcase.colorHexFromString("#1397C5")
    
    //ADDED BY CRISTINA LOPES
    /// Cover Alpha
    open var coverAlpha: CGFloat = 0.9
    /// Cover Color
    open var coverColor: UIColor = UIColor.black
    /// Font to be used with close. Default is System font of size 17
    open var closeFont: UIFont = UIFont.systemFont(ofSize: 17)
    /// Color of the close text. Default is White Color
    open var closeColor: UIColor = UIColor.white
    
    
    /// Type of the showcase to be created. Default is Rectangle
    open var iType: TYPE = .rectangle
    /// Text alignment for title. Default is Center
    open var titleTextAlignment: NSTextAlignment = NSTextAlignment.center
    /// Text alignment for details. Default is Center
    open var detailsTextAlignment: NSTextAlignment = NSTextAlignment.center
    /// Radius of the circle with iShowcase type Circle. Default radius is 25
    open var radius: Float = 25
    /// Single Shot ID for iShowcase
    open var singleShotId: Int64 = -1
    /// Delegate for handling iShowcase callbacks
    open var delegate: iShowcaseDelegate?
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		self.isAccessibilityElement = true
		self.accessibilityIdentifier = "onboarding"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Initialize an instance of iShowcase

     - parameter titleFont:       Custom font for the title
     - parameter detailsFont:     Custom font for the description
     - parameter titleColor:      Custom color for the title
     - parameter detailsColor:    Custom color for the description
     - parameter coverColor: Color of the cover
     - parameter highlightColor:  Color for the iShowcase highlight
     - parameter iType:           Type of the iShowcase highlight

     - returns: Instance of iShowcase
     */
    public convenience init(withTitleFont titleFont: UIFont?,
        withDetailsFont detailsFont: UIFont?,
        withTitleColor titleColor: UIColor?,
        withDetailsColor detailsColor: UIColor?,
        withCoverColor coverColor: UIColor?,
        withHighlightColor highlightColor: UIColor?,
        withIType iType: TYPE?) {
        self.init()
        
        if let titleFont = titleFont {
            self.titleFont = titleFont
        }
        
        if let detailsFont = detailsFont {
            self.detailsFont = detailsFont
        }
        
        if let titleColor = titleColor {
            self.titleColor = titleColor
        }
        
        if let detailsColor = detailsColor {
            self.detailsColor = detailsColor
        }
        
        if let coverColor = coverColor {
            self.coverColor = coverColor
        } else {
            self.coverColor = UIColor.black
        }
        
        if let highlightColor = highlightColor {
            self.highlightColor = highlightColor
        }
        
        if let iType = iType {
            self.iType = iType
        }
    }
    
    /**
     Setup the showcase for a view

     - parameter view:    The view to be highlighted
     - parameter title:   Title for the showcase
     - parameter details: Description of the showcase
     */
    open func setupShowcase(forView view: UIView, withTitle title: String, detailsMessage details: String, closeMessage close: String) {
        self.setupShowcase(
            forTarget: view,
            withTitle: title,
            detailsMessage: details,
            closeMessage: close)
    }
    
    /**
     Setup showcase for the item at 1st position (0th index) of the table

     - parameter tableView: Table whose item is to be highlighted
     - parameter title:     Title for the showcase
     - parameter details:   Description of the showcase
     */
    open func setupShowcase(forTableView tableView: UITableView, withTitle title: String, detailsMessage details: String, closeMessage close: String) {
        self.setupShowcase(
            forTableView: tableView,
            withIndexOfItem: 0,
            setionOfItem: 0,
            withTitle: title,
            detailsMessage: details,
            closeMessage: close)
    }
    
    /**
     Setup showcase for the item at the given index in the given section of the table

     - parameter tableView: Table whose item is to be highlighted
     - parameter row:       Index of the item to be highlighted
     - parameter section:   Section of the item to be highlighted
     - parameter title:     Title for the showcase
     - parameter details:   Description of the showcase
     */
    open func setupShowcase(forTableView tableView: UITableView, withIndexOfItem row: Int, setionOfItem section: Int, withTitle title: String, detailsMessage details: String, closeMessage close: String) {
        self.setupShowcase(
            forLocation: tableView.convert(
                tableView.rectForRow(at: IndexPath(row: row, section: section)),
                to: self.containerView),
            withTitle: title,
            detailsMessage: details,
            closeMessage: close)
    }
    
    /**
     Setup showcase for the Bar Button in the Navigation Bar

     - parameter barButtonItem: Bar button to be highlighted
     - parameter title:         Title for the showcase
     - parameter details:       Description of the showcase
     */
    open func setupShowcase(forBarButtonItem barButtonItem: UIBarButtonItem, withTitle title: String, detailsMessage details: String, closeMessage close: String) {
        self.setupShowcase(
            forTarget: barButtonItem.value(forKey: "view")! as AnyObject,
            withTitle: title,
            detailsMessage: details,
            closeMessage: close)
    }
    
    /**
     Setup showcase to highlight any object that can be converted to rect on the screen

     - parameter target:  The object to be highlighted
     - parameter title:   Title for the showcase
     - parameter details: Description of the showcase
     */
    open func setupShowcase(forTarget target: AnyObject, withTitle title: String, detailsMessage details: String, closeMessage close: String) {
        self.setupShowcase(
            forLocation: target.convert(target.bounds, to: self.containerView),
            withTitle: title,
            detailsMessage: details,
            closeMessage: close)
    }
    
    /**
     Setup showcase to highlight a particular location on the screen

     - parameter location: Location to be highlighted
     - parameter title:    Title for the showcase
     - parameter details:  Description of the showcase
     */
    open func setupShowcase(forLocation location: CGRect, withTitle title: String, detailsMessage details: String, closeMessage close: String) {
        self.showcaseRect = location
        self.setupBackground()
        self.calculateRegion()
        self.setupText(withTitle: title, detailsText: details  + "\n\n OK", closeText: close)
        
        //ADDED BY CRISTINA LOPES - descendant validation

        if !showcaseImageView.isDescendant(of: self)
        {
            self.addSubview(showcaseImageView)
        }
        if !titleLabel.isDescendant(of: self)
        {
            self.addSubview(titleLabel)
        }
        if !detailsLabel.isDescendant(of: self)
        {
            self.addSubview(detailsLabel)
        }
		
// Commented out due to layout issues
//        if !closeLabel.isDescendantOfView(self)
//        {
//            self.addSubview(closeLabel)
//        }
		
        self.addGestureRecognizer(self.getGesture())

    }
    
    /**
     Display the iShowcase
     */
    open func show() {
        if self.singleShotId != -1 && UserDefaults.standard.bool(forKey: String(format: "iShowcase-%ld", self.singleShotId)) {
            self.recycleViews()
            return
        }
        
        self.alpha = 1
        for view in containerView.subviews {
            view.isUserInteractionEnabled = false
        }
        
        UIView.transition(
            with: containerView,
            duration: 0.5,
            options: UIViewAnimationOptions.transitionCrossDissolve,
            animations: {() -> Void in
                self.containerView.addSubview(self)
            }) {(Bool) -> Void in
            if let delegate = self.delegate {
                if delegate.responds(to: "iShowcaseShown:") {
                    delegate.iShowcaseShown!(self)
                }
            }
        }
    }
    
    fileprivate func setupBackground() {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        var context: CGContext? = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.coverColor.cgColor)
        context!.fill(containerView.bounds)
        
        if self.iType == .rectangle {
            
            if let showcaseRect = showcaseRect {
                
                // Outer highlight
                let highlightRect = CGRect(x: showcaseRect.origin.x - 15, y: showcaseRect.origin.y - 15, width: showcaseRect.size.width + 30, height: showcaseRect.size.height + 30)
                
                context!.setShadow(offset: CGSize.zero, blur: 30, color: self.highlightColor.cgColor)
                context!.setFillColor(self.coverColor.cgColor)
                context!.setStrokeColor(self.highlightColor.cgColor)
                context!.addPath(UIBezierPath(rect: highlightRect).cgPath)
                context!.drawPath(using: .fillStroke)
                
                // Inner highlight
                context!.setLineWidth(3)
                context!.addPath(UIBezierPath(rect: showcaseRect).cgPath)
                context!.drawPath(using: .fillStroke)
                
                let showcase = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // Clear region
                UIGraphicsBeginImageContext(showcase!.size)
                showcase!.draw(at: CGPoint.zero)
                context = UIGraphicsGetCurrentContext()
                context!.clear(showcaseRect)
                
            }
            
        } else {
            
            if let showcaseRect = showcaseRect {
                
                let center = CGPoint(x: showcaseRect.origin.x + showcaseRect.size.width / 2.0, y: showcaseRect.origin.y + showcaseRect.size.height / 2.0)
                
                // Draw highlight
                context!.setLineWidth(2.54)
                context!.setShadow(offset: CGSize.zero, blur: 30, color: self.highlightColor.cgColor)
                context!.setFillColor(self.coverColor.cgColor)
                context!.setStrokeColor(self.highlightColor.cgColor)
				
				context?.addArc(center: center, radius: CGFloat(self.radius * 2), startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: false)
				//CGContextAddArc(context!, center.x, center.y, CGFloat(self.radius * 2), 0, CGFloat(2 * M_PI), 0)
                context!.drawPath(using: .fillStroke)
				
				context?.addArc(center: center, radius: CGFloat(self.radius), startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: false)

				//CGContextAddArc(context!, center.x, center.y, CGFloat(self.radius), 0, CGFloat(2 * M_PI), 0)
                context!.drawPath(using: .fillStroke)
                
                // Clear circle
                context!.setFillColor(UIColor.clear.cgColor)
                context!.setBlendMode(.clear)
				
				context?.addArc(center: center, radius: CGFloat(self.radius - 0.54), startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: false)

                //CGContextAddArc(context!, center.x, center.y, CGFloat(self.radius - 0.54), 0, CGFloat(2 * M_PI), 0)
                context!.drawPath(using: .fill)
                context!.setBlendMode(.normal)
            }
            
        }
        showcaseImageView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()
        showcaseImageView.alpha = self.coverAlpha
    }
    
    fileprivate func calculateRegion() {
        if let showcaseRect = showcaseRect {
            let left = showcaseRect.origin.x,
            right = showcaseRect.origin.x + showcaseRect.size.width,
            top = showcaseRect.origin.y,
            bottom = showcaseRect.origin.y + showcaseRect.size.height
            
            let areas = [
                top * UIScreen.main.bounds.size.width, // Top region
                left * UIScreen.main.bounds.size.height, // Left region
                (UIScreen.main.bounds.size.height - bottom) * UIScreen.main.bounds.size.width, // Bottom region
                (UIScreen.main.bounds.size.width - right) - UIScreen.main.bounds.size.height // Right region
            ]
            
            var largestIndex: Int = 0
            for  i in 0 ..< areas.count //+= 1
			{
                if areas[i] > areas[largestIndex] {
                    largestIndex = i
                }
            }
            
            self.region = REGION.regionFromInt(largestIndex)
            
        }
    }
    
    fileprivate func setupText(withTitle title: String, detailsText details: String, closeText close: String) {
        
        //ADDED BY CRISTINA LOPES - margin
        let widthmargin :CGFloat = 40.0
        
        var titleSize = NSString(string: title).size(attributes: [NSFontAttributeName : self.titleFont])
        titleSize.width = UIScreen.main.bounds.size.width - widthmargin
        
        var detailsSize = NSString(string: details).size(attributes: [NSFontAttributeName : self.detailsFont])
        detailsSize.width = UIScreen.main.bounds.size.width - widthmargin
        
        var closeSize = NSString(string: close).size(attributes: [NSFontAttributeName : self.closeFont])
        closeSize.width = UIScreen.main.bounds.size.width - widthmargin
        
        let textPosition = self.getBestPositionOfTitle(withTitleSize: titleSize, withDetailsSize: detailsSize, withCloseSize: closeSize)
        
        if let region = self.region {
            
            if region == .left || region == .right {
                if let showcaseRect = self.showcaseRect {
                    titleSize.width -= showcaseRect.size.width
                    detailsSize.width -= showcaseRect.size.width
                    closeSize.width -= showcaseRect.size.width
                }
            }
            if self.region != .bottom {
                self.titleLabel = UILabel(frame: textPosition[0])
                self.detailsLabel = UILabel(frame: textPosition[1])
                self.closeLabel = UILabel(frame: textPosition[2])
            } else {// Bottom Region
                self.closeLabel = UILabel(frame: textPosition[0])
                self.detailsLabel = UILabel(frame: textPosition[1])
                self.titleLabel = UILabel(frame: textPosition[2])
            }
        }
        
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        titleLabel.textAlignment = self.titleTextAlignment
        titleLabel.textColor = self.titleColor
        titleLabel.font = self.titleFont
        
        detailsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        detailsLabel.numberOfLines = 0
        detailsLabel.text = details
        detailsLabel.textAlignment = self.detailsTextAlignment
        detailsLabel.textColor = self.detailsColor
        detailsLabel.font = self.detailsFont
        
        closeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        closeLabel.numberOfLines = 0
        closeLabel.text = close
        closeLabel.textAlignment = self.detailsTextAlignment
        closeLabel.textColor = self.closeColor
        closeLabel.font = self.closeFont
        
        titleLabel.sizeToFit()
        detailsLabel.sizeToFit()
        closeLabel.sizeToFit()
        
        titleLabel.frame = CGRect(
            x: containerView.bounds.size.width / 2.0 - titleLabel.frame.size.width / 2.0,
            y: titleLabel.frame.origin.y,
            width: titleLabel.frame.size.width,
            height: titleLabel.frame.size.height)
        
        detailsLabel.frame = CGRect(
            x: containerView.bounds.size.width / 2.0 - detailsLabel.frame.size.width / 2.0,
            y: detailsLabel.frame.origin.y,
            width: detailsLabel.frame.size.width,
            height: detailsLabel.frame.size.height)
        
        closeLabel.frame = CGRect(
            x: containerView.bounds.size.width / 2.0 - closeLabel.frame.size.width / 2.0,
            y: closeLabel.frame.origin.y,
            width: closeLabel.frame.size.width,
            height: closeLabel.frame.size.height)
        
    }
    
    fileprivate func getBestPositionOfTitle(withTitleSize titleSize: CGSize, withDetailsSize detailsSize: CGSize, withCloseSize closeSize: CGSize) -> [CGRect] {
        var rect0: CGRect = CGRect(), rect1: CGRect = CGRect(), rect2: CGRect = CGRect()
        
        //ADDED BY CRISTINA LOPES -margin
        let heightmargin : CGFloat = 40.0
        
        if let region = self.region {
            
            switch region {
            
            case .top:
                
                //CHANGED BY CRISTINA LOPES - dinamic top margin

                rect0 = CGRect(
                    x: containerView.bounds.size.width / 2.0 - titleSize.width / 2.0,
                    y: titleSize.height + containerView.bounds.size.height*0.10,
                    width: titleSize.width,
                    height: titleSize.height)
                rect1 = CGRect(
                    x: containerView.bounds.size.width / 2.0 - detailsSize.width / 2.0,
                    y: rect0.origin.y + rect0.size.height + detailsSize.height / 2.0 + heightmargin,
                    width: detailsSize.width,
                    height: detailsSize.height)
                rect2 = CGRect(
                    x: containerView.bounds.size.width / 2.0 - closeSize.width / 2.0,
                    y: rect1.origin.y + rect1.size.height + closeSize.height / 2.0 + heightmargin,
                    width: closeSize.width,
                    height: closeSize.height)
                break
            
            case .left:
                rect0 = CGRect(
                    x: 0,
                    y: containerView.bounds.size.height / 2.0,
                    width: titleSize.width,
                    height: titleSize.height)
                rect1 = CGRect(
                    x: 0,
                    y: rect0.origin.y + rect0.size.height + detailsSize.height / 2.0,
                    width: detailsSize.width,
                    height: detailsSize.height)
                rect2 = CGRect(
                    x: 0,
                    y: rect1.origin.y + rect1.size.height + closeSize.height / 2.0,
                    width: closeSize.width,
                    height: closeSize.height)
                break
            
            case .bottom:
                rect0 = CGRect(
                    x: containerView.bounds.size.width / 2.0 - closeSize.width / 2.0,
                    y: containerView.bounds.size.height - closeSize.height * 2.0,
                    width: closeSize.width,
                    height: closeSize.height)
                rect1 = CGRect(
                    x: containerView.bounds.size.width / 2.0 - detailsSize.width / 2.0,
                    y: rect0.origin.y - rect0.size.height - detailsSize.height / 2.0,
                    width: detailsSize.width,
                    height: detailsSize.height)
                rect2 = CGRect(
                    x: containerView.bounds.size.width / 2.0 - titleSize.width / 2.0,
                    y: rect1.origin.y - rect1.size.height - titleSize.height / 2.0,
                    width: titleSize.width,
                    height: titleSize.height)
                break
            
            case .right:
                rect0 = CGRect(
                    x: containerView.bounds.size.width - titleSize.width,
                    y: containerView.bounds.size.height / 2.0,
                    width: titleSize.width,
                    height: titleSize.height)
                rect1 = CGRect(
                    x: containerView.bounds.size.width - detailsSize.width,
                    y: rect0.origin.y + rect0.size.height + detailsSize.height / 2.0,
                    width: detailsSize.width,
                    height: detailsSize.height)
                rect2 = CGRect(
                    x: containerView.bounds.size.width - closeSize.width,
                    y: rect1.origin.y + rect1.size.height + closeSize.height / 2.0,
                    width: closeSize.width,
                    height: closeSize.height)
                break
                
            }
            
        }
        
        return [rect0, rect1, rect2]
    }
    
    fileprivate func getGesture() -> UIGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: "showcaseTapped")
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        return singleTap
    }
    
    internal func showcaseTapped() {
        UIView.animate(
            withDuration: 0.5,
            animations: {() -> Void in
                self.alpha = 0
            }, completion: {(Bool) -> Void in
            self.onAnimationComplete()
        }) 
    }
    
    fileprivate func onAnimationComplete() {
        self.recycleViews()
        if let delegate = delegate {
            if delegate.responds(to: "iShowcaseDismissed:") {
                delegate.iShowcaseDismissed!(self)
            }
        }
    }
    
    fileprivate func recycleViews() {
        if self.singleShotId != -1 {
            UserDefaults.standard.set(true, forKey: String(format: "iShowcase-%ld", self.singleShotId))
            self.singleShotId = -1
        }
        
        for view in self.containerView.subviews {
            view.isUserInteractionEnabled = true
        }
        
        showcaseImageView.removeFromSuperview()
        titleLabel.removeFromSuperview()
        detailsLabel.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    open static func colorHexFromString(_ colorString: String) -> UIColor {
        let hex = colorString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
