//
//  MZInfoView.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 19/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import OAStackView


@objc protocol MZInfoViewDelegate: NSObjectProtocol
{
   @objc optional func didTapHide()
}


class MZInfoView: UIView
{
    @IBOutlet weak var baseView: UIView?
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var stButtons: OAStackView?
    
    var delegate: MZInfoViewDelegate?
	
    @IBAction func btnExitTouched(_ sender: AnyObject)
    {
        hide()
    }
	
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.lbTitle?.font = UIFont.boldFontOfSize(11)
        
        self.baseView?.backgroundColor = UIColor.white
        self.baseView?.layer.cornerRadius = CORNER_RADIUS;
        self.baseView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.baseView?.layer.shadowOpacity = 0.2
        self.baseView?.layer.shadowColor = UIColor.black.cgColor
        self.baseView?.layer.shadowRadius = 1
        self.baseView?.layer.shadowPath = UIBezierPath(roundedRect: self.baseView!.bounds, cornerRadius: self.baseView!.layer.cornerRadius).cgPath
        
        self.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.6)
        
        self.stButtons?.alignment = .firstBaseline
        
        self.stButtons?.arrangedSubviews.forEach({ (arrangedSubview) in
            self.stButtons?.removeArrangedSubview(arrangedSubview)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        self.addGestureRecognizer(tap)
    }
    
    func show()
    {
        let win:UIWindow = UIApplication.shared.delegate!.window!!
        self.frame = win.bounds
        win.addSubview(self)

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) 
    }
    
    func hide()
    {
       delegate?.didTapHide?()
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            }, completion: {(complete: Bool) in
                self.removeFromSuperview()
        })
    }
}
