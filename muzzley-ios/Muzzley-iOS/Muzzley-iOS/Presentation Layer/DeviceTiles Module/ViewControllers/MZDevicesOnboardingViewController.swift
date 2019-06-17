//
//  MZDevicesOnboardingViewController.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 21/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZDevicesOnboardingViewController: MZOnboardingViewController
{
	override init()
	{
		super.init()
	}
	
	convenience init(modalPresentationStyle: UIModalPresentationStyle, highlightViews:[UIView])
	{
		self.init()
		self.titles = [NSLocalizedString("mobile_onboarding_devices_1_title", comment: "")]
		self.details = [NSLocalizedString("mobile_onboarding_devices_1_text", comment: "")]
		self.close = "\n\n" + NSLocalizedString("mobile_onboarding_devices_1_close", comment: "")
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
            contextualOnboarding.radius = 44
			if(highlightViews.count > 0)
			{
				contextualOnboarding.setupShowcase(forView:highlightViews[step], withTitle: titles[step], detailsMessage: details[step], closeMessage: close)
			}
			else
			{
				contextualOnboarding.setupShowcase(forLocation:CGRect(x: 0,y: 22,width: self.view.frame.width, height: self.view.frame.height), withTitle: titles[step], detailsMessage: details[step], closeMessage: close)
			}
			contextualOnboarding.show()
        default:
            self.hide()
        }
    }
}
