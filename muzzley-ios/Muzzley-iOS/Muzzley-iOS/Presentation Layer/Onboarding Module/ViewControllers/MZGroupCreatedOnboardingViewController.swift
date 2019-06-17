//
//  MZGroupCreatedOnboardingViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 02/01/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZGroupCreatedOnboardingViewController: MZOnboardingViewController
{
	override init()
	{
		super.init()
	}
	
	convenience init(modalPresentationStyle: UIModalPresentationStyle, highlightViews:[UIView])
	{
		self.init()
		titles = [NSLocalizedString("mobile_onboarding_group_created_1_title", comment: "")]
		details = [NSLocalizedString("mobile_onboarding_group_created_1_text", comment: "")]
		close = "\n\n" + NSLocalizedString("mobile_onboarding_group_created_1_close", comment: "")

		self.modalPresentationStyle = modalPresentationStyle
		self.highlightViews = highlightViews
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func showStep(_ step : Int)
	{
		switch step {
		case 0:
			contextualOnboarding.iType = .circle
			if(highlightViews.count > 0)
			{
				contextualOnboarding.radius = 150
				contextualOnboarding.setupShowcase(forView:highlightViews[steps], withTitle: titles[steps], detailsMessage: details[steps], closeMessage: close)
			}
			else
			{
				contextualOnboarding.radius = 0
				contextualOnboarding.setupShowcase(forLocation:CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), withTitle: titles[steps], detailsMessage: details[steps], closeMessage: close)
			}
			
			contextualOnboarding.show()
			
		default:
			self.hide()
		}
	}
}
