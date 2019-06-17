//
//  MZPermissionInfoView
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 28/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit
import OAStackView
import CoreLocation


enum MZPermissionType
{
	case notifications
	case location
}

class MZPermissionInfoView: MZInfoView
{
    @IBOutlet weak var lbText: UILabel!
    @IBOutlet weak var vwSteps: OAStackView!
    
    let stepHeight: CGFloat = 30.0
	
	var _permissionType = MZPermissionType.location
	
	
	var stepsNotificationsOff = [["1-ios",NSLocalizedString("mobile_ios_notifications_permission_step1", comment: "")],
	                             ["icon_notifications",NSLocalizedString("mobile_ios_notifications_permission_step2", comment: "")],
	                             ["app_icon",String(format: NSLocalizedString("mobile_ios_notifications_permission_step3", comment: ""), MZThemeManager.sharedInstance.appInfo.applicationName)],
	                             ["4-on",NSLocalizedString("mobile_ios_notifications_permission_step4", comment: "")]]
	
	
	var stepsLocationServicesOff = [["1-ios",NSLocalizedString("mobile_ios_location_permission_step1_1", comment: "")],
	                                ["2-privacy",NSLocalizedString("mobile_ios_location_permission_step2_0", comment: "")],
	                                ["3-location",NSLocalizedString("mobile_ios_location_permission_step3_0", comment: "")],
	                                ["4-on",NSLocalizedString("mobile_ios_location_permission_step4_0", comment: "")],
	                                ["app_icon",String(format: NSLocalizedString("mobile_ios_location_permission_step5_2", comment: ""), MZThemeManager.sharedInstance.appInfo.applicationName)],
	                                
	                                ["6-check",NSLocalizedString("mobile_ios_location_permission_step6_4", comment: "")]]
	
	var stepsAppLocationServicesOff = [["1-ios",NSLocalizedString("mobile_ios_location_permission_step1_1", comment: "")],
	                                   ["app_icon",String(format: NSLocalizedString("mobile_ios_location_permission_step5_2", comment: ""), MZThemeManager.sharedInstance.appInfo.applicationName)],
	                                   ["3-location",NSLocalizedString("mobile_ios_location_permission_step0_3", comment: "")],
	                                   ["6-check",NSLocalizedString("mobile_ios_location_permission_step6_4", comment: "")]]
	
	
	open func setPermissionType(_ permissionType: MZPermissionType)
	{
		self._permissionType = permissionType
	}
    
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.lbText?.font = UIFont.regularFontOfSize(15)
		self.lbText?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
		
		self.lbTitle?.font = UIFont.boldFontOfSize(19)
		self.lbTitle?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
		self.lbTitle?.text = NSLocalizedString("mobile_permission_title", comment:"")
		
		self.vwSteps.axis = .vertical
		self.vwSteps.alignment = .leading
		self.vwSteps.distribution = .equalSpacing
		self.vwSteps.spacing = 5
		var nrSteps = 0
		
