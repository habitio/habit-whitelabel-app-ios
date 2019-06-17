//
//  MZDeviceSelectionCell.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 11/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation

class MZDeviceSelectionCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var deviceNameLabel: UILabel?
    @IBOutlet weak var checkmark: UIImageView?

    override func draw(_ rect: CGRect) {
        self.imgView!.layer.cornerRadius = (self.imgView?.frame.size.width)! / 2.0
        self.imgView!.layer.masksToBounds = true
        self.imgView!.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 1).cgColor
        self.imgView!.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.checkmark!.layer.cornerRadius = (self.checkmark?.frame.size.width)! / 2.0
    }
    
    override func prepareForReuse() {
        self.imgView?.cancelImageDownloadTask()
        self.imgView?.image = nil
        self.deviceNameLabel?.text = ""
    }
    
    func setViewModel(_ viewModel: MZDeviceViewModel) {
        self.prepareForReuse()
        self.imgView!.setImageWith(viewModel.imageUrlAlt!)
        self.deviceNameLabel!.text = viewModel.title
    }
    
}
