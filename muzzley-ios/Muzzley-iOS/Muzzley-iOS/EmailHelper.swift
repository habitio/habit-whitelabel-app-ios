//
//  EmailHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 24/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import MessageUI

class EmailHelper: UIViewController, MFMailComposeViewControllerDelegate
{
    func sendEmailToSupport()
	{
		//let window: UIWindow?
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
		
		mailComposerVC.setToRecipients(["support@muzzley.com"])
		mailComposerVC.setSubject("Error report - Sign In/Up")
		let version: String = "App version:" + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
//		let version: String = "App version:" + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) + ((((Bundle.main.infoDictionary!["CFBundleIcons"] as! NSDictionary)["CFBundlePrimaryIcon"]!["CFBundleIconFiles"] as! [Any]).first as! String).lowercased().range(of: "beta") != nil ? "-beta" : "") + "/" + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
		mailComposerVC.setMessageBody(version, isHTML: false)
		
		if(MFMailComposeViewController.canSendMail())
		{
			UIApplication.shared.keyWindow?.rootViewController?.present(mailComposerVC, animated: true, completion: nil)
		}
		else
		{
			self.showSendMailErrorAlert()
		}
	}
    
	func sendEmail()
	{
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
		
		mailComposerVC.setToRecipients([])
		mailComposerVC.setSubject("")
		mailComposerVC.setMessageBody("", isHTML: false)
		
		if(MFMailComposeViewController.canSendMail())
		{
			self.present(mailComposerVC, animated: true, completion: nil)
		}
		else
		{
			self.showSendMailErrorAlert()
		}
	}
	
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("mobile_send_mail_error_title", comment: ""), message: NSLocalizedString("mobile_send_mail_error_text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: ""))
		sendMailErrorAlert.show()
	}
}