		self.vwSteps.arrangedSubviews.forEach { (view) in
			self.vwSteps.removeArrangedSubview(view)
		}
		
		
		switch _permissionType
		{
			
		case MZPermissionType.location:
			
			self.lbText?.text = NSLocalizedString("mobile_location_permission_text", comment: "")
			
			
			if !CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() != .authorizedAlways
			{
				nrSteps = self.stepsLocationServicesOff.count
				
				let stepsHeight = (stepHeight + self.vwSteps.spacing) * CGFloat(nrSteps)
				
				self.vwSteps.translatesAutoresizingMaskIntoConstraints = false
				var stepsFrame : CGRect = vwSteps.frame
				stepsFrame.size.height = stepsHeight
				vwSteps.frame = stepsFrame
				
				self.stepsLocationServicesOff.forEach { (step) in
					
					let vwStep = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: stepHeight))
                    if(step[0] != "app_icon")
                    {
                        vwStep.setImage(resizeImage(UIImage(named: step[0])!, scaledToSize: CGSize(width: 30,height: 30)), for: UIControlState())
                    }
                    else
                    {
                        vwStep.setImage(resizeImage(UIImage.appIcon!, scaledToSize: CGSize(width: 30,height: 30)), for: UIControlState())
                    }
                    vwStep.titleEdgeInsets = UIEdgeInsetsMake(0,7,0,-7)
					vwStep.setTitle(step[1], for: UIControlState())
					vwStep.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 1), for: UIControlState())
					vwStep.titleLabel?.font = UIFont.regularFontOfSize(14)
					vwStep.isUserInteractionEnabled = false
					
					vwStep.contentHorizontalAlignment = .fill
					vwStep.contentVerticalAlignment = .fill
					vwStep.imageView?.contentMode = .scaleAspectFit
					//vwStep.contentMode = .AspectFit;
					
					vwSteps.addArrangedSubview(vwStep)
				}
				
			}
			else if CLLocationManager.authorizationStatus() != .authorizedAlways
			{
				nrSteps = self.stepsAppLocationServicesOff.count
				
				let stepsHeight = (stepHeight + self.vwSteps.spacing) * CGFloat(nrSteps)
				
				self.vwSteps.translatesAutoresizingMaskIntoConstraints = false
				var stepsFrame : CGRect = vwSteps.frame
				stepsFrame.size.height = stepsHeight
				vwSteps.frame = stepsFrame
				
				self.stepsAppLocationServicesOff.forEach { (step) in
					
					let vwStep = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: stepHeight))
                    if(step[0] != "app_icon")
                    {
                        vwStep.setImage(resizeImage(UIImage(named: step[0])!, scaledToSize: CGSize(width: 30,height: 30)), for: UIControlState())
                    }
                    else
                    {
                        vwStep.setImage(resizeImage(UIImage.appIcon!, scaledToSize: CGSize(width: 30,height: 30)), for: UIControlState())
                    }
					vwStep.titleEdgeInsets = UIEdgeInsetsMake(0,7,0,-7)
					vwStep.setTitle(step[1], for: UIControlState())
					vwStep.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 1), for: UIControlState())
					vwStep.titleLabel?.font = UIFont.regularFontOfSize(14)
					vwStep.isUserInteractionEnabled = false
					
					vwSteps.addArrangedSubview(vwStep)
				}
			}
			
			break
			
		case MZPermissionType.notifications:
			self.lbText?.text = NSLocalizedString("mobile_notifications_permission_text", comment: "")
			nrSteps = self.stepsNotificationsOff.count
			
			if(self.vwSteps == nil)
			{
				//dLog(message: "nil")
			}
			let stepsHeight = (stepHeight + self.vwSteps.spacing) * CGFloat(nrSteps)
			
			self.vwSteps.translatesAutoresizingMaskIntoConstraints = false
			var stepsFrame : CGRect = vwSteps.frame
			stepsFrame.size.height = stepsHeight
			vwSteps.frame = stepsFrame
			
			self.stepsNotificationsOff.forEach { (step) in
				
				let vwStep = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: stepHeight))
				
                if(step[0] != "app_icon")
                {
                    vwStep.setImage(resizeImage(UIImage(named: step[0])!, scaledToSize: CGSize(width: 30,height: 30)), for: UIControlState())
                }
                else
                {
                    vwStep.setImage(resizeImage(UIImage.appIcon!, scaledToSize: CGSize(width: 30,height: 30)), for: UIControlState())
                }
                
				vwStep.titleEdgeInsets = UIEdgeInsetsMake(0,7,0,-7)
				vwStep.setTitle(step[1], for: UIControlState())
				vwStep.setTitleColor(UIColor.muzzleyBlackColor(withAlpha: 1), for: UIControlState())
				vwStep.titleLabel?.font = UIFont.regularFontOfSize(14)
				vwStep.isUserInteractionEnabled = false
				
				vwSteps.addArrangedSubview(vwStep)
			}
			
			break
			
		default:
			break
		}
		
		
		//let btSettings = getButton(NSLocalizedString("mobile_go_settings", comment: ""), tag: 200, font: UIFont.heavyFontOfSize(12))
		//self.stButtons?.addArrangedSubview(btSettings)
		
		let btExit = getButton(NSLocalizedString("mobile_ok", comment: ""), tag: 100, font: UIFont.regularFontOfSize(12))
		self.stButtons?.addArrangedSubview(btExit)
	}
	
	
	// TODO: Move this to somewhere more helpful so it can be used everywhere
	func resizeImage(_ image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	
    func getButton(_ title:String, tag: Int, font:UIFont) -> MZColorButton
    {
        let btn = MZColorButton(frame: CGRect(x: 0,y: 0,width: 0,height: 40))
        btn.titleLabel?.font = font
        btn.setTitleColor(UIColor.muzzleyBlueColor(withAlpha: 1.0), for: .normal)
        btn.setTitle(title.uppercased(), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsetsMake(16,16,16,16)
        btn.defaultBackgroundColor = UIColor.clear
        btn.highlightBackgroundColor = UIColor.clear
        btn.cornerRadiusScale = 0
        btn.tag = tag
        btn.addTarget(self, action: #selector(self.didTapButton(_:)), for: UIControlEvents.touchUpInside)

        return btn
    }
    
    
    func didTapButton(_ sender : UIButton)
    {
        if sender.tag == 100
        {
            self.hide()
        } else if sender.tag == 200
        {
			if let url: URL = URL(string: "prefs://") {
					if UIApplication.shared.canOpenURL(url) {
						UIApplication.shared.openURL(url)
					}
				}
            self.hide()
        }
    }
}
