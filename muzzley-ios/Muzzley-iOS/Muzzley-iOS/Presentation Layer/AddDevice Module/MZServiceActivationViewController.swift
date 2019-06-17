//
//  MZServiceActivationViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 24/11/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

enum MZActivationModeEnum
{
	case oAuth
	case serialNumber
	case none
}


@objc protocol MZServiceActivationViewControllerDelegate: NSObjectProtocol
{
	func activationSuccessful()
	func activationUnsuccessful()
}


class MZServiceActivationViewController : UIViewController, MZServiceActivationSerialNumberViewControllerDelegate, MZDiscoveryRecipeInteractorOutput, OAuthViewControllerDelegate
{

	var activationCallback : MZDiscoveryRequestActivationCallback?
	var discoveryProcessAction : MZDiscoveryProcessAction?
	var activationMode = MZActivationModeEnum.none
	var service : MZService?
	var shopUrl = ""
	var delegate : MZServiceActivationViewControllerDelegate?
	var interactor : MZDiscoveryRecipeInteractor?
	var expandedButtonRect : CGRect?
	var collapsedButtonRect : CGRect?
	var authorizationUrl : URL?
	
	var stepResultUrl : URL?
	var currentStepActionId : String = ""
	
	var serialNumberVC : MZServiceActivationSerialNumberViewController?

	
	@IBOutlet weak var uiActivationView: UIView!

	@IBOutlet weak var uiShopView: UIView!
	
	@IBOutlet weak var uiLbShopText: UILabel!
	
	@IBOutlet weak var uiBtShop: MZColorButton!
	
	@IBOutlet weak var uiBtCollapseExpand: UIButton!
	
	@IBOutlet weak var uiViewCollapsed: UIView!
	
	@IBOutlet weak var uiViewExpanded: UIView!
		
	@IBOutlet weak var uiBtShopBottomMarginConstraint: NSLayoutConstraint!
	@IBOutlet weak var uiBtShopHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var uiBtShopTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var uiBtShopLeadingConstraint: NSLayoutConstraint!
//
//	@IBOutlet weak var uiBtShopWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var uiLbTopText: UILabel!
	@IBOutlet weak var uiLbShopDescription: UILabel!
	
	
	@IBOutlet weak var uiShopViewHeightConstraint: NSLayoutConstraint!
	
	var isExpanded = true
	var collapsedHeight = 74.0
	var expandedHeight = UIScreen.main.bounds.height / 2
	
	@IBAction func uiBtCollapseExpand(_ sender: AnyObject)
	{
		expandCollapse()
	}
	
	override func viewWillDisappear(_ animated : Bool) {
		super.viewWillDisappear(animated)
		
        if (self.isMovingFromParentViewController){
			self.delegate?.activationUnsuccessful()
		}
	}
	
	func expandCollapse()
	{
		if(isExpanded)
		{
			setCollapsed()
		}
		else
		{
			setExpanded()
		}
	}
	
