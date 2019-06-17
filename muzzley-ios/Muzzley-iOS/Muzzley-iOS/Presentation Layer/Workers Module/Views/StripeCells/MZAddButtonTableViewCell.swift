//
//  MZAddButtonTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 17/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZAddButtonTableViewCell: MZStripeTableViewCell {

    static let height: CGFloat = CGFloat(70.0)
    
    @IBOutlet weak var uiLBNoActionableDevices: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonLeading: NSLayoutConstraint!
    
    internal var isSmall: Bool = false {
        didSet {
            self.updateIconType()
        }
    }
    
    internal var isButtonEnabled: Bool = true {
        didSet {
            updateIconEnabledState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addLabel.text = ""
        self.addLabel.textColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
        self.addLabel.font = UIFont.semiboldItalicFontOfSize(17)
        self.updateIconType()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.addLabel.text = ""
    }
    
    fileprivate func updateIconType() {
        self.contentView.bringSubview(toFront: self.addButton)
        self.buttonHeight.constant = 50.0 - (self.isSmall ? 10.0 : 0.0)
        self.buttonLeading.constant = 30.0 + (self.isSmall ? 5.0 : 0.0)
        self.addButton.setImage(UIImage(named: self.isSmall ? "IconSmallPlus" : "IconBigPlus"), for: UIControlState())
        self.addButton.backgroundColor = self.isSmall ? UIColor.muzzleyWhiteColor(withAlpha: 1) : UIColor.muzzleyBlueColor(withAlpha: 1)
        self.addButton.contentEdgeInsets = UIEdgeInsetsMake(self.isSmall ? 12.0 : 15.0, self.isSmall ? 12.0 : 15.0, self.isSmall ? 12.0 : 15.0, self.isSmall ? 12.0 : 15.0)
        
        self.addButton.layer.cornerRadius = self.buttonHeight.constant / 2.0
        self.addButton.layer.borderWidth = self.isSmall ? 1.0 : 0.0
        self.addButton.layer.borderColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
        self.addButton.layer.masksToBounds = true
    }
    
    fileprivate func updateIconEnabledState()
    {
        if(!self.isButtonEnabled)
        {
            self.addButton.backgroundColor =  UIColor.muzzleyGrayColor(withAlpha: 1)
            self.isUserInteractionEnabled = false
            self.uiLBNoActionableDevices.tintColor = UIColor.muzzleyRed2Color(withAlpha: 1)
            self.uiLBNoActionableDevices.text = NSLocalizedString("mobile_worker_no_actionable_devices", comment: "")
            self.uiLBNoActionableDevices.isHidden = false
        }
    }

}
