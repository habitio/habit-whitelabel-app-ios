//
//  MZDeviceToAddTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 28/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZDeviceToAddTableViewCell: UITableViewCell {

    @IBOutlet weak var devicePhoto: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceAccessory: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.devicePhoto.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        self.devicePhoto.layer.cornerRadius = self.devicePhoto.bounds.size.height / 2.0
        self.devicePhoto.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.devicePhoto.layer.borderColor = UIColor.muzzleyGray2Color(withAlpha: 1).cgColor
        self.devicePhoto.layer.masksToBounds = true
        
        self.deviceAccessory.image = UIImage(named: "IconCheck")
        self.deviceAccessory.isHidden = true
        
        self.deviceName.font = UIFont.lightFontOfSize(18)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.devicePhoto.cancelImageDownloadTask()
        self.devicePhoto.image = nil
        self.deviceName.text = ""
        self.deviceAccessory.isHidden = true
    }
    
    internal func setViewModel(_ viewModel: MZDeviceViewModel) {
        self.devicePhoto.setImageWith(viewModel.imageUrlAlt!)
        self.deviceName.text = viewModel.title
    }
    
}
