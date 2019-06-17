//
//  MZCardsOnBoarding.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 18/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import UIKit

class MZCardsOnboardingViewController: MZOnboardingViewController
{
	override init()
	{
		super.init()
	}
	
	convenience init(modalPresentationStyle: UIModalPresentationStyle, highlightViews:[UIView])
	{
		self.init()
		let appName = MZThemeManager.sharedInstance.appInfo.applicationName

		titles = [NSLocalizedString("mobile_onboarding_cards_1_title", comment: "")]
		details = [String(format: NSLocalizedString("mobile_onboarding_cards_1_text", comment: ""), appName)]
		close = "\n\n\n" + NSLocalizedString("mobile_onboarding_cards_1_close", comment: "")
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
//            contextualOnboarding.titleFont = UIFont.init(name: "icomoon", size: 90.0)!
//            contextualOnboarding.detailsFont = UIFont.regularFontOfSize(17)
//			
//            let transform = "Any-Hex/Java"
//            let convertedString = titles[step].mutableCopy() as! NSMutableString
//            CFStringTransform(convertedString, nil, transform as NSString, true)
			
            contextualOnboarding.radius = 40
			contextualOnboarding.setupShowcase(forLocation: CGRect(x: 27,y: self.view.frame.size.height - 40,width: CGFloat(contextualOnboarding.radius),height: CGFloat(contextualOnboarding.radius)), withTitle: titles[step], detailsMessage: details[step], closeMessage: close)
            contextualOnboarding.show()

        default:
            self.hide()
        }        
    }
}
