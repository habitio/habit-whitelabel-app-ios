//
//  MZStatisticsView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZStatisticsView: UIView {

    @IBOutlet weak var topLineHeight: NSLayoutConstraint!
    @IBOutlet weak var devicesNumberLabel: UILabel!
    @IBOutlet weak var devicesText: UILabel!
    @IBOutlet weak var sharesCountLabel: UILabel!
    @IBOutlet weak var sharesText: UILabel!
    @IBOutlet weak var workersNumberLabel: UILabel!
    @IBOutlet weak var workersText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.topLineHeight.constant = 1.0 / UIScreen.main.scale
        // TODO: configure labels
    }

} 
