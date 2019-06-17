//
//  CardDatePicker.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 12/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZCardDatePickerDelegate: NSObjectProtocol {
    func datePickerToggled()
}

@objc class MZCardDatePicker: UIViewController, ToggleButtonDelegate {
    @IBOutlet weak var atButton : UIButton?
    @IBOutlet weak var atLabel : UILabel?
    @IBOutlet weak var datePickerBgView : UIView?
    @IBOutlet weak var datePicker : UIDatePicker?
    @IBOutlet weak var dateComponentsSeparatorViewConstraint : NSLayoutConstraint?

    @IBOutlet var daysButtons: Array<MZToggleButton>?

    var value : NSObject?
    var card: MZCardViewModel?
    var field: MZFieldViewModel?
//    var indexPath: IndexPath?
    
    var delegate: MZCardDatePickerDelegate?

    func setupDesign ()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MZCardDatePicker.updateDatePickerSeparatorsAndAtButtonText), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        
        self.datePickerBgView!.layer.cornerRadius = 4
        self.datePickerBgView!.layer.masksToBounds = true

        let textColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
        self.datePicker!.setValue(textColor, forKeyPath: "textColor")

        self.datePicker!.datePickerMode = .countDownTimer
        self.datePicker!.datePickerMode = .time
		if(MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat == 24)
		{
			self.datePicker!.locale = Locale.init(identifier:"pt_PT")
		}
		else
		{
			self.datePicker!.locale = Locale.init(identifier:"en_US")
		}

        self.atButton!.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1.0), for: UIControlState())
        self.atButton!.titleLabel?.font = UIFont.mediumFontOfSize(15.0)
        self.atLabel!.textColor = self.card?.colorMainText
    }

//    override func draw(_ rect: CGRect)
//    {
//        super.draw(CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat(self.calculateHeightForCell())))
//    }

    override func viewDidLoad() {
        self.setupUI()
        self.setupDesign()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(MZCardDatePicker.closeDatePicker))
        self.view.addGestureRecognizer(tgr)
        
        self.atButton!.addTarget(self, action: #selector(MZCardDatePicker.openDatePicker), for: .touchUpInside)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.setupDesign()
//
//        let tgr = UITapGestureRecognizer(target: self, action: #selector(MZCardDatePicker.closeDatePicker))
//        self.addGestureRecognizer(tgr)
//
//        self.atButton!.addTarget(self, action: #selector(MZCardDatePicker.openDatePicker), for: .touchUpInside)
//    }
    

    func setViewModel(_ cardViewModel: MZCardViewModel, fieldViewModel: MZFieldViewModel)
    {
        self.card = cardViewModel
        self.field = fieldViewModel
    }
    
    

    func setupUI()
    {
        
        let theValue = self.field?.getValue()
        if let timePH : [MZTimePlaceholderViewModel] = theValue as? [MZTimePlaceholderViewModel] {
            self.value = timePH[0]
        } else {
            self.value = field!.placeholders.first as? MZTimePlaceholderViewModel
        }
        
        self.field?.setValue(self.value!)
        
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel
        
        self.updateDatePickerSeparatorsAndAtButtonText()
        
        self.datePicker!.isHidden = !timePlaceholder.datePickerOpened
        self.datePickerBgView!.isHidden = self.datePicker!.isHidden

        self.atButton?.setTitle(timePlaceholder.timeUI, for: UIControlState())
        
        var i = 0
        for button in self.daysButtons! {
            let toggleButton: MZToggleButton = button
            toggleButton.tag = i
            toggleButton.delegate = self
            toggleButton.setStatus(timePlaceholder.weekDays[i])
            i += 1
        }
        
    }
    
    
    func updateDatePickerSeparatorsAndAtButtonText ()
    {
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel

        timePlaceholder.setupDate(self.datePicker!.date)

        if (timePlaceholder.is24H) {
//            self.dateComponentsSeparatorViewConstraint!.constant = 0.0
        } else {
//            self.dateComponentsSeparatorViewConstraint!.constant = -27.0
        }
        
        self.atButton?.setTitle(timePlaceholder.timeUI, for: UIControlState())
    }
    
    
    func calculateHeightForCell () -> Int
    {
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel

        var height = 103
        
        if (timePlaceholder.datePickerOpened == true) {
            height += 175
        }
        return height
    }
    
    
    @IBAction func dateDidChange ()
    {
        self.updateDatePickerSeparatorsAndAtButtonText()
    }
    
    
    func openDatePicker ()
    {
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel

        if (timePlaceholder.datePickerOpened == true)
        {
            return            
        }
        
        self.datePicker!.date = timePlaceholder.timeDate

        timePlaceholder.datePickerOpened = true
        self.datePicker!.isHidden = false
        self.datePickerBgView!.isHidden = false
        
        self.delegate!.datePickerToggled()
    }
    
    
    func closeDatePicker ()
    {
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel

        self.datePicker!.date = timePlaceholder.timeDate
        
        timePlaceholder.datePickerOpened = false
        self.datePicker!.isHidden = true
        self.datePickerBgView!.isHidden = true
        
        self.delegate!.datePickerToggled()
    }
    
    
    func closePicker()
    {
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel
        timePlaceholder.datePickerOpened = false
    }

    
    func toggleButtonTapped(_ btnIndex: Int, currentStatus: Bool)
    {
        let timePlaceholder : MZTimePlaceholderViewModel = self.value as! MZTimePlaceholderViewModel
        timePlaceholder.weekDays[btnIndex] = currentStatus
        self.field?.setValue(self.value!)
    }
    
}
