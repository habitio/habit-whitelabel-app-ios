//
//  MZCardTextView.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 17/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZCardTextView : UIViewController
{
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var txtView: UITextView!
    
    @IBOutlet weak var cntrtWidth: NSLayoutConstraint!
    @IBOutlet weak var cntrtHeight: NSLayoutConstraint!
    
    let widthIcon :CGFloat = 87.0
    
    
    var card: MZCardViewModel?
    var stage: MZStageViewModel?
    var indexPath: IndexPath?
    
    func setCardViewModel(_ viewModel: MZCardViewModel)
    {
        self.card = viewModel
        self.stage = viewModel.stages[viewModel.unfoldedStagesIndex]
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        self.view.sizeToFit()
    }
    func setupUI()
    {
        self.view.backgroundColor = self.card?.colorMainBackground

        let textContent: String = stage!.text.content
        let rangeStyles: NSArray = stage!.text.rangeStyles as NSArray
        
        let defaultFontSize: Float = 15
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: textContent as String)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrString.length))

        let font = UIFont.regularFontOfSize(defaultFontSize)
        attrString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attrString.length))

        for index in 0 ..< rangeStyles.count
        {
            let rs: MZRangeStyleViewModel = rangeStyles[index] as! MZRangeStyleViewModel
            
            let isBold: Bool = rs.bold
            let isItalic: Bool = rs.italic
            let isUnderlined: Bool  = rs.underline
            
            var range: [Int] = rs.range
            
            if range.count > 1
            {
                if attrString.length < range[1]
                {
                    range[1] = attrString.length
                }
                
                let length : Int = range[1] - range[0]
                
                let attributedRange: NSRange = NSMakeRange(range[0], length)

                if rs.fontSizeScale != 1
                {
                    let regularFont = UIFont.regularFontOfSize(defaultFontSize * rs.fontSizeScale)
                    attrString.addAttribute(NSFontAttributeName, value: regularFont, range: attributedRange)
                }
                
                if (isBold) {
                    let font = UIFont.boldFontOfSize(defaultFontSize * rs.fontSizeScale)
                    attrString.addAttribute(NSFontAttributeName, value: font, range: attributedRange)
                }
             
                if (isItalic) {
                    let font = UIFont.italicFontOfSize(defaultFontSize * rs.fontSizeScale)
                    attrString.addAttribute(NSFontAttributeName, value: font, range: attributedRange)
                }
                
                if (isUnderlined) {
                    attrString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: attributedRange)
                }
                
                if !rs.color.isEmpty
                {
                    attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: rs.color), range: attributedRange)
                }
            }
        }
        
        self.txtView?.attributedText = attrString
        self.txtView?.contentInset = UIEdgeInsetsMake(-6,0,-6,0)
        self.txtView?.textContainer.lineFragmentPadding = 0
        
        var width = UIScreen.main.bounds.width - (8*2+16*2)
        
        if self.stage!.iconUrl != nil && !self.stage!.iconUrl!.absoluteString!.isEmpty
        {
            width -= widthIcon
        }
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        //TODO FIX ME!!
        let rect = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: options, context: nil)
        stage!.text.totalTextViewHeight = rect.height + 18
        
        
        self.txtView?.textColor = self.card?.colorMainText

        self.imgIcon?.image = nil

        
        if self.stage!.iconUrl != nil && !self.stage!.iconUrl!.absoluteString!.isEmpty
        {
            let imageRequest: URLRequest = URLRequest(url: self.stage!.iconUrl! as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
            self.imgIcon?.setImageWith(imageRequest, placeholderImage: UIImage(), success: nil, failure: nil)
            self.imgIcon?.clipsToBounds = true;
            //            self.cntrtWidth.constant = widthIcon
            //            self.cntrtHeight.constant = widthIcon
        } else {
            self.cntrtWidth.constant = 0
            self.cntrtHeight.constant = 0
        }

        var newFrame = self.txtView?.frame
        newFrame?.size.height = stage!.text.totalTextViewHeight
        self.txtView?.frame = newFrame!
    }
}
