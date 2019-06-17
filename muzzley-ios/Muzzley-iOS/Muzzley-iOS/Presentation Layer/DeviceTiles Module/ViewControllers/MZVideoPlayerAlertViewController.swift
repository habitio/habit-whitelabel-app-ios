//
//  MZVideoPlayerAlertViewController
//  Muzzley-iOS
//
//  Created by Ana Figueira on 06/02/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

class MZVideoPlayerAlertViewController : UIViewController
{
	@IBOutlet weak var uiAlertImage: UIImageView!
	
	@IBOutlet weak var uiAlertMessage: UILabel!
	
	func updateAlertStatus(_ showAlert : Bool, container: UIView, alertMessage: String)
	{
		if(showAlert)
		{
			self.showAlertOnView(container, errorMessage: alertMessage)
		}
		else
		{
			self.hideAlertOnView(container)
		}
	}
	
	fileprivate func showAlertOnView(_ container : UIView, errorMessage : String)
	{
		self.view.frame = container.frame
		self.view.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.8)
		self.uiAlertImage.image = UIImage(named: "icon_no_video")
		self.uiAlertMessage.textColor = UIColor.white
		self.uiAlertMessage.font = UIFont.init(name: "SanFranciscoDisplay-Light", size: 17)
		self.uiAlertMessage.text = errorMessage
		container.addSubview(self.view)

		UIView.animate(withDuration: 0.1) { () -> Void in
			self.view.alpha = 1.0
		}
	}
	
	fileprivate func hideAlertOnView(_ container:UIView)
	{
		UIView.animate(withDuration: 0.1, animations: { () -> Void in
			self.view.alpha = 0.0
		})
		self.uiAlertMessage.text = ""
		self.view.removeFromSuperview()
	}
}
