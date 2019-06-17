//
//  MZServiceActivationSerialNumber.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 30/11/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation


@objc protocol MZServiceActivationSerialNumberViewControllerDelegate: NSObjectProtocol
{
	func activationSerialCodeInput(_ code : String)
}


class MZServiceActivationSerialNumberViewController : UIViewController, UITextFieldDelegate
{
	var service : MZService?
	var delegate : MZServiceActivationSerialNumberViewControllerDelegate?
	
	@IBOutlet weak var uiLbTop: UILabel!
	@IBOutlet weak var uiTfCode: MZTextField!
	@IBOutlet weak var uiBtActivate: UIButton!
	
	@IBAction func uiBtActivate_TouchUp(_ sender: AnyObject)
	{
		if(!(self.uiTfCode.text?.isEmpty)!)
		{
			self.delegate!.activationSerialCodeInput(self.uiTfCode.text!)
		}
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
	
	
	func setupInterface()
	{
		self.uiLbTop.text = String(format: NSLocalizedString("mobile_activation_serial_already_have", comment: ""), (self.service?.name)!)
		self.uiLbTop.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		self.uiTfCode.placeholder = NSLocalizedString("mobile_insert_code_placeholder", comment: "")
		self.uiTfCode?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 17)

		self.uiBtActivate.setTitle(NSLocalizedString("mobile_activate_now", comment: ""), for: .normal)
	}
	
	func clearForms()
	{
		self.uiTfCode.text = ""
	}
}
