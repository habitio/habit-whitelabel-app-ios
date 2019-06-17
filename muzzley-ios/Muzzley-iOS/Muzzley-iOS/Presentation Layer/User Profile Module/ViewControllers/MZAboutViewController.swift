//
//  MZAboutViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 30/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZAboutViewController: UIViewController {

    fileprivate var wireframe: UserProfileWireframe!
    @IBOutlet weak var horizontalLogo: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightTxtView: UITextView!
    @IBOutlet weak var privacyTxtView: UITextView!
    @IBOutlet weak var termsAndConditionsBtn: UIButton!
    @IBOutlet weak var privacyPolicyBtn: UIButton!
    
	@IBOutlet weak var uiBtWebsite: UIButton!
    convenience init(withWireframe wireframe: UserProfileWireframe) {
        self.init(nibName: "MZAboutViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        MZAnalyticsInteractor.aboutMuzzleyViewEvent()
    }
	

    fileprivate func setupInterface()
	{
		self.horizontalLogo.image = UIImage(named: "horizontal_logo_profile")

		let barButton: UIBarButtonItem = UIBarButtonItem()
		barButton.title = ""
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton

        self.title = NSLocalizedString("mobile_about", comment: "")
        var version: String = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
		
		version += "/" + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
		
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy"
		
		let startDate = MZThemeManager.sharedInstance.copyright.startDate
		let companyName = MZThemeManager.sharedInstance.copyright.companyName
		
		let string = NSLocalizedString("mobile_about_copyright", comment: "")
		let endDate = formatter.string(from: Date())
		
		// Need to convert to NSString otherwise the format won't work on Swift 2. Works on Objective-C and swift 3 though... no comments...
        let copyrightTextFormatted = NSString(format: string as NSString,  startDate, endDate, companyName, MZThemeManager.sharedInstance.appInfo.applicationName)

        self.copyrightTxtView.text = String(copyrightTextFormatted)
		if(MZThemeManager.sharedInstance.urls.website != nil  && !(MZThemeManager.sharedInstance.urls.website?.absoluteString.isEmpty)!)
		{
			self.uiBtWebsite.setTitle(NSLocalizedString("mobile_about_website", comment: ""), for: UIControlState())
			self.uiBtWebsite.isHidden = false
		}
		else
		{
			self.uiBtWebsite.isHidden = true
		}

		
		self.privacyTxtView.text = String(format: NSLocalizedString("mobile_about_privacy", comment: ""), companyName)
		
		if MZThemeManager.sharedInstance.urls.termsServices != nil
		{
			self.termsAndConditionsBtn.setTitle(NSLocalizedString("mobile_about_tc", comment: ""), for: UIControlState())
			self.termsAndConditionsBtn.isHidden = false
		}
		else
		{
			self.termsAndConditionsBtn.isHidden = true
		}

		if MZThemeManager.sharedInstance.urls.privacyPolicy != nil
		{
			self.privacyPolicyBtn.setTitle(NSLocalizedString("mobile_about_pp", comment: ""), for: UIControlState())
			self.privacyPolicyBtn.isHidden = false
		}
		else
		{
			self.privacyPolicyBtn.isHidden = true
		}
		
		if(self.termsAndConditionsBtn.isHidden && self.privacyPolicyBtn.isHidden)
		{
			self.privacyTxtView.isHidden = true
		}
		else
		{
			self.privacyTxtView.isHidden = false
		}
		
        let isRunningTestFlightBeta = (Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt")
        if isRunningTestFlightBeta
        {
            version += "b"
        }
        
        self.versionLabel.text = version
		
        
        self.view.isUserInteractionEnabled = true
        let debugGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MZAboutViewController.setupDebugView(_:)))
        debugGesture.numberOfTapsRequired = 5
        debugGesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(debugGesture)
    }
    
    @IBAction func setupDebugView(_ sender: AnyObject) {
        UserDefaults.standard.set(true, forKey: "DebugEnabled")
        UserDefaults.standard.synchronize()
        MZNotifications.send(MZNotificationKeys.UserProfile.DebugLogEnabled, obj: nil)
    }
    
    @IBAction func openTermsAndConditions () {
        let vc = MZWebViewController()
        vc.url = MZThemeManager.sharedInstance.urls.termsServices
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openPrivacyPolicy () {
        let vc = MZWebViewController()
        vc.url = MZThemeManager.sharedInstance.urls.privacyPolicy
        self.navigationController?.pushViewController(vc, animated: true)
    }
	
	@IBAction func uiBtWebsite_TouchUpInside(_ sender: AnyObject) {
		let vc = MZWebViewController()
		vc.url = MZThemeManager.sharedInstance.urls.website
		self.navigationController?.pushViewController(vc, animated: true)

	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
