//
//  MZPhoneSwitchTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/08/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZPhoneSwitchTableViewCell: UITableViewCell {
	
	@IBOutlet weak var title: UILabel!
	
	@IBOutlet weak var toggle: MZTriStateToggle!
	
//	@IBOutlet weak var iconInfo: UIImageView!
	
	@IBOutlet weak var uiButton: UIButton!
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
		self.uiButton.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1), for: .normal)

	}
	
	
	@IBAction func uiButton_TouchUpInside(_ sender: Any) {
	}
}
 
