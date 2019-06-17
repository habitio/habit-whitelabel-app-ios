//
//  MZDeviceDetailTileCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 07/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZDeviceDetailTileCell: MZCollectionViewCell {

    @IBOutlet weak var selectionBar: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selectionBar.backgroundColor = UIColor.muzzleyGray4Color(withAlpha: 1.0)
        self.deviceName.text = ""
        self.deviceName.font = UIFont.regularFontOfSize(12)
        self.backgroundImage.cancelImageDownloadTask()
        self.backgroundImage.image = nil
    }

    override func setModel(_ model: NSObject!) {
        assert(model.isKind(of: MZTileViewModel.self), "")
        
        let deviceTileViewModel: MZTileViewModel = model as! MZTileViewModel
        self.deviceName.text = deviceTileViewModel.title
        
        self.backgroundImage.cancelImageDownloadTask()
        if deviceTileViewModel.imageURL != nil
		{
			
            self.backgroundImage.setImageWith(deviceTileViewModel.imageURL! as! URL)
        } else {
            self.backgroundImage.image = nil
        }
        
        self.selectionBar.backgroundColor = deviceTileViewModel.isSelected ? UIColor.muzzleyBlueColor(withAlpha: 1) : UIColor.muzzleyGray4Color(withAlpha: 1.0)
        self.deviceName.textColor = deviceTileViewModel.isSelected ? UIColor.muzzleyBlueColor(withAlpha: 1) : UIColor.muzzleyGray4Color(withAlpha: 1.0)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

}
