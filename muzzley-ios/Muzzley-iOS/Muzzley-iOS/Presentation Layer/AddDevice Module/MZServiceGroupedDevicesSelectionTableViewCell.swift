//
//  MZServiceGroupedDevicesSelectionTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



@objc protocol MZServiceGroupedDevicesSelectionTableViewCellDelegate: NSObjectProtocol
{
	func tappedTryAgain(_ profile: MZChannelTemplate)
	func triggerValidation()
}


class MZServiceGroupedDevicesSelectionTableViewCell : UITableViewCell, UITableViewDataSource, UITableViewDelegate
{
	@IBOutlet weak var uiContentView: UIView!
	
    @IBOutlet weak var uiShadowView: UIView!
    
    @IBOutlet weak var uiMainView: UIView!

	@IBOutlet weak var uiTableView: UITableView!
	
	@IBOutlet weak var uiViewTerms: UIView!
	
	@IBOutlet weak var uiLbTermsConditions: UILabel!
	
	@IBOutlet weak var uiLbTermsConditionsLink: UILabel!
	
	@IBOutlet weak var uiViewTermsLayer: UIView!
	
	@IBOutlet weak var uiBtTryAgain: UIButton!
	
	@IBOutlet weak var uiLbNumberOfDevices: UILabel!
	
	@IBOutlet weak var uiLbNumberOfDevicesHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var uiViewTermsHeightConstraint: NSLayoutConstraint!
	
	var delegate : MZServiceGroupedDevicesSelectionTableViewCellDelegate?
    	
	@IBAction func uiBtTermsCheckBox_TouchUpInside(_ sender: AnyObject)
	{
		self.viewModel!.acceptedTerms = !self.viewModel!.acceptedTerms
		validateGroup()
	}
	
	@IBAction func uiBtTryAgain_TouchUpInside(_ sender: AnyObject)
	{
		self.viewModel?.isLoading = true
		updateLoading()
		self.delegate!.tappedTryAgain((self.viewModel?.profile)!)
	}
	
	let loadingView = MZLoadingTopRightViewController()
	
