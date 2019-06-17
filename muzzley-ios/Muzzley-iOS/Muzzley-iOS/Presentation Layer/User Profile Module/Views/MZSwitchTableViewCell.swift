//
//  MZSwitchTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 30/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
	
	@IBOutlet weak var toggle: MZTriStateToggle!

	@IBOutlet weak var iconInfo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.labelSwitch.tintColor = UIColor.muzzleyGrayColorWithAlpha(1)
        //self.labelSwitch.onTintColor = UIColor.muzzleyBlueColorWithAlpha(1)
        //self.labelSwitch.addTarget(self, action: #selector(MZSwitchTableViewCell.switchChangeValue(_:)), forControlEvents: .valueChanged)
	}
}
 
