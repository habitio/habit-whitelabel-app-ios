//
//  MZCardHelpView.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 28/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZCardInfoViewDelegate: NSObjectProtocol
{
    func exitInfo()
}


class MZCardInfoView: UIView
{
    @IBOutlet weak var baseView: UIView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var txtInfo: UITextView?
    @IBOutlet weak var btnExit: MZColorButton?
    
    var card: MZCardViewModel?
    var stage: MZStageViewModel?
    var action : MZActionViewModel?

    var delegate: MZCardInfoViewDelegate?
    
    @IBAction func btnExitTouched(_ sender: AnyObject)
    {
        delegate?.exitInfo()
    }
    
    func setCardViewModel(_ viewModel: MZCardViewModel)
    {
        self.card = viewModel
        self.stage = viewModel.stages[viewModel.unfoldedStagesIndex]
        self.lblTitle?.text = self.card?.title!.uppercased()
        self.btnExit?.setTitle(NSLocalizedString("mobile_got_it", comment: "").uppercased(), for: .normal)
    }
    
    
    func setActionViewModel(_ viewModel: MZActionViewModel)
    {
        self.action = viewModel
        self.txtInfo?.text = self.action?.args.infoText
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.lblTitle?.font = UIFont.boldFontOfSize(11)
        self.lblTitle?.textColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        
        self.txtInfo?.font = UIFont.regularFontOfSize(15)
        self.txtInfo?.textColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        
        self.btnExit?.titleLabel?.font = UIFont.heavyFontOfSize(12)
        self.btnExit?.setTitleColor(UIColor.muzzleyWhiteColor(withAlpha: 1.0), for: .normal)
        self.btnExit?.contentEdgeInsets = UIEdgeInsetsMake(0,16,0,16)
        self.btnExit?.defaultBackgroundColor = UIColor.clear
        self.btnExit?.highlightBackgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0).withAlphaComponent(0.1)
        self.btnExit?.cornerRadiusScale = 0
        
        self.baseView?.backgroundColor = UIColor.muzzleyDarkGreenColor(withAlpha: 1.0)
        self.baseView?.layer.cornerRadius = CORNER_RADIUS;
//        self.baseView?.layer.masksToBounds = true;
        self.baseView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.baseView?.layer.shadowOpacity = 0.2
        self.baseView?.layer.shadowColor = UIColor.black.cgColor
        self.baseView?.layer.shadowRadius = 1
        self.baseView?.layer.shadowPath = UIBezierPath(roundedRect: self.baseView!.bounds, cornerRadius: self.baseView!.layer.cornerRadius).cgPath
    }
}
