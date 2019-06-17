//
//  MZProfilePhotoTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
import GPUImage
import RxSwift
//import RxCocoa

enum Gender: String {
    case Male = "M"
    case Female = "F"
}

protocol MZProfilePhotoTableViewCellDelegate {
    func didTapPhoto()
    func didChangeEditingState(_ state: Bool)
    func didOpenDobDatePicker(_ open: Bool)
    func didSelectDobDate(_ date: Date)
    func didSelectGender(_ gender: Gender)
}

class MZProfilePhotoTableViewCell: UITableViewCell {

	
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var editButton: MZEditButton!
    @IBOutlet weak var placeholderView: UIView!
    
    internal var delegate: MZProfilePhotoTableViewCellDelegate?
    internal var profilePhoto: UIImage = UIImage(named: "icon_guest_profile")! {
        didSet {
            self.profilePhotoImageView.image = self.profilePhoto
            self.parallaxImage?.image = self.blurImage(self.profilePhotoImageView.image!, withBlurLevel: 0.25)
        }
    }
    internal var statisticsView: MZStatisticsView?
    internal var editView: MZEditProfileView?
    internal var modeEdit: Bool = false {
        didSet {
            self.editButton.isEditing = self.modeEdit
            if self.modeEdit {
                self.editButton.backgroundColor = UIColor.muzzleyBlueColor(withAlpha: 1)
            }
            self.configurePlaceholderView() 
        }
    }
    internal var dateOpened: Bool = false {
        didSet {
            self.configurePlaceholderView()
        }
    }
    internal var selectedGender: Gender?


