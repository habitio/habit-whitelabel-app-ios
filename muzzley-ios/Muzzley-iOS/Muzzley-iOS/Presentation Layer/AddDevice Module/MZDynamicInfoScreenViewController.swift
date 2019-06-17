
//
//  MZServiceSummaryViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 13/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation


@objc protocol MZDynamicInfoScreenViewControllerDelegate: NSObjectProtocol
{
    func didPressBackOnInfoScreen()
	func didFinishInfoScreen()
}


class MZDynamicInfoScreenViewController : UIViewController
{
    var loadingView = MZLoadingView()
	var screenInfo : MZDynamicInfoScreenViewModel?
	var delegate : MZDynamicInfoScreenViewControllerDelegate?
	
	@IBOutlet weak var uiLbTitle: UILabel!
	
	@IBOutlet weak var uiSummaryImage: UIImageView!
	
	@IBOutlet weak var uiBottomImage: UIImageView!
	
	@IBOutlet weak var uiDescription: UILabel!
	
	@IBOutlet weak var uiBtNext: UIButton!
	
    var showBackButton = false
    
	convenience init(screenInfo: MZDynamicInfoScreenViewModel)
	{
		self.init()
		self.screenInfo = screenInfo
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
	
    func back()
    {
        self.delegate?.didPressBackOnInfoScreen()
    }
	
	func setupInterface()
	{
        self.navigationItem.hidesBackButton = true
     
        if self.screenInfo!.isBackButtonEnabled
        {
            let newBackButton = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(self.back))
 
            self.navigationItem.leftBarButtonItem = newBackButton
        }
        let button = UIButton(type: .custom)
        button.tintColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        button.bounds = CGRect(x: 0, y: 0, width: 22, height: 22)
        
        button.setImage(UIImage(named: "icon_i_info"), for: UIControlState())
        
        if(self.screenInfo!.infoUrl != nil && !self.screenInfo!.infoUrl!.isEmpty)
        {
            button.addTarget(self, action: #selector(self.showInfoButtonPressedAction(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }

		self.view.backgroundColor = UIColor.white
		self.title = self.screenInfo!.navigationBarTitle
		
		self.uiBtNext.setTitle(self.screenInfo!.buttonText, for: .normal)
		
		uiLbTitle.text = self.screenInfo!.title
		uiLbTitle.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		
		uiDescription.text = self.screenInfo!.text
		uiDescription.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)

		if(self.screenInfo!.topImageUrl != nil && !self.screenInfo!.topImageUrl!.isEmpty)
		{
			uiSummaryImage.setImageWith(URL(string: (self.screenInfo!.topImageUrl!))!)
		}
        
		if(self.screenInfo!.bottomImageUrl != nil && !self.screenInfo!.bottomImageUrl!.isEmpty)
        {
			uiBottomImage.setImageWith(URL(string: self.screenInfo!.bottomImageUrl!)!)
		}
	}
    
    func showInfoButtonPressedAction(_ sender: AnyObject)
    {
        UIApplication.shared.openURL(URL(string: self.screenInfo!.infoUrl!)!)
    }
	
	@IBAction func uiBtNext_TouchUpInside(_ sender: AnyObject)
	{
        self.loadingView.updateLoadingStatus(true, container: self.view)
		self.delegate?.didFinishInfoScreen()
	}
}
