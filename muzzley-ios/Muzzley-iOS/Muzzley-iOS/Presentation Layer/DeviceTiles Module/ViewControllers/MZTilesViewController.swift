//
//  MZTilesViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 05/04/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit


@objc enum MZTileType : Int
{
	case device
	case service
	case none
}

@objc protocol MZTilesViewControllerDelegate: NSObjectProtocol
{
	func startAddTile(_ tileType: String)
}

class MZTilesViewController: UIViewController, MZDeviceTilesInteractorDelegate, DeviceTilesViewControllerDelegate, MZCreateGroupViewControllerDelegate, MZRootTilesViewControllerDelegate, MZServicesViewControllerDelegate
{

	fileprivate var loadingView = MZLoadingView()
	
	var devicesInteractor : MZDeviceTilesInteractor?
		
	@IBOutlet weak var uiSegmentedControl: UISegmentedControl!
		
	@IBOutlet weak var uiDevicesView: UIView!
	
	@IBOutlet weak var uiServicesView: UIView!
	
	@IBOutlet weak var uiBtAddTile: UIButton!
	
	@IBOutlet weak var uiBtCreateGroup: UIButton!
	
    @IBOutlet weak var uiAddDeviceCenterButton: MZLightBorderButton!
    
    var delegate : MZTilesViewControllerDelegate?
	
	var devicesViewController : DeviceTilesViewController?
	
	var servicesViewController : MZServicesViewController?
	
	var wireframe : DeviceTilesWireframe?
    
    var parentWireframe : MZRootWireframe?
    

    init(wireframe: DeviceTilesWireframe, parentWireframe : MZRootWireframe)
	{
		super.init(nibName: "MZTilesViewController", bundle: Bundle.main)
		self.wireframe = wireframe
		self.devicesInteractor = self.wireframe?.deviceTilesViewController.interactor
		self.devicesInteractor?.delegate = self
        self.parentWireframe = parentWireframe
    }
	
	func deviceTilesViewControllerDidSelectAddDevice(_ viewController: DeviceTilesViewController!) {
		if(self.delegate != nil)
		{
			self.delegate!.startAddTile("device")
		}
	}
	
	required init?(coder aDecoder: NSCoder)
    {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.parentWireframe?.rootViewController.tilesDelegate = self
    }
    
	func createGroupCancel()
	{
	}
	
	func createGroupSuccess()
	{
	}
	
	func tilesTabVisibleStatusUpdate(_ isVisible: Bool)
    {
		self.devicesViewController?.isDevicesViewVisible = isVisible
        if isVisible && ((self.uiAddDeviceCenterButton != nil && !self.uiAddDeviceCenterButton.isHidden) || (self.uiBtAddTile != nil && !self.uiBtAddTile.isHidden))
        {
            showOnboardings()
        }
	}
	
    func tilesTabDoubleTapped()
    {
        self.devicesViewController?.scrollToTop()
    }
    
    func selectTab(tab: String) {
        switch tab {
        case "services":
            self.uiSegmentedControl.selectedSegmentIndex = 1
            break
        default:
            self.uiSegmentedControl.selectedSegmentIndex = 0
            break
        }
        self.uiSegmentedControl_valueChanged(self.uiSegmentedControl)
    }
    