	var viewModel : MZProfileDevicesViewModel?
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
		self.uiMainView.layer.cornerRadius = CORNER_RADIUS
		self.uiMainView.layer.masksToBounds = false
	}
	
	func validateGroup()
	{
		var count = 0
		for d in self.viewModel!.devices
		{
			if d.channelSubscription != nil && d.isSelected
			{
				count+=1
			}
		}
		
		if(self.viewModel!.occurrences > 0 && count != self.viewModel!.occurrences)
		{
			self.uiLbNumberOfDevices.textColor = UIColor.muzzleyRed2Color(withAlpha: 1)
		}
		else
		{
			self.uiLbNumberOfDevices.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
		}
		
		self.delegate?.triggerValidation()
	}
	
	
    func setupInterface(_ vm : MZProfileDevicesViewModel)
	{
		self.viewModel = vm
        
         self.uiBtTryAgain.isHidden = true
        
		self.uiViewTermsLayer.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 0.75)
		// Show terms if they exist
		if(self.viewModel!.showTerms)
		{
			self.uiViewTermsHeightConstraint.constant = 44
			self.uiViewTerms.isHidden = false
		}
		else
		{
			self.uiViewTermsHeightConstraint.constant = 0
			self.uiViewTerms.isHidden = true
		}
	
		// Show try again and hide terms layer
		if(self.viewModel!.showGroupError)
		{
            self.uiBtTryAgain.isHidden = false
            self.uiViewTermsLayer.isHidden = false
		}
		else
		{
            self.uiBtTryAgain.isHidden = false
			self.uiViewTermsLayer.isHidden = true
		}

		self.uiTableView.register(UINib(nibName: "MZServiceDeviceSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "MZServiceDeviceSelectionTableViewCell")
	
		self.uiTableView.rowHeight = UITableViewAutomaticDimension
		self.uiTableView.estimatedRowHeight = 140

		self.uiTableView.delegate = self
		self.uiTableView.dataSource = self
		
		self.uiLbTermsConditions.text = NSLocalizedString("mobile_service_device_selection_terms_label", comment: "")
		self.uiLbTermsConditions.font.withSize(13)
		self.uiLbTermsConditions.textColor = UIColor.muzzleyGrayColor(withAlpha: 1)
		self.uiLbTermsConditionsLink.text = NSLocalizedString("mobile_service_device_selection_terms_button", comment: "")
		self.uiLbTermsConditionsLink.font.withSize(13)
		self.uiLbTermsConditionsLink.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
		
		let attributedText = NSMutableAttributedString(string: uiLbTermsConditionsLink.text!)
		attributedText.addAttribute(NSUnderlineStyleAttributeName, value:NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, uiLbTermsConditionsLink.text!.characters.count))

		self.uiLbTermsConditionsLink.attributedText = attributedText
		if(self.viewModel!.occurrences > 0)
		{
			self.uiLbNumberOfDevices.text = String(format: NSLocalizedString("mobile_service_device_selection_number_devices", comment: ""),  String(self.viewModel!.occurrences))
		}
		else
		{
			self.uiLbNumberOfDevices.text = NSLocalizedString("mobile_device_selection_select_devices", comment: "")
		}
		self.uiLbNumberOfDevices.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
		
        self.uiTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.uiTableView.frame.size.width, height: 1))
        
		updateLoading()
		
		self.uiTableView.reloadData()
        
        

	}
	
	func updateLoading()
	{
		if(self.viewModel!.isLoading)
		{
			self.loadingView.updateLoader(self.uiMainView, enabled: true, sideDescription: self.viewModel?.loadingSideText, topDescription: self.viewModel?.loadingTopText)
            self.uiBtTryAgain.isHidden = true
		}
		else
		{
			self.loadingView.updateLoader(self.uiMainView, enabled: false)
            self.uiBtTryAgain.isHidden = false
        }
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.viewModel!.devices.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{

		let cell : MZServiceDeviceSelectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZServiceDeviceSelectionTableViewCell", for: indexPath) as! MZServiceDeviceSelectionTableViewCell
		cell.selectionStyle = UITableViewCellSelectionStyle.none
		
		let gesture = UITapGestureRecognizer(target: self, action: #selector(self.termsLinkTapHandler(_:)))
		uiLbTermsConditionsLink.addGestureRecognizer(gesture)
		
		if(self.viewModel?.devices.count > self.viewModel?.occurrences)
		{
			self.uiTableView.allowsSelection = true
			self.uiTableView.allowsMultipleSelection = true
			cell.uiBtCheckBox.isHidden = false
			self.uiLbNumberOfDevices.isHidden = false
			self.uiLbNumberOfDevicesHeightConstraint.constant = 40
		}
		else
		{
			self.uiTableView.allowsSelection = false
			self.uiTableView.allowsMultipleSelection = false
			cell.uiBtCheckBox.isHidden = true
			self.uiLbNumberOfDevices.isHidden = true
			self.uiLbNumberOfDevicesHeightConstraint.constant = 0
		}
		
		cell.setupInterface(self.viewModel!.devices[indexPath.row])

		if(self.viewModel!.isLoading)
		{
			self.loadingView.updateLoader(self.uiMainView, enabled: true)
		}
		else
		{
			self.loadingView.updateLoader(self.uiMainView, enabled: false)
		}

//		if(indexPath.row == (self.viewModel!.devices.count - 1))
//		{
//			cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
//			cell.layoutSubviews()
//		}
		return cell
	}
    
    override func layoutSubviews()
    {
        self.uiMainView.layer.cornerRadius = CORNER_RADIUS
        self.uiMainView.layer.masksToBounds = true
        
//        self.uiContentView.dropShadow(cornerRadius: CORNER_RADIUS)
//        print(self.uiMainView.frame)
//        print(self.uiShadowView.frame)
//
//        self.uiShadowView.layer.frame = self.uiMainView.layer.frame
//        self.uiShadowView.layer.cornerRadius = CORNER_RADIUS
//
//        self.uiShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
//        self.uiShadowView.layer.shadowOpacity = 0.2
//        self.uiShadowView.layer.shadowColor = UIColor.black.cgColor
//        self.uiShadowView.layer.shadowRadius =  1 //1
//        self.uiShadowView.layer.shadowPath = UIBezierPath(roundedRect: self.uiShadowView.bounds, cornerRadius: self.uiMainView.layer.cornerRadius).cgPath
        
    }
        

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		self.viewModel!.devices[indexPath.row].isSelected = !self.viewModel!.devices[indexPath.row].isSelected
		
		self.uiTableView.reloadData()
		self.validateGroup()
	}
	
	func termsLinkTapHandler(_ sender:UITapGestureRecognizer)
	{
		UIApplication.shared.openURL(URL(string: self.viewModel!.profile.termsUrl)!)
	}
}
