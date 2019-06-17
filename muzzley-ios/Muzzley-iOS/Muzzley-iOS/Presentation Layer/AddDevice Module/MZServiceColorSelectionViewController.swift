//
//  MZServiceColorSelectionViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 13/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation


@objc protocol MZServiceColorSelectionViewControllerDelegate: NSObjectProtocol
{
	func selectColorSuccess(_ selectedChannelId: String, otherChannelId: String)
	func selectColorUnsuccess()
}


class MZServiceColorSelectionViewController : UIViewController, MZAddServicesInteractorDelegate
{
	@IBOutlet weak var uiLbTitle: UILabel!
	
	@IBOutlet weak var uiLbText: UILabel!
	@IBOutlet weak var uiBtTop: UIButton!
	
	@IBOutlet weak var uiBtBottom: UIButton!
	
	@IBOutlet weak var uiBtNext: MZColorButton!
	@IBOutlet weak var uiLbOr: UILabel!
	
	var viewModel : MZServiceColorSelectionViewModel?
	var interactor : MZAddServicesInteractor?
	var loadingView = MZLoadingView()
	var isTopSelected = false
	var isBottomSelected = false
	
	var profileId = ""
	var propertyOn = ""
	var propertyColor = "color"
	var propertyStatus = "status"
	var propertyBrightness = "brightness"
	
	var componentId = "light-bulb"
	var channelId1 = ""
	var channelId2 = ""
	var remoteId = ""

	
	var delegate : MZServiceColorSelectionViewControllerDelegate?
	
	convenience init(serviceInteractor: MZAddServicesInteractor, profile: String, channels: [String])
	{
		self.init()
		self.interactor = serviceInteractor
		self.interactor?.delegate = self
		self.profileId = profile
		self.viewModel = MZServiceColorSelectionViewModel(profile: profile, channels: channels)
		if(channels.count >= 2)
		{
			self.channelId1 = channels[0]
			self.channelId2 = channels[1]
		}
		else
		{
			self.delegate?.selectColorUnsuccess()
		}
	}
	

	
	
	override func viewWillDisappear(_ animated : Bool) {
		super.viewWillDisappear(animated)
		
		
		if (self.isMovingFromParentViewController && self.delegate != nil){
			self.delegate?.selectColorUnsuccess()
		}
	}
	

	@IBAction func uiBtNext_TouchUpInside(_ sender: AnyObject)
	{

		self.loadingView.updateLoadingStatus(true, container: self.view)

		if(isBottomSelected)
		{
			self.sendWhiteColorInstructions()
			self.delegate?.selectColorSuccess(self.channelId2, otherChannelId: self.channelId1)
			return
		}
		
		if(isTopSelected)
		{
			self.sendWhiteColorInstructions()
			self.delegate?.selectColorSuccess(self.channelId1, otherChannelId: self.channelId2)
			return
		}

		self.loadingView.updateLoadingStatus(true, container: self.view)

		self.sendColorInstructions()
		
	}
	
	
	@IBAction func uiBtTop_TouchUpInside(_ sender: AnyObject)
	{
		if isBottomSelected
		{
			isBottomSelected = false
			uiBtBottom.setBackgroundImage(UIImage(named: "red_color_light"), for: .normal)
		}
		
		if isTopSelected
		{
			isTopSelected = false
			uiBtTop.setBackgroundImage(UIImage(named: "blue_color_light"), for: .normal)
		}
		else
		{
			isTopSelected = true
			uiBtTop.setBackgroundImage(UIImage(named: "blue_color_light_selected"), for: .normal)
		}
		
		updateButtons()
	}
	
	func updateButtons()
	{
		if isTopSelected || isBottomSelected
		{
			uiBtNext.setTitle(NSLocalizedString("mobile_next", comment: ""), for: .normal)
            //TODO
			//(uiBtNext as MZColorButton).invertedButton = true
		}
		else
		{
			uiBtNext.setTitle(NSLocalizedString("mobile_send_color_instructions", comment: ""), for: .normal)
            //TODO
			//(uiBtNext as MZColorButton).invertedButton = false
		}
	}
	