    func showOnboardings()
    {
        if self.view == nil
        {
            return
        }
        
        if self.view.window == nil
        {
            return
            
        }
        
        if(!MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_devices))
        {
            self.definesPresentationContext = true;
            
            var highlitViews = [UIView]()
            if !self.uiBtAddTile.isHidden
            {
                highlitViews.append(self.uiBtAddTile)
            }
            
            if !self.uiAddDeviceCenterButton.isHidden
            {
                highlitViews.append(self.uiAddDeviceCenterButton)
            }
            
            let onboarding = MZDevicesOnboardingViewController(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext, highlightViews: highlitViews)
            self.present(onboarding, animated: false, completion: nil)
            onboarding.show()
        
            MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_devices, shownStatus: true)
        }
    }
    
	@IBAction func uiSegmentedControl_valueChanged(_ sender: AnyObject)
	{
		switch((sender as! UISegmentedControl).selectedSegmentIndex)
		{
		case 0:
			uiDevicesView.isHidden = false
			uiServicesView.isHidden = true
			
			// Should be false but its true now because of vodafone and allianz
			uiBtCreateGroup.isHidden = true
			self.devicesViewController?.isDevicesViewVisible = true
			
//			if(self.uiSegmentedControl.selectedSegmentIndex == 0 && self.devicesViewController != nil && self.devicesViewController!.hasGroupableDevices)
//			{
//				if(!MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_createGroup))
//				{
//					self.definesPresentationContext = true;
//					
//					var highlitViews = [UIView]()
//					highlitViews.append(self.uiBtCreateGroup)
//					
//					let onboarding = MZCreateGroupOnboardingViewController(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext, highlightViews: highlitViews)
//					self.present(onboarding, animated: false, completion: nil)
//					onboarding.show()
//					MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_createGroup, shownStatus: true)
//				}
//			}
            
			break
				
			
		case 1:
			
			uiDevicesView.isHidden = true
			uiServicesView.isHidden = false
			uiBtCreateGroup.isHidden = true
			self.devicesViewController?.isDevicesViewVisible = false
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
		
	@IBAction func uiBtAddTile_TouchUpInside(_ sender: AnyObject)
	{
		if self.delegate != nil
		{
			switch uiSegmentedControl.selectedSegmentIndex
			{
			case 1:
				self.delegate?.startAddTile("service")
				break
			default:
				
				self.delegate?.startAddTile("device")
				break
			}
		}
	}

	@IBAction func uiBtCreateGroup_TouchUpInside(_ sender: AnyObject)
	{
		let createGroupVC = MZCreateGroupViewController(withWireframe: self.wireframe!, andInteractor: devicesInteractor!)
		createGroupVC.delegate = self
		self.wireframe?.parent.pushViewController(toEnd: createGroupVC, animated: true)
	}
	
	func didSelectAddService()
	{
		if(delegate != nil)
		{
			self.delegate?.startAddTile("service")
		}
	}
	
	
	fileprivate func setupInterface()
	{
		showDevicesAndServices()
		
		self.uiDevicesView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiServicesView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiBtCreateGroup.isHidden = true
		self.devicesViewController = DeviceTilesViewController(wireframe: wireframe, interactor: devicesInteractor)
		self.devicesViewController?.delegate = self
		self.devicesViewController?.view.frame = CGRect(x: 0, y: 0, width: self.uiDevicesView.frame.size.width, height: self.uiDevicesView.frame.size.height)
		self.devicesViewController?.reloadData()
		self.devicesViewController?.isDevicesViewVisible = true

		self.uiDevicesView.addSubview(self.devicesViewController!.view)
		self.uiAddDeviceCenterButton.setTitle(NSLocalizedString("mobile_device_add", comment: ""))
        self.uiAddDeviceCenterButton.setImage(UIImage(named: "IconAdd")?.withRenderingMode(.alwaysTemplate), for: .normal)

        self.uiBtAddTile.setImage(UIImage(named: "IconAdd")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
		self.servicesViewController = MZServicesViewController()
		self.servicesViewController!.delegate = self
		self.servicesViewController?.view.frame = CGRect(x: 0, y: 0, width: self.uiServicesView.frame.size.width, height: self.uiServicesView.frame.size.height)
		self.uiServicesView.addSubview(self.servicesViewController!.view)


//        if(self.uiSegmentedControl.selectedSegmentIndex == 0 && self.devicesViewController != nil && self.devicesViewController!.hasGroupableDevices)
//        {
//			if(!MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_createGroup))
//			{
//				self.definesPresentationContext = true;
//			
//				var highlitViews = [UIView]()
//				highlitViews.append(self.uiBtCreateGroup)
//			
//				let onboarding = MZCreateGroupOnboardingViewController(modalPresentationStyle: UIModalPresentationStyle.OverCurrentContext, highlightViews: highlitViews)
//				self.presentViewController(onboarding, animated: false, completion: nil)
//				onboarding.show()
//				MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_createGroup, shownStatus: true)
//			}
//        }

            self.uiSegmentedControl.isHidden = true
            self.uiBtAddTile.isHidden = true
            self.uiAddDeviceCenterButton.isHidden = true
            checkForServices { (areServicesAvailable) in
                if areServicesAvailable
                {
                    self.uiBtAddTile.isHidden = false
                    self.uiSegmentedControl.isHidden = false
                    self.uiAddDeviceCenterButton.isHidden = true
                }
                else
                {
                    self.uiBtAddTile.isHidden = true
                    self.uiSegmentedControl.isHidden = true
                    self.uiAddDeviceCenterButton.isHidden = false
                }
                
                if (self.devicesViewController?.isDevicesViewVisible)! && ((self.uiAddDeviceCenterButton != nil && !self.uiAddDeviceCenterButton.isHidden) || (self.uiBtAddTile != nil && !self.uiBtAddTile.isHidden))
                {
                    self.showOnboardings()
                }
            }
	}
    
    func checkForServices(completion: @escaping (_ result: Bool) -> Void) {

        let servicesObservable = MZServicesDataManager.sharedInstance.getObservableOfAllServices()
        _ = servicesObservable.subscribe(
            onNext:{(bundlesAndServicesDic) -> Void in
                
            if let servicesJSON = bundlesAndServicesDic[MZAddServicesInteractor.key_services] as? NSArray
            {
               if servicesJSON.count > 0
               {
                    completion(true)
                    return
                }
            }
                
            completion(false)
            
             
            }, onError: { error in
                completion(false)

        })
    }
	
	func showDevicesAndServices()
	{
		self.uiSegmentedControl.layer.cornerRadius = 15.0
		self.uiSegmentedControl.layer.borderColor = UIColor.lightGray.cgColor
		self.uiSegmentedControl.layer.borderWidth = 1.0
        self.uiSegmentedControl.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
		self.uiSegmentedControl.layer.masksToBounds = true;
		self.uiSegmentedControl.removeAllSegments()
		self.uiSegmentedControl.insertSegment(withTitle: NSLocalizedString("mobile_devices",comment: ""), at: 0, animated: false)
		self.uiSegmentedControl.insertSegment(withTitle: NSLocalizedString("mobile_services",comment: ""), at: 1, animated: false)
		self.uiSegmentedControl.selectedSegmentIndex = 0
	}
	
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
