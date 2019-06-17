//
//  MZLoadingTopRightViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/02/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZLoadingTopRightViewController : UIViewController
{

	@IBOutlet weak var uiActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var uiLbSideDescription: UILabel!
	@IBOutlet weak var uiLbTopDescription: UILabel!
	
	func updateLoader(_ container: UIView, enabled: Bool, sideDescription: String? = "", topDescription: String? = "")
	{
        self.view.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
		
		self.view.layer.cornerRadius = CORNER_RADIUS
		self.view.layer.masksToBounds = true
		
		if(enabled)
		{
			if(sideDescription!.isEmpty)
			{
				uiLbSideDescription.text = ""
				uiLbSideDescription.isHidden = true
			}
			else
			{
				uiLbSideDescription.text = sideDescription
				uiLbSideDescription.isHidden = false
			}
			
			if(topDescription!.isEmpty)
			{
				uiLbTopDescription.text = ""
				uiLbTopDescription.isHidden = true
			}
			else
			{
				uiLbTopDescription.text = topDescription
				uiLbTopDescription.isHidden = false
			}
			
			showLoadingView(container)
		
		}
		else
		{
			hideLoadingView()
		}
	}
	
	fileprivate func showLoadingView(_ container:UIView)
	{
		self.view.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.2)
		self.view.alpha = 0.0
		container.addSubview(self.view)
		UIView.animate(withDuration: 0.1) { () -> Void in
			self.view.alpha = 1.0
			self.uiActivityIndicator.startAnimating()
		}
	}
	
	fileprivate func hideLoadingView()
	{
		UIView.animate(withDuration: 0.1, animations: { () -> Void in
			self.view.alpha = 0.0
		})

		self.uiLbSideDescription.text = ""
		self.uiLbSideDescription.isHidden = true
		self.uiLbTopDescription.text = ""
		self.uiLbTopDescription.isHidden = true
	
		self.view.removeFromSuperview()
	}
}