    fileprivate var parallaxImage: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2.0
        self.profilePhotoImageView.layer.borderColor = self.modeEdit ? UIColor.muzzleyBlueColor(withAlpha: 1).cgColor : UIColor.muzzleyWhiteColor(withAlpha: 1).cgColor
        self.profilePhotoImageView.layer.borderWidth = 2.0 / UIScreen.main.scale
        self.profilePhotoImageView.layer.masksToBounds = true
        self.profilePhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZProfilePhotoTableViewCell.didTapPhotoAction(_:))))
        
        // FIXME: unhide button
        self.editButton.isHidden = true
        
        self.editButton.editIcon = UIImage(named: "IconEdit")!
        self.editButton.onEditingLabel = NSLocalizedString("mobile_done", comment: "")
        self.editButton.isEditing = self.modeEdit
        self.editButton.setNeedsDisplay()
        self.editButton.addTarget(self, action: #selector(MZProfilePhotoTableViewCell.editButtonAction(_:)), for: .touchUpInside)
        
        self.userNameField.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        
        self.configurePlaceholderView()
    }
    
    internal func cellOnTableView(_ tableView: UITableView, didScrollOnView view: UIView) {
        let difference: CGFloat = (self.parallaxImage?.frame)!.height - self.frame.height
        var imageRect: CGRect = (self.parallaxImage?.frame)!
        imageRect.origin.y = -(difference / 2.0) + ((view.frame.height / 2.0 - tableView.convert(self.frame, to: view).minY) / view.frame.height) * difference
        self.parallaxImage?.frame = imageRect
    }
    
    fileprivate func blurImage(_ image: UIImage, withBlurLevel blur: CGFloat) -> UIImage {
        let blurFilter: GPUImageiOSBlurFilter = GPUImageiOSBlurFilter()
        blurFilter.blurRadiusInPixels = blur
        blurFilter.rangeReductionFactor = 0.0
        
        let frame: CGRect = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        let backView: UIView = UIView(frame: frame)
        backView.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        
        let imagePlaceholder: UIImageView = UIImageView(frame: frame)
        imagePlaceholder.image = image
        backView.addSubview(imagePlaceholder)
        
        let blankView: UIView = UIView(frame: frame)
		blankView.backgroundColor = UIColor(red: 0.91, green: 0.92, blue: 0.93, alpha: 0.9)
        backView.addSubview(blankView)
        
        UIGraphicsBeginImageContext(image.size)
        backView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let currentImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return blurFilter.image(byFilteringImage: currentImage)
    }
    
    fileprivate func configurePlaceholderView() {
        self.parallaxImage?.removeFromSuperview()
        var pImageFrame: CGRect = self.frame
        pImageFrame.size.height = pImageFrame.size.height + 100.0
        pImageFrame.size.width = UIScreen.main.bounds.size.width
        self.parallaxImage = UIImageView(frame: pImageFrame)
        self.insertSubview(self.parallaxImage!, at: 0)
        
        self.profilePhotoImageView.layer.borderColor = self.modeEdit ? UIColor.muzzleyBlueColor(withAlpha: 1).cgColor : UIColor.muzzleyWhiteColor(withAlpha: 1).cgColor
        self.userNameField.isEnabled = self.modeEdit
        self.userNameField.textColor = self.modeEdit ? UIColor.muzzleyBlueColor(withAlpha: 1) : UIColor.muzzleyBlackColor(withAlpha: 1)
        
        var newFrame: CGRect = self.placeholderView.frame
        newFrame.size.width = UIScreen.main.bounds.size.width
        self.placeholderView.frame = newFrame
        self.placeholderView.updateConstraints()
		
		if self.modeEdit {
            self.statisticsView?.removeFromSuperview()
            if self.editView == nil {
                self.editView = Bundle.main.loadNibNamed("MZEditProfileView", owner: self, options: nil)![0] as? MZEditProfileView
                self.editView?.frame = CGRect(x: 0.0, y: 0.0, width: self.placeholderView.frame.size.width, height: self.placeholderView.frame.size.height)
                
                self.editView?.dobTitle.text = NSLocalizedString("mobile_dob", comment: "").uppercased()
                self.editView?.dayLabel.text = NSLocalizedString("mobile_day", comment: "")
                self.editView?.monthLabel.text = NSLocalizedString("mobile_month", comment: "")
                self.editView?.yearLabel.text = NSLocalizedString("mobile_year", comment: "")
                self.editView?.genderTitle.text = NSLocalizedString("mobile_gender", comment: "").uppercased()
                self.editView?.maleRadioItem.text = NSLocalizedString("mobile_male", comment: "")
                self.editView?.femaleRadioItem.text = NSLocalizedString("mobile_female", comment: "")
                
                if self.selectedGender == Gender.Male {
                    self.editView?.maleRadioItem.isSelected = true
                    self.editView?.femaleRadioItem.isSelected = false
                } else {
                    self.editView?.maleRadioItem.isSelected = false
                    self.editView?.femaleRadioItem.isSelected = true
                }
                self.editView?.maleRadioItem.tag = 100
                self.editView?.femaleRadioItem.tag = 200
                self.editView?.dobClickView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZProfilePhotoTableViewCell.didTapDob(_:))))
                self.editView?.dobDatePicker.addTarget(self, action: #selector(MZProfilePhotoTableViewCell.datePickerDidChangeValue(_:)), for: .valueChanged)
                self.editView?.maleRadioItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZProfilePhotoTableViewCell.didChangeGender(_:))))
                self.editView?.femaleRadioItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZProfilePhotoTableViewCell.didChangeGender(_:))))
            }
            self.editView?.dobDatePickerHeight.constant = 0.0
            self.editView!.dobDatePicker!.isHidden = true
            if self.dateOpened {
                self.editView?.invertDobPickerVisibility()
            }
            self.placeholderView.addSubview(self.editView!)
        } else {
            self.editView?.removeFromSuperview()
            if self.statisticsView == nil {
                self.statisticsView = Bundle.main.loadNibNamed("MZStatisticsView", owner: self, options: nil)![0] as? MZStatisticsView
                self.statisticsView?.frame = CGRect(x: 0.0, y: 0.0, width: self.placeholderView.frame.size.width, height: self.placeholderView.frame.size.height)
                
                self.statisticsView?.devicesText.text = NSLocalizedString("mobile_devices", comment: "")
                self.statisticsView?.devicesNumberLabel.text = "0"
				
				
				self.statisticsView?.sharesText.text = " " 
                self.statisticsView?.sharesCountLabel.text = ""
				
                self.statisticsView?.workersText.text = NSLocalizedString("mobile_workers", comment: "")
                self.statisticsView?.workersNumberLabel.text = "0"
            }
            //self.placeholderView.addSubview(self.statisticsView!)
        }
        self.updateConstraints()
    }
    
    
    // MARK: - UIButton Actions
    
    @IBAction func didTapPhotoAction(_ sender: AnyObject) {
        if self.modeEdit {
            self.delegate?.didTapPhoto()
        }
    }
    
    @IBAction func editButtonAction(_ sender: AnyObject) {
        self.modeEdit = !self.modeEdit
        (sender as! MZEditButton).isEditing = self.modeEdit
        (sender as! MZEditButton).resignFirstResponder()
        self.delegate?.didChangeEditingState(self.modeEdit)
    }
    
    @IBAction func didTapDob(_ sender: AnyObject) {
        self.editView?.invertDobPickerVisibility()
        self.delegate?.didOpenDobDatePicker(self.editView?.dobDatePickerHeight.constant != 0.0)
    }
    
    @IBAction func datePickerDidChangeValue(_ sender: AnyObject) {
        let components: DateComponents = (Calendar.current as NSCalendar).components([.year, .month, .day], from: (sender as! UIDatePicker).date)
        self.editView?.dayLabel.text = "\(components.day)"
        self.editView?.monthLabel.text = "\(components.month)"
        self.editView?.yearLabel.text = "\(components.year)"
        self.delegate?.didSelectDobDate((sender as! UIDatePicker).date)
    }
    
    @IBAction func didChangeGender(_ sender: AnyObject) {
        if !((sender as! UIGestureRecognizer).view as! MZRadioItemView).isSelected {
            if ((sender as! UIGestureRecognizer).view as! MZRadioItemView).tag == 100 {
                self.selectedGender = Gender.Male
                self.editView?.maleRadioItem.isSelected = true
                self.editView?.femaleRadioItem.isSelected = false
            } else {
                self.selectedGender = Gender.Female
                self.editView?.maleRadioItem.isSelected = false
                self.editView?.femaleRadioItem.isSelected = true
            }
            self.delegate?.didSelectGender(self.selectedGender!)
        }
    }

}
