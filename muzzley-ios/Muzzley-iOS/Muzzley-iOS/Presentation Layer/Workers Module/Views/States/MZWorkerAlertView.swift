//
//  MZWorkerAlertView.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 15/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

protocol MZWorkerAlertViewDelegate {
    func didTapLeftButton()
    func didTapRightButton()
    func didTapCenterButton()
}

class MZWorkerAlertView : UIView {
    
    var delegate: MZWorkerAlertViewDelegate?
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var alertViewModel: MZWorkerAlertViewModel!
    
    @IBAction func didTapLeftButton () {
        delegate?.didTapLeftButton()
    }
    
    @IBAction func didTapRightButton () {
        delegate?.didTapRightButton()
    }
    
    @IBAction func didTapCenterButton () {
        delegate?.didTapCenterButton()
    }
    
    func setViewModel(_ viewModel:MZWorkerAlertViewModel)
    {
        self.alertViewModel = viewModel
        self.titleLabel.isHidden = self.alertViewModel.title.isEmpty
        self.textLabel.isHidden = self.alertViewModel.text.isEmpty
        self.leftButton.isHidden = self.alertViewModel.leftButtonTitle.isEmpty
        self.rightButton.isHidden = self.alertViewModel.rightButtonTitle.isEmpty
        self.centerButton.isHidden = self.alertViewModel.centerButtonTitle.isEmpty
        
        self.titleLabel.text = self.alertViewModel.title
        self.textLabel.text = self.alertViewModel.text
        self.leftButton.setTitle(self.alertViewModel.leftButtonTitle.uppercased(), for: UIControlState())
        self.rightButton.setTitle(self.alertViewModel.rightButtonTitle.uppercased(), for: UIControlState())
        self.centerButton.setTitle(self.alertViewModel.centerButtonTitle.uppercased(), for: UIControlState())
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.titleLabel.font = UIFont.semiboldFontOfSize(14)
        self.textLabel.font = UIFont.regularFontOfSize(14)
        
        self.leftButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
        self.rightButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
        self.centerButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
        
        self.titleLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
        self.textLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
        
        self.leftButton.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1), for: UIControlState())
        self.rightButton.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1), for: UIControlState())
        self.centerButton.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1), for: UIControlState())
        self.backgroundColor = UIColor.white
        
		self.imgView.image = UIImage(named:"icon_info")

		self.imgView.tintColor = UIColor.blue

        if self.alertViewModel.currentAlert == .invalid
        {
            self.titleLabel.textColor = UIColor.white
            self.textLabel.textColor = UIColor.white
            self.leftButton.setTitleColor(UIColor.white, for: UIControlState())
            self.rightButton.setTitleColor(UIColor.white, for: UIControlState())
            self.centerButton.setTitleColor(UIColor.white, for: UIControlState())
            self.backgroundColor = UIColor.muzzleyRed2Color(withAlpha: 1)
        } else if self.alertViewModel.currentAlert == .locationPermission
        {
            self.imgView.image = UIImage(named:"icon_location")
        } else if self.alertViewModel.currentAlert == .hardwareCapabilities
        {
            self.imgView.image = UIImage(named:"icon_constraint")
        }
        
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.95)
    }

}
