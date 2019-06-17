//
//  MZShortcutsOnboardingViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 03/01/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
class MZShortcutsOnboardingViewController: MZOnboardingViewController
{
	
	override init()
	{
		super.init()
	}
	
	convenience init(modalPresentationStyle: UIModalPresentationStyle, highlightViews:[UIView])
	{
		self.init()
		
		titles = [NSLocalizedString("mobile_onboarding_shortcuts_1_title", comment: "")]
		details = [String(format: NSLocalizedString("mobile_onboarding_shortcuts_1_text", comment: ""), MZThemeManager.sharedInstance.appInfo.applicationName)]
		close = "\n\n" + NSLocalizedString("mobile_onboarding_shortcuts_1_close", comment: "")
		
		self.modalPresentationStyle = modalPresentationStyle
		self.highlightViews = highlightViews
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func showStep(_ step : Int)
	{
		switch step
        {
		case 0:
			contextualOnboarding.radius = 50
			contextualOnboarding.setupShowcase(forView:highlightViews[step], withTitle: titles[step] as String, detailsMessage: details[step], closeMessage: close)
			contextualOnboarding.show()
			
		default:
			self.hide()
		}
	}
}
