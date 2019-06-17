//
//  MZProfileServiceCollectionCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZProfileServiceCollectionCell : UICollectionViewCell
{

    @IBOutlet weak var uiOverlayImage: UIImageView!
    @IBOutlet weak var uiImage: UIImageView!
	@IBOutlet weak var uiLabel: UILabel!
	
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
