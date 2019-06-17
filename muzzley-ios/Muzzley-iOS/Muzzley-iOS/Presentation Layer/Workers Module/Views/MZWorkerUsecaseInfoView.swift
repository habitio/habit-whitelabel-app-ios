//
//  MZWorkerUsecaseInfoViewDelegate.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 28/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit


class MZWorkerUsecaseInfoView: MZInfoView
{
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var txtInfo: UITextView?
    @IBOutlet weak var lbFooter: UILabel!
    
     var workerVM: MZWorkerViewModel?
	
    func setViewModel(_ workerVM: MZWorkerViewModel)
    {
        self.workerVM = workerVM
        
        self.lbTitle?.text = workerVM.category.uppercased()
        self.lbTitle?.textColor = workerVM.categoryColor
        self.lbSubtitle?.text = workerVM.devicesText
        self.txtInfo?.text = workerVM.desc
        self.lbFooter?.text = NSLocalizedString("mobile_footer_usecase", comment: "")
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.lbTitle?.font = UIFont.boldFontOfSize(11)
        self.lbSubtitle?.font = UIFont.boldFontOfSize(15)
        self.lbSubtitle?.textColor = UIColor.black
        
        self.txtInfo?.font = UIFont.regularFontOfSize(15)
        self.txtInfo?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        
        self.lbFooter?.font = UIFont.italicFontOfSize(14)
        self.lbFooter?.textColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)
        
        let btExit = MZColorButton(frame: CGRect(x: 0,y: 0,width: 0,height: 40))
        btExit.titleLabel?.font = UIFont.heavyFontOfSize(12)
        btExit.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1.0), for: .normal)
        btExit.setTitle(NSLocalizedString("mobile_got_it", comment: "").uppercased(), for: .normal)
        btExit.contentEdgeInsets = UIEdgeInsetsMake(16,16,16,16)
        btExit.defaultBackgroundColor = UIColor.clear
        btExit.highlightBackgroundColor = UIColor.clear
        btExit.cornerRadiusScale = 0
        btExit.addTarget(self, action: #selector(self.didTapButton(_:)), for: UIControlEvents.touchUpInside)
        
        self.stButtons?.addArrangedSubview(btExit)
    }
    
    
    func didTapButton(_ sender : UIButton)
    {
        self.delegate?.didTapHide?()
		UIView.animate(withDuration: 0.3, animations: {
			self.alpha = 0
			}, completion: {(complete: Bool) in
				self.removeFromSuperview()
		})
    }
}
