//
//  MZAddTilesViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 04/10/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol MZAddTilesViewControllerDelegate: NSObjectProtocol
{
    func addChannelFlowControllerDidCancelFlow()
    func addChannelFlowControllerDidAddChannel()
    func addChannelFlowControllerDidAbortWithAuthenticationRequired()
}


class MZAddTilesViewController : BaseViewController, MZAddServicesInteractorDelegate, MZFlowControllerAddDeviceDelegate 
{
	fileprivate var loadingView = MZLoadingView()
    
//    var flowAddDevice : MZFlowControllerChannelAdd!
	var flowAddDevice : MZFlowControllerAddDevice!
    var flowAddBundle : MZFlowControllerAddService!
    var flowAddService: MZFlowControllerAddService!

    var delegate: MZAddTilesViewControllerDelegate?
	var responsesCount = 0
	var responsesRequired = 3
	
	var initialSelectedTileType = "none"
	
	var interactor : MZAddServicesInteractor?
	
	@IBOutlet weak var uiSegmentedControl: UISegmentedControl!
	
	@IBOutlet weak var uiDevicesView: UIView!
	
	@IBOutlet weak var uiBundlesView: UIView!
	
	@IBOutlet weak var uiServicesView: UIView!
	
	@IBOutlet weak var uiErrorView: UIView!
	
	@IBOutlet weak var uiLoadingView: UIView!
	
	@IBOutlet weak var uiBtTryAgain: MZColorButton!
	
	@IBOutlet weak var uiLbTryAgain: UILabel!
	
	
	@IBAction func uiBtTryAgain_TouchUpInside(_ sender: AnyObject)
	{
		self.responsesCount = 0
		self.uiLoadingView.isHidden = false
		self.flowAddDevice = MZFlowControllerAddDevice()
		self.flowAddDevice.delegate = self

		self.fetchBundlesAndServices()

	}
	
