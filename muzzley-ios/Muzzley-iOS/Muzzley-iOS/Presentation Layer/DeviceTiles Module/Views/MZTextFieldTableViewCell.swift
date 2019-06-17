//
//  MZTextFieldTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 02/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonWidth: NSLayoutConstraint!
    
    fileprivate var textFieldBorder: CALayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textField.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.textField.delegate = self
        self.doneButton.tintColor = UIColor.muzzleyGrayColor(withAlpha: 0.4)
        
        self.textFieldBorder = CALayer()
        self.textFieldBorder.borderColor = UIColor.muzzleyBlueColor(withAlpha: 1.0).cgColor
        self.textFieldBorder.frame = CGRect(x: 0.0, y: self.textField.frame.size.height - 1.0 / UIScreen.main.scale, width: UIScreen.main.bounds.size.width - 32.0, height: 1.0 / UIScreen.main.scale)
        self.textFieldBorder.borderWidth = 1.0 / UIScreen.main.scale
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.doneButton.alpha = 1.0
        self.doneButtonWidth.constant = 0.0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.doneButton.alpha = 0.0
            self.doneButton.layoutIfNeeded()
            self.textField.layoutIfNeeded()
        }, completion: { (success) -> Void in
            self.doneButton.isHidden = true
            self.textField.layer.addSublayer(self.textFieldBorder)
        }) 
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.doneButtonWidth.constant = 24.0
        self.doneButton.alpha = 0.0
        self.doneButton.isHidden = false
        self.textFieldBorder.removeFromSuperlayer()
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.doneButton.alpha = 1.0
            self.doneButton.layoutIfNeeded()
            self.textField.layoutIfNeeded()
        })
    }
    
    @IBAction func doneButtonAction(_ sender: AnyObject) {
        self.textField.becomeFirstResponder()
    }
    
}
