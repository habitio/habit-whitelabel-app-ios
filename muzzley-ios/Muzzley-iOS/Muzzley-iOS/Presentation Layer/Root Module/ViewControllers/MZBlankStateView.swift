//
//  MZBlankStateViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 29/10/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZBlankStateDelegate : NSObjectProtocol
{
    func blankStateRefreshTriggered()
    func blankStateButtonPressed()
}

@IBDesignable
class MZBlankStateView: UIView {

    
    @objc enum StateEnum : Int {
        case blank, loading, error, noInternet
    }
    
    var contentView:UIView?
    @IBInspectable var nibName:String?
    
    var currentState = StateEnum.blank
    
    var delegate : MZBlankStateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
        setupUI()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        guard let nibName = nibName else { return nil }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    @IBOutlet weak var uiImage: UIImageView!
    
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiText: UILabel!
    @IBOutlet weak var uiLoading: UIActivityIndicatorView!
    @IBOutlet weak var uiButton: UIButton!
    
    @IBAction func uiButton_TouchUpInside(_ sender: UIButton)
    {
        if delegate != nil
        {
            if currentState == .blank
            {
                delegate!.blankStateButtonPressed()
            }
            else
            {
                delegate!.blankStateRefreshTriggered()
            }
        }
    }
    
    private var blankStateImage: UIImage!
    private var blankStateTitle: String?
    private var blankStateText: String?
    private var blankStatebuttonTitle: String?
    
    private var loadingStateImage: UIImage!
    private var loadingStateTitle: String?
    private var loadingStateText: String?
    
    private var errorStateImage: UIImage!
    private var errorStateTitle: String?
    private var errorStateText: String?
    private var errorStateButtonTitle: String?
    
    
    private var noInternetStateImage: UIImage!
    private var noInternetStateTitle: String?
    private var noInternetStateText: String?
    private var noInternetStateButtonTitle: String?
    

    func setup(blankStateImage: UIImage, blankStateTitle: String, blankStateText: String, blankStatebuttonTitle: String?, loadingStateTitle: String, loadingStateText: String)
    {
        self.blankStateImage = blankStateImage
        self.blankStateTitle = blankStateTitle
        self.blankStateText = blankStateText
        self.blankStatebuttonTitle = blankStatebuttonTitle
        
        self.loadingStateImage = blankStateImage
        self.loadingStateTitle = loadingStateTitle
        self.loadingStateText = loadingStateText

        self.errorStateImage = blankStateImage
        self.errorStateTitle = NSLocalizedString("mobile_error_title", comment: "")
        self.errorStateText = NSLocalizedString("mobile_retry_text", comment: "")
        self.errorStateButtonTitle = NSLocalizedString("mobile_retry", comment: "")
        
        self.noInternetStateImage = UIImage(named: "IconNoWifi")
        
        self.noInternetStateTitle = NSLocalizedString("mobile_no_internet_title", comment: "")
        self.noInternetStateText = NSLocalizedString("mobile_no_internet_text", comment: "")
        self.noInternetStateButtonTitle = NSLocalizedString("mobile_retry", comment: "")
    }

    private func setupUI()
    {
       addRefreshFromTop()
        
        self.isHidden = true
        self.contentView?.backgroundColor = UIColor.muzzleyMainBackgroundColor(withAlpha: 1)
        self.uiTitle.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
        self.uiText.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
    }
    
    func addRefreshFromTop()
    {
        var height = self.frame.size.height * 0.4
        print(frame.size.height)
        print(frame.size.width)
        var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: height))
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = UIColor.muzzleyBlueColor(withAlpha: 0)
        scrollView.contentSize = CGSize(width: self.frame.size.width, height: 1000)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.purple
        refreshControl.alpha = 0.01
        refreshControl.addTarget(self, action: #selector(self.triggerRefreshDelegate(refreshControl:)), for: .valueChanged)
        
        scrollView.addSubview(refreshControl)
        
        self.contentView!.addSubview(scrollView)
    }
    
    
    func triggerRefreshDelegate(refreshControl: UIRefreshControl)
    {
        refreshControl.endRefreshing()
        
        if self.delegate != nil
        {
            self.delegate!.blankStateRefreshTriggered()
        }
    }
    
    public func hide()
    {
        self.isHidden = true
    }
    
    func setState(state: StateEnum)
    {
        self.currentState = state
        
        switch state {
        case StateEnum.blank:
            self.isHidden = false
            setState(image: self.blankStateImage, title: self.blankStateTitle, text: self.blankStateText, buttonTitle: self.blankStatebuttonTitle)
            self.uiLoading.isHidden = true
            break
        
        case StateEnum.loading:
            self.isHidden = false
            setState(image: self.loadingStateImage, title: self.loadingStateTitle, text: self.loadingStateText, buttonTitle: nil)
            self.uiLoading.isHidden = false
            break
            
        case StateEnum.error:
            self.isHidden = false
            setState(image: self.errorStateImage, title: self.errorStateTitle, text: self.errorStateText, buttonTitle: self.errorStateButtonTitle)
            self.uiLoading.isHidden = true
            break
            
        case StateEnum.noInternet:
            self.isHidden = false
            setState(image: self.noInternetStateImage, title: self.noInternetStateTitle, text: self.noInternetStateText, buttonTitle: self.noInternetStateButtonTitle)
            self.uiLoading.isHidden = true
            self.uiImage.tintColor = UIColor(hex: "#BCCED2")
            break
            
        default:
            break
        }
    }
    
    private func setState(image: UIImage, title: String?, text: String?, buttonTitle: String?)
    {
        self.uiImage.isHidden = false
        self.uiImage.image = image
        
        if title != nil && !title!.isEmpty
        {
            self.uiTitle.isHidden = false
            self.uiTitle.text = title
        }
        else
        {
            self.uiTitle.isHidden = true
        }
        
        if text != nil && !text!.isEmpty
        {
            self.uiText.isHidden = false
            self.uiText.text = text
        }
        else
        {
            self.uiText.isHidden = true
        }
        
        if buttonTitle == nil || buttonTitle!.isEmpty
        {
            self.uiButton.isHidden = true
        }
        else
        {
            self.uiButton.setTitle(buttonTitle, for: .normal)
            self.uiButton.isHidden = false
        }
        
    }
}
