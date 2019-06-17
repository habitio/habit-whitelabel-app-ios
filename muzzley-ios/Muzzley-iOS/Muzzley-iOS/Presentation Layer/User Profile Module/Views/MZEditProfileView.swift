//
//  MZEditProfileView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 26/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZEditProfileView: UIView {

    @IBOutlet weak var hLineHeight: NSLayoutConstraint!
    @IBOutlet weak var vLineHeight: NSLayoutConstraint!
    @IBOutlet weak var dobClickView: UIView!
    @IBOutlet weak var dobTitle: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    @IBOutlet weak var dobDatePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var genderTitle: UILabel!
    @IBOutlet weak var maleRadioItem: MZRadioItemView!
    @IBOutlet weak var femaleRadioItem: MZRadioItemView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hLineHeight.constant = 1.0 / UIScreen.main.scale
        self.vLineHeight.constant = 1.0 / UIScreen.main.scale
        
        self.dobDatePicker.maximumDate = Date()
        var newFrame: CGRect = self.dobDatePicker.frame
        newFrame.size.width = UIScreen.main.bounds.size.width
        self.dobDatePicker.frame = newFrame
        
        self.maleRadioItem.isSelected = false
        self.femaleRadioItem.isSelected = false
        
        self.dayLabel.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.monthLabel.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.yearLabel.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        
        // TODO: configure labels text attributes
    }
    
    internal func invertDobPickerVisibility() {
        if self.dobDatePickerHeight.constant == 0 {
            UIView.animate(withDuration: 0.6, animations: { () -> Void in
                self.dobDatePickerHeight.constant = 216.0
               self.dobDatePicker.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.dobDatePickerHeight.constant = 0.0
               self.dobDatePicker.isHidden = true
            })
        }
    }

}
 
