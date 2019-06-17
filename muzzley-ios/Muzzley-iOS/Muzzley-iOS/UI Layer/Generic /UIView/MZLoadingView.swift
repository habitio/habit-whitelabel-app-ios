//
//  MZLoaderViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 19/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import UIKit

class MZLoadingView: UIView
{
	
	let loading: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
	let textLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 300,height: 40))
	
	override func layoutSubviews()
	{
		self.loading.center = self.center
		
		var position = self.center
		position.y += 50
		self.textLabel.center = position
		self.textLabel.textColor = UIColor.white
		self.textLabel.font = UIFont.init(name: "SanFranciscoDisplay-Light", size: 17)
		self.textLabel.textAlignment = .center
        self.bindFrameToSuperviewBounds()
	}
	
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": self]))
    }
    
    fileprivate func showLoadingOnView(_ container:UIView)
    {
        container.addSubview(self)
        self.showLoadingView()
    }

    fileprivate func hideLoadingOnView(_ container:UIView)
    {
        self.hideLoadingView()
        self.removeFromSuperview()
    }
    
    fileprivate func showLoadingView()
	{
        self.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.2)
        self.addSubview(loading)
		self.addSubview(self.textLabel)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.alpha = 1.0
            self.loading.startAnimating()
        }) 
    }
    
    fileprivate func hideLoadingView() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.alpha = 0.0
        })
    }
    
    func updateLoadingStatus(_ isLoading : Bool, container: UIView)
    {
        if(isLoading)
        {
            self.showLoadingOnView(container)
        }
        else
        {
            self.hideLoadingOnView(container)
        }
    }
	
	func setLoadingText(_ text: String)
	{
		self.textLabel.text = text
	}
}
