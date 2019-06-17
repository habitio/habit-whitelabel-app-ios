//
//  MZSettingsLocationUndefinedViewCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 25/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

class MZSettingsLocationUndefinedViewCell : UITableViewCell
{

	@IBOutlet weak var imgPlaceIcon: UIImageView!
	
	@IBOutlet weak var lbName: UILabel!
	
	@IBOutlet weak var lbAdd: UILabel!
	
	var placeVM : MZPlaceViewModel = MZPlaceViewModel()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let bgColorView: UIView = UIView()
		bgColorView.backgroundColor = UIColor.clear
		self.selectedBackgroundView = bgColorView
		lbAdd.tintColor = UIColor.blue
        
        self.lbAdd.text = NSLocalizedString("mobile_add_plus", comment: "")
	}

	
}