	@IBAction func uiBtBottom_TouchUpInside(_ sender: AnyObject)
	{
		if isTopSelected
		{
			isTopSelected = false
			uiBtTop.setBackgroundImage(UIImage(named: "blue_color_light"), for: .normal)
		}
		
		if isBottomSelected
		{
			isBottomSelected = false
			uiBtBottom.setBackgroundImage(UIImage(named: "red_color_light"), for: .normal)
		}
		else
		{
			isBottomSelected = true
			uiBtBottom.setBackgroundImage(UIImage(named: "red_color_light_selected"), for: .normal)
		}
		
		updateButtons()
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
	
	func setupInterface()
	{
		self.loadingView.updateLoadingStatus(true, container: self.view)
		self.sendColorInstructions()
		
		isTopSelected = false
		isBottomSelected = false
		
		let barButton: UIBarButtonItem = UIBarButtonItem()
		barButton.title = ""
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
		self.navigationController?.navigationBar.topItem?.hidesBackButton = false

		
		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.navigationController?.setNavigationBarHidden(false, animated: false)
		
		self.title = NSLocalizedString("mobile_service_color_selection", comment: "")
		uiLbTitle.text = NSLocalizedString("mobile_service_color_selection_text",comment: "");
		uiLbTitle.font = UIFont.mediumFontOfSize(14)
		
		uiBtTop.layer.masksToBounds = true
		uiBtTop.setBackgroundImage(UIImage(named: "blue_color_light"), for: .normal)
		uiBtTop.setTitleColor(UIColor.white, for: .normal)
		uiBtTop.setTitle(NSLocalizedString("mobile_blue", comment: ""), for: .normal)
		uiBtTop.layoutIfNeeded()
		
		uiBtBottom.layer.masksToBounds = true
		uiBtBottom.setBackgroundImage(UIImage(named: "red_color_light"), for: .normal)
		uiBtBottom.setTitleColor(UIColor.white, for: .normal)
		uiBtBottom.setTitle(NSLocalizedString("mobile_red", comment: ""), for: .normal)
		uiBtBottom.layoutIfNeeded()
		
		uiLbOr.text = NSLocalizedString("mobile_or", comment: "")
		uiLbOr.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		
		updateButtons()
	}
	

	

	func sendColorInstructions()
	{
		
		// Send turn on instructions
		let turnOnRed = NSMutableDictionary()
		turnOnRed.addEntries(from: ["io": "w", "data": true])
		
		let turnOnBlue = NSMutableDictionary()
		turnOnBlue.addEntries(from: ["io": "w", "data": true])
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId1, componentId: self.componentId, propertyId: self.propertyStatus), jsonDict: turnOnRed, completion: { (success, error) in
		} )
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId2, componentId: self.componentId, propertyId: self.propertyStatus), jsonDict: turnOnBlue, completion: { (success, error) in
		} )

		
		// Send brightness instructions
		let brightnessRed = NSMutableDictionary()
		brightnessRed.addEntries(from: ["io": "w", "data": 1])
		
		
		let brightnessBlue = NSMutableDictionary()
		brightnessBlue.addEntries(from: ["io": "w", "data": 1])
		
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId1, componentId: self.componentId, propertyId: self.propertyBrightness), jsonDict: brightnessRed, completion: { (success, error) in
		} )
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId2, componentId: self.componentId, propertyId: self.propertyBrightness), jsonDict: brightnessBlue, completion: { (success, error) in
		} )
		
		
		// Send color instructions
		let colorBlue = NSMutableDictionary()
		colorBlue.addEntries(from: ["io": "w", "data": ["h":240, "s":100, "v":100]])
		
		
		let colorRed = NSMutableDictionary()
		colorRed.addEntries(from: ["io": "w", "data": ["h":0, "s":100, "v":100]])
		
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId1, componentId: self.componentId, propertyId: self.propertyColor), jsonDict: colorBlue, completion: { (success, error) in
		} )
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId2, componentId: self.componentId, propertyId: self.propertyColor), jsonDict: colorRed, completion: { (success, error) in
		} )
		
	
		self.loadingView.updateLoadingStatus(false, container: self.view)

	}
	
	func sendWhiteColorInstructions()
	{
		
		// Send turn on instructions
		let turnOnRed = NSMutableDictionary()
		turnOnRed.addEntries(from: ["io": "w", "data": true])
		
		let turnOnBlue = NSMutableDictionary()
		turnOnBlue.addEntries(from: ["io": "w", "data": true])
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId1, componentId: self.componentId, propertyId: self.propertyStatus), jsonDict: turnOnRed, completion: { (success, error) in
		} )
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId2, componentId: self.componentId, propertyId: self.propertyStatus), jsonDict: turnOnBlue, completion: { (success, error) in
		} )
		
		
		// Send brightness instructions
		let brightnessRed = NSMutableDictionary()
		brightnessRed.addEntries(from: ["io": "w", "data": 1])
		
		
		let brightnessBlue = NSMutableDictionary()
		brightnessBlue.addEntries(from: ["io": "w", "data": 1])
		
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId1, componentId: self.componentId, propertyId: self.propertyBrightness), jsonDict: brightnessRed, completion: { (success, error) in
		} )
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId2, componentId: self.componentId, propertyId: self.propertyBrightness), jsonDict: brightnessBlue, completion: { (success, error) in
		} )
		
		
		// Send color instructions
		let colorWhite = NSMutableDictionary()
		colorWhite.addEntries(from: ["io": "w", "data": ["h":0, "s":0, "v":100]])

		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId1, componentId: self.componentId, propertyId: self.propertyColor), jsonDict: colorWhite, completion: { (success, error) in
		} )
		
		MZMQTTConnection.sharedInstance.publish(MZTopicParser.createPublishTopic(channelId2, componentId: self.componentId, propertyId: self.propertyColor), jsonDict: colorWhite, completion: { (success, error) in
		} )
		
		
		//self.loadingView.updateLoadingStatus(false, container: self.view)
		
	}
	
	
}