	func setCollapsed()
	{
        isExpanded = false
        self.uiBtShopBottomMarginConstraint.constant = 12
        self.uiShopViewHeightConstraint.constant = CGFloat(collapsedHeight)
        self.uiBtCollapseExpand.imageView?.transform =  CGAffineTransform(rotationAngle: CGFloat(M_PI * 1.5))
        
        //self.uiBtShop.frame = CGRect(x: 0,y: self.uiBtShop.frame.origin.y,width: 90, height: self.uiBtShop.frame.height)
        //    self.uiBtShopWidthConstraint.constant = 90
        
        self.uiBtShopTrailingConstraint.constant = 20
        self.uiBtShopLeadingConstraint.constant = UIScreen.main.bounds.width - 110
        self.uiBtShopHeightConstraint.constant = 30
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.uiLbTopText.alpha = 0
            self.uiShopView.layoutIfNeeded()
        }, completion: { (success) -> Void in
				UIView.animate(withDuration: 0.1, animations: { () -> Void in
					self.uiViewCollapsed.alpha = 1
					self.uiViewExpanded.alpha = 0

					self.uiShopView.layoutIfNeeded()
					self.uiBtShop.layer.cornerRadius = self.uiBtShop!.bounds.height / 2
					self.uiBtShop.layoutIfNeeded()

					}, completion: nil)
		})
	}
		
	func setExpanded()
	{
		isExpanded = true
		self.uiBtCollapseExpand.imageView?.transform =  CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
		
		UIView.animate(withDuration: 0.01, animations: { () -> Void in
			self.uiViewCollapsed.alpha = 0
			self.uiViewExpanded.alpha = 1
			self.uiLbTopText.alpha = 1
			self.uiShopView.layoutIfNeeded()
			}, completion: { (success) -> Void in
				self.uiBtShopBottomMarginConstraint.constant = 20
				self.uiBtShopHeightConstraint.constant = 40
				self.uiBtShopLeadingConstraint.constant = 20
				self.uiBtShopTrailingConstraint.constant = 20
				self.uiShopViewHeightConstraint.constant = self.expandedHeight
				UIView.animate(withDuration: 0.5, animations: { () -> Void in
					self.uiShopView.layoutIfNeeded()
					}, completion: nil)
		})
	}
	
	@IBAction func uiBtShop_TouchUpInside(_ sender: AnyObject)
	{
		UIApplication.shared.openURL(URL(string: shopUrl)!)
	}
	

	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		setupInterface()
	}
	
	func getActivationWindowType()
	{
		interactor = MZDiscoveryRecipeInteractor(url: authorizationUrl!)
		interactor!.requestDiscoveryProcessInfo()
	}
	
	func setupInterface()
	{
		
		let barButton: UIBarButtonItem = UIBarButtonItem()
		barButton.title = ""
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton

		self.title = NSLocalizedString("mobile_activation_title", comment: "")
		self.collapsedButtonRect = uiBtShop.frame

		Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(MZServiceActivationViewController.setCollapsed), userInfo: nil, repeats: false)
		
		setExpanded()
		self.uiViewCollapsed.backgroundColor = UIColor.muzzleyVeryLightBlueColor(withAlpha: 1)
		self.uiViewExpanded.backgroundColor = UIColor.muzzleyVeryLightBlueColor(withAlpha: 1)
		
		self.uiBtCollapseExpand.setImage(UIImage(named: "icon_card_arrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
		self.uiBtCollapseExpand.backgroundColor = UIColor.muzzleyVeryLightBlueColor(withAlpha: 1)
		self.uiBtCollapseExpand.imageView?.contentMode = .scaleAspectFit
		self.uiBtCollapseExpand.imageView?.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
		self.uiBtCollapseExpand.layer.cornerRadius = self.uiBtCollapseExpand!.bounds.height / 2
		
		self.uiLbShopText.text = String(format: NSLocalizedString("mobile_activation_serial_dont_have", comment: ""), self.service!.name)
		self.uiLbShopText.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 14)
		self.uiLbShopText.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		self.uiBtShop.setTitle(NSLocalizedString("mobile_add_service_shop", comment: ""), for: .normal)
		
		
		self.uiLbTopText.text = String(format: NSLocalizedString("mobile_activation_serial_dont_have", comment: ""), self.service!.name)
		self.uiLbTopText.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		self.uiLbShopDescription.text = self.service!.shopDescription
		self.uiLbShopDescription.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)

		switch activationMode
		{
			
		case MZActivationModeEnum.oAuth:
			let oAuthVC = OAuthViewController(nibName: SCREEN_ID_CHANNEL_OAUTH, bundle: Bundle.main)
			oAuthVC.urlHost = self.authorizationUrl;
			oAuthVC.view.frame = self.uiActivationView.frame
			oAuthVC.delegate = self;
			self.addChildViewController(oAuthVC)
			self.uiActivationView.addSubview(oAuthVC.view)
					break
			
		default:
			getActivationWindowType()
			break
		}
	}
	
	func activationSerialCodeInput(_ code: String)
	{
		let array = self.interactor?.createActionResultsArray(with: [code], actionId: (self.discoveryProcessAction?.identifier)!)
		
		
		if ((self.activationCallback) != nil) {
			self.activationCallback!(array as? [Any]);
			return;
		}
	}
	
	func requestActivationAction(_ action: MZDiscoveryProcessAction!, callback: (([Any]?) -> Void)!) {
		self.activationCallback = callback
		self.discoveryProcessAction = action
		switch action.type
		{
			
		case "activation-code":
			self.activationMode = MZActivationModeEnum.serialNumber
			if(serialNumberVC == nil)
			{
				serialNumberVC = MZServiceActivationSerialNumberViewController()
				self.serialNumberVC!.service = service
				self.serialNumberVC!.view.frame = self.uiActivationView.frame
				self.serialNumberVC!.delegate = self
				self.addChildViewController(serialNumberVC!)
				self.uiActivationView.addSubview(serialNumberVC!.view)
			}
			
			self.serialNumberVC!.clearForms()
			
			break
			
		default:
			break
		}
	}
	
	
	func foundDiscoveryProcessStepInfo(_ discoveryProcessStep: MZDiscoveryProcessStep!) {
		
	}
	
	
	// MZDiscoveryRecipe Delegates
	func foundDiscoveryProcessInfo(_ discoveryProcess : MZDiscoveryProcess)
	{
		self.interactor!.startCustomAuthentication()
	}
	
	func authenticationFailedWithError(_ error: Error!) {
		let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_activation_error_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: { action in
			self.navigationController?.popViewController(animated: false)
		}))
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_retry", comment: ""), style: .default, handler: { action in
			self.interactor!.requestDiscoveryProcessInfo()
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	
    func authenticationDidEnded(withSuccessAndData data: [AnyHashable : Any]!) {
        self.delegate?.activationSuccessful()
    }

	func authenticationDidEndedWithSuccess()
	{
		self.delegate?.activationSuccessful()
	}

	
	func oAuthViewControllerDidAuthenticate(_ oAuthViewController: OAuthViewController)
	{
	 	self.delegate?.activationSuccessful()
	}
	
	func oAuthViewControllerDidCancelAuthentication(_ oAuthViewController: OAuthViewController!) {
		self.delegate?.activationUnsuccessful()
	}
	
	func oAuthViewControllerDidFailAuthentication(_ oAuthViewController: OAuthViewController)
	{
		self.delegate?.activationUnsuccessful()
	}
    
    @IBAction func didTapSuccessOAuth(_ sender: AnyObject) {
        self.delegate?.activationSuccessful()
    }
}