	@IBAction func uiSegmentedControl_valueChanged(_ sender: AnyObject)
	{
		switch((sender as! UISegmentedControl).selectedSegmentIndex)
		{
			case 0:
				uiDevicesView.isHidden = false
				uiBundlesView.isHidden = true
				uiServicesView.isHidden = true
				break
			
			case 1:
				uiDevicesView.isHidden = true
				
				if(self.flowAddBundle.servicesVC?.services.count > 0)
				{
					uiBundlesView.isHidden = false
					uiServicesView.isHidden = true
				}
				else
				{
					uiBundlesView.isHidden = true
					uiServicesView.isHidden = false
				}
				
				break
			
			case 2:
				uiDevicesView.isHidden = true
				uiBundlesView.isHidden = true
				uiServicesView.isHidden = false
				break
	
			default:
				break
		}
	}
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupInterface()
    }
	
	func updateResponses()
	{
		self.responsesCount += 1
		if(self.responsesCount == self.responsesRequired)
		{
			self.showDevicesAndServices()
		}
	}

	fileprivate func setupInterface()
	{
		self.responsesCount = 0
		
		self.interactor = MZAddServicesInteractor()
		self.interactor?.delegate = self
		self.loadingView.updateLoadingStatus(true, container: self.uiLoadingView)
		
		self.uiErrorView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiLbTryAgain.text = NSLocalizedString("mobile_error_text", comment: "")
		self.uiLbTryAgain.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
		self.uiBtTryAgain.setTitle(NSLocalizedString("mobile_retry", comment: ""), for: .normal)
		
		self.uiBundlesView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiDevicesView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiServicesView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		
		self.title = NSLocalizedString("mobile_add_devices_services_title", comment: "")

        self.uiErrorView.isHidden = true

		self.flowAddDevice = MZFlowControllerAddDevice()
		self.flowAddDevice.delegate = self
		
		self.flowAddBundle = MZFlowControllerAddService()
        self.flowAddBundle.isService = false
		self.addChildViewController(self.flowAddBundle.viewController!)
		self.flowAddBundle.servicesVC!.view.frame = CGRect(x: 0, y: 0, width: uiBundlesView.frame.width , height: uiBundlesView.frame.height)
		self.uiBundlesView.addSubview(self.flowAddBundle.servicesVC!.view)
		
		self.flowAddService = MZFlowControllerAddService()
		self.addChildViewController(self.flowAddService.viewController!)
		self.flowAddService.servicesVC!.view.frame = CGRect(x: 0, y: 0, width: uiServicesView.frame.width , height: uiServicesView.frame.height)
		self.uiServicesView.addSubview(self.flowAddService.servicesVC!.view)
		
		fetchBundlesAndServices()
	}
	
	func showDevicesOnly()
	{
		let vcd = self.flowAddDevice.viewController
		self.addChildViewController(vcd!)
		vcd!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: self.view.frame.height)
		self.view.addSubview(vcd!.view)
		self.uiErrorView.isHidden = true
		self.uiLoadingView.isHidden = true
	}
	
	func showDevicesAndServices()
	{
		
		if(self.flowAddBundle.servicesVC?.services.count == 0 && self.flowAddService.servicesVC?.services.count == 0)
		{
			showDevicesOnly()
		}
		else
		{
			self.uiSegmentedControl.layer.cornerRadius = 15.0;
			self.uiSegmentedControl.layer.borderColor = UIColor.lightGray.cgColor;
			self.uiSegmentedControl.layer.borderWidth = 1.0;
            self.uiSegmentedControl.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
			self.uiSegmentedControl.layer.masksToBounds = true;
			self.uiSegmentedControl.removeAllSegments()
			self.uiSegmentedControl.insertSegment(withTitle: NSLocalizedString("mobile_devices",comment: ""), at: 0, animated: false)
			
			let vcd = self.flowAddDevice.viewController
			self.addChildViewController(vcd!)
			vcd!.view.frame = CGRect(x: 0, y: 0, width: uiDevicesView.frame.width , height: uiDevicesView.frame.height)
			self.uiDevicesView.addSubview(vcd!
				.view)
			
		
			if(self.flowAddBundle.servicesVC?.services.count > 0)
			{
				self.uiSegmentedControl.insertSegment(withTitle: NSLocalizedString("mobile_bundles",comment: ""), at: 1, animated: false)
			}
		
			if(self.flowAddService.servicesVC?.services.count > 0)
			{
				if(self.flowAddBundle.servicesVC?.services.count > 0)
				{
					self.uiSegmentedControl.insertSegment(withTitle: NSLocalizedString("mobile_services",comment: ""), at: 2, animated: false)
				}
				else
				{
					self.uiSegmentedControl.insertSegment(withTitle: NSLocalizedString("mobile_services",comment: ""), at: 1, animated: false)
				}
			}
		
			switch self.initialSelectedTileType
			{
			case "service":
				self.uiSegmentedControl.selectedSegmentIndex = 1
				self.uiSegmentedControl_valueChanged(self.uiSegmentedControl)

				break
			default:
				self.uiSegmentedControl.selectedSegmentIndex = 0

				break
			}
			
		}
		self.uiLoadingView.isHidden = true
		self.uiErrorView.isHidden = true
	}
	
	func fetchBundlesAndServices()
	{
		self.interactor!.getServices()
	}
	
	func getBundlesSuccess(_ bundles: [MZService])
	{
		self.flowAddBundle.servicesVC!.services = bundles
		self.flowAddBundle.servicesVC!.updateLoadingStatus(false)
		updateResponses()
	}
	
	func getBundlesUnsuccess()
	{
        // Commented out because the request for bundles is no longer the same as for services.
		//showError()
        updateResponses()
	}
	
	func getServicesSuccess(_ services: [MZService])
	{
		self.flowAddService.servicesVC!.services = services
		self.flowAddService.servicesVC!.updateLoadingStatus(false)
		updateResponses()
	}
	
	func getServicesUnsuccess()
	{
		showError()
        updateResponses()
	}
	
	func getChannelTemplatesFinished()
	{
		updateResponses()
	}
	
	func getChannelTemplatesFinishedWithError()
	{
		showError()
        updateResponses()
	}
	
	func showError()
	{
		self.uiErrorView.isHidden = false
		self.uiLoadingView.isHidden = true
	}
	
    func addChannelFlowControllerDidAddChannel()
    {
        self.delegate?.addChannelFlowControllerDidAddChannel()
    }
    
    func addChannelFlowControllerDidCancelFlow()
    {
        self.delegate?.addChannelFlowControllerDidCancelFlow()
    }
    
    func addChannelFlowControllerDidAbort()
    {
        self.delegate?.addChannelFlowControllerDidAbortWithAuthenticationRequired()
    }
	
}
