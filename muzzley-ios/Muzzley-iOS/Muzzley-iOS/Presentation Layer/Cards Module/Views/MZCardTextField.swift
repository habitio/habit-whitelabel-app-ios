//
//  MZCardTextField.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZCardTextField : UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var txtField : MZTextField?
    
    var value : NSObject?
    var card: MZCardViewModel?
    var field: MZFieldViewModel?
    
    override func viewDidLoad() {
        setupUI()
    }

    func setViewModel(_ cardViewModel: MZCardViewModel, fieldViewModel: MZFieldViewModel)
    {
        self.card = cardViewModel
        self.field = fieldViewModel
    }
    
    func setupUI()
    {
        self.view.backgroundColor = card!.colorMainBackground
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(MZCardTextField.textFieldDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        let ph : MZTextPlaceholderViewModel? = self.field!.placeholders.first as? MZTextPlaceholderViewModel
        
        
        let theValue = self.field?.getValue()
        if let txtPH : [MZTextPlaceholderViewModel] = theValue as? [MZTextPlaceholderViewModel]
        {
            self.value = txtPH[0]
        } else {
            if ph != nil
            {
                self.field?.setValue(ph!)
                self.txtField!.placeholder = ph!.string
            }
            self.value = MZTextPlaceholderViewModel()
        }
        
        self.txtField!.text = (self.value! as! MZTextPlaceholderViewModel).string
        self.txtField?.delegate = self
        
        setupTextFieldDesign()
    }
    
    func setupTextFieldDesign ()
    {
        //self.txtField?.tintColor = UIColor.muzzleyBlueColorWithAlpha(1.0)
        self.txtField?.layer.cornerRadius = 3
        self.txtField?.layer.masksToBounds = true
        self.txtField?.textColor = UIColor.muzzleyGray2Color(withAlpha: 1.0)
        self.txtField?.borderStyle = .none;
        self.txtField?.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1.0)
        self.txtField?.delegate = self
		self.txtField?.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 17)

    }
    
    func textFieldDidChange(_ notif: Notification)
    {
        let txtField = notif.object as! UITextField
        (self.value! as! MZTextPlaceholderViewModel).string = txtField.text!
        self.field?.setValue(self.value!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
