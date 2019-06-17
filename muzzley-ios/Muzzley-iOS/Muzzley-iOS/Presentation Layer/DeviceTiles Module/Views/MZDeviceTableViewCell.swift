//
//  MZDeviceTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 02/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.deviceImageView.layer.cornerRadius = self.deviceImageView.frame.size.height / 2.0
        self.deviceImageView.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 0.1).cgColor
        self.deviceImageView.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.deviceImageView.layer.masksToBounds = true
    }
    
}
