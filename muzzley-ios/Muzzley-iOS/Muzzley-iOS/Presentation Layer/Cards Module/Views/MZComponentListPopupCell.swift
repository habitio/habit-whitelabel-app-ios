//
//  MZComponentListPopupCell.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 11/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation

class MZComponentListPopupCell: UITableViewCell {
        
    @IBOutlet weak var deviceNameLabel: UILabel?
    @IBOutlet weak var checkmark: UIView?

    override func draw(_ rect: CGRect)
    {
        self.checkmark!.layer.cornerRadius = (self.checkmark?.frame.size.width)! / 2.0
    }
    
    override func prepareForReuse()
    {
        self.deviceNameLabel?.text = ""
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.deviceNameLabel!.font = UIFont.regularFontOfSize(14)
    }
    
    func setViewModel(_ viewModel: MZComponentViewModel)
    {
        self.deviceNameLabel!.text = viewModel.title
    }
    
}
