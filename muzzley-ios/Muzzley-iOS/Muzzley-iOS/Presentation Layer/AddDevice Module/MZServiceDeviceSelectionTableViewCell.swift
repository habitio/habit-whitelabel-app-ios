//
//  MZServiceDeviceSelectionTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation



class MZServiceDeviceSelectionTableViewCell : UITableViewCell
{
	@IBOutlet weak var uiImage: UIImageView!
	@IBOutlet weak var uiLabel: UILabel!
	@IBOutlet weak var uiLbError: UILabel!
	@IBOutlet weak var uiBtCheckBox: MZCheckBox!
	
	var viewModel : MZDeviceToAddViewModel?
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
	}

	func setupInterface(_ vm: MZDeviceToAddViewModel)
	{
		self.viewModel = vm
	
		if(self.viewModel?.deviceImage != nil && !self.viewModel!.deviceImage.isEmpty)
		{
			self.uiImage.setImageWith(URL(string: (self.viewModel?.deviceImage)!)!)
		}
		self.uiLabel.text = viewModel?.deviceName
		
		self.uiLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		self.uiLbError.textColor = UIColor.muzzleyRed2Color(withAlpha: 1)
		self.uiLbError.text = NSLocalizedString("mobile_service_device_selection_error", comment: "");
		
		if(self.viewModel!.showError)
		{
			viewModel?.viewState = MZViewStateEnum.error
		}
		
		uiBtCheckBox.isChecked = self.viewModel!.isSelected
		
		updateViews()
	}
	
	// Show/hide error
	func updateViews()
	{
		if(viewModel?.viewState == MZViewStateEnum.error)
		{
			self.uiLbError.isHidden = false
			DispatchQueue.main.async(execute: {
				self.uiImage!.layer.borderColor = UIColor.muzzleyRed2Color(withAlpha: 1).cgColor
			})
		}
		
		if(viewModel?.viewState == MZViewStateEnum.normal)
		{
			self.uiLbError.isHidden = true
			DispatchQueue.main.async(execute: {
				self.uiImage!.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 1).cgColor
			})
		}
	}
	
	override func draw(_ rect: CGRect)
	{
		self.uiImage!.layer.cornerRadius = (self.uiImage?.frame.size.width)! / 2.0
		self.uiImage!.layer.masksToBounds = true
		self.uiImage!.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 1).cgColor
		self.uiImage!.layer.borderWidth = 1.0 / UIScreen.main.scale
	}
}
