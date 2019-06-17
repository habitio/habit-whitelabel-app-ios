//
//  MZOnboardingViewController.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 21/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

@objc protocol MZOnboardingViewControllerDelegate {
    func contextualOnboardingDidDismiss()
}

class MZOnboardingViewController: UIViewController, iShowcaseDelegate
{
    var contextualOnboarding:iShowcase!
    var steps:Int = 0
    
    internal var delegate: MZOnboardingViewControllerDelegate?
    
    var titles: [String] = []
    var details: [String] = []
    var close: String = "\n\n\n" + NSLocalizedString("mobile_got_it", comment: "")
    var highlightViews: [UIView] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    }
	
	init()
	{
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
    func show()
    {
        contextualOnboarding = iShowcase.init()
        contextualOnboarding.titleFont = UIFont.boldFontOfSize(25)
        contextualOnboarding.detailsFont = UIFont.regularFontOfSize(15)
        contextualOnboarding.closeFont = UIFont.boldFontOfSize(25)
        contextualOnboarding.titleColor = MZThemeManager.sharedInstance.colors.complementaryColorText
        contextualOnboarding.detailsColor = MZThemeManager.sharedInstance.colors.complementaryColorText
        contextualOnboarding.closeColor = MZThemeManager.sharedInstance.colors.complementaryColorText
        contextualOnboarding.coverColor = MZThemeManager.sharedInstance.colors.complementaryColor
        contextualOnboarding.coverAlpha = 0.85
		contextualOnboarding.highlightColor = MZThemeManager.sharedInstance.colors.complementaryColor
        contextualOnboarding.iType = .circle
        contextualOnboarding.delegate = self
        
        self.showStep(steps)
    }
    
    func showStep(_ step : Int)
    {
    }
    
    func hide()
    {
        self.delegate?.contextualOnboardingDidDismiss()
        self.dismiss(animated: true, completion:nil)
    }
    
    //iShowcase delegate
    
    func iShowcaseShown(_ showcase: iShowcase)
    {
    }
    
    func iShowcaseDismissed(_ showcase: iShowcase)
    {
        steps += 1
        self.showStep(steps)
    }
    
}
