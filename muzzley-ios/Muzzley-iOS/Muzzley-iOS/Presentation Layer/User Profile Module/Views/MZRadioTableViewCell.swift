//
//  MZRadioTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZRadioTableViewCell: UITableViewCell {

    @IBOutlet weak var radioItem: MZRadioItemView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.radioItem.textAlignment = .left
        
        let bgColorView: UIView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = bgColorView
    }
    
}
 
