//
//  MZWorkerConstructionOnboardingViewModel.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 02/01/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZWorkersOnboardingViewController: MZOnboardingViewController
{
	override init()
	{
		super.init()
	}
	
	convenience init(modalPresentationStyle: UIModalPresentationStyle, highlightViews:[UIView])
	{
		self.init()
		titles = [NSLocalizedString("mobile_onboarding_worker_construction_1_title", comment: "")]
		details = [NSLocalizedString("mobile_onboarding_worker_construction_1_text", comment: "")]
		close = "\n\n" + NSLocalizedString("mobile_onboarding_worker_construction_1_close", comment: "")
		
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
			contextualOnboarding.radius = 80.0

			contextualOnboarding.setupShowcase(forView:highlightViews[step], withTitle: titles[step], detailsMessage: details[step], closeMessage: close)
			contextualOnboarding.show()
		default:
			self.hide()
		}
	}
}