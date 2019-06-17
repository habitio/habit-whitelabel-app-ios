//
//  MZWorkerActionCell.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 09/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZWorkerActionView : UIView {
    
    @IBOutlet weak var imgView : UIImageView?
    
    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 1.0).cgColor
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
    }
    
    func setViewModel(_ viewModel: MZBaseWorkerDeviceViewModel) {
        
    }
    
}
    
