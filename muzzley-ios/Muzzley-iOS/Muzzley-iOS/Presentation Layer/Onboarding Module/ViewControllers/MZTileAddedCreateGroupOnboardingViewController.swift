//
//  MZTileAddedCreateGroupOnboardingViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 02/01/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZTileAddedCreateGroupOnboardingViewController: MZOnboardingViewController
{
	
	override init()
	{
		super.init()
	}
	
	convenience init(modalPresentationStyle: UIModalPresentationStyle, highlightViews:[UIView])
	{
		self.init()
		titles = [NSLocalizedString("mobile_onboarding_tile_added_create_group_1_title", comment: ""),
		          NSLocalizedString("mobile_onboarding_tile_added_create_group_2_title", comment: "")]
		details = [NSLocalizedString("mobile_onboarding_tile_added_create_group_1_text", comment: ""),
		           "\n" + NSLocalizedString("mobile_onboarding_tile_added_create_group_2_text", comment: "")]

		close = "\n\n" +  NSLocalizedString("mobile_got_it", comment: "")
		
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
			close = "\n\n" + NSLocalizedString("mobile_onboarding_tile_added_create_group_1_close", comment: "")
			contextualOnboarding.radius = 130
			contextualOnboarding.setupShowcase(forView:highlightViews[step], withTitle: titles[step], detailsMessage: details[step], closeMessage: close)
			contextualOnboarding.show()
			
		case 1:
			close = "\n\n\n" + NSLocalizedString("mobile_onboarding_tile_added_create_group_2_close", comment: "")
			contextualOnboarding.radius = 55
			contextualOnboarding.setupShowcase(forView:highlightViews[step], withTitle: titles[step], detailsMessage: details[step], closeMessage: close)
			contextualOnboarding.show()

		default:
			self.hide()
		}
	}
}
