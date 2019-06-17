//
//  MZSettingsLocationViewCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZSettingsLocationViewCell: UITableViewCell {
	
	@IBOutlet weak var imgWifi: UIImageView!
	
	@IBOutlet weak var lbName: UILabel!
	
	@IBOutlet weak var lbWifi: UILabel!
	
	@IBOutlet weak var imgPlaceIcon: UIImageView!
	
	@IBOutlet weak var lbAddress: UILabel!
	
	var placeVM : MZPlaceViewModel = MZPlaceViewModel()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let bgColorView: UIView = UIView()
		bgColorView.backgroundColor = UIColor.clear
		self.selectedBackgroundView = bgColorView
	}
	
}
