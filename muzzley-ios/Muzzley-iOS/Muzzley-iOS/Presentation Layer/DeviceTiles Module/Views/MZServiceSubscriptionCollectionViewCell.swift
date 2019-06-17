//
//  MZServiceSubscriptionCollectionViewCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 07/04/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZServiceSubscriptionCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var uiImage: UIImageView!
	@IBOutlet weak var uiLabel: UILabel!
	@IBOutlet weak var uiImageState: UIImageView!
	
	var state : Bool = false
	{
		didSet
		{
			if(state)
			{
				self.uiImageState.image = UIImage(named: "icon_service_active")
			}
			else
			{
				self.uiImageState.image = UIImage(named: "icon_service_inactive")
			}
		}
	}
	
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
		
		self.layer.cornerRadius = CORNER_RADIUS
		self.layer.masksToBounds = true
		self.uiLabel.font = UIFont.lightFontOfSize(17)
	}
	
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
		self.layer.shadowOpacity = 0.2
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowRadius = 1
		self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,cornerRadius: self.layer.cornerRadius).cgPath
	}

}
