//
//  MZCheckBox.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

@IBDesignable
class MZCheckBox: UIButton {
	// Images
	var checkedImage = UIImage(named: "icon_check_selected")! as UIImage
	var uncheckedImage = UIImage(named: "icon_check")! as UIImage
	
	// Bool property
	var  isChecked: Bool = false {
		didSet{
			if isChecked == true
			{
				self.setBackgroundImage(checkedImage, for: .normal)
			} else {
				self.setBackgroundImage(uncheckedImage, for: .normal)
			}
		}
	}
	
//	func setCustomImages(uncheckedImg: UIImage, checkedImg: UIImage)
//	{
//		
//		self.checkedImage = checkedImg;
//		self.uncheckedImage = uncheckedImg
//		if isChecked
//		{
//			self.setImage(checkedImage, forState: .normal)
//		}
//		else
//		{
//			self.setImage(uncheckedImage, forState: .normal)
//		}
//		self.layoutIfNeeded()
//	}
	
	override func awakeFromNib()
	{
		self.addTarget(self, action: #selector(MZCheckBox.buttonClicked(_:)), for: UIControlEvents.touchUpInside)
		self.isChecked = false
	}
	
	func buttonClicked(_ sender: UIButton)
	{
		if sender == self
		{
			isChecked = !isChecked
		}
	}
}
