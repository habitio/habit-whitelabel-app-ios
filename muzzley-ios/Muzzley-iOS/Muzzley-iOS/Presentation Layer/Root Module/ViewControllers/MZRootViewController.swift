//
//  MZRootViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 06/06/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit


@objc protocol MZRootCardsViewControllerDelegate : NSObjectProtocol
{
	func cardsTabVisibleStatusUpdate(_ isVisible:Bool)
    func cardsTabDoubleTapped()
}

@objc protocol MZRootWorkersViewControllerDelegate : NSObjectProtocol
{
	func workersTabVisibleStatusUpdate(_ isVisible:Bool)
    func workersTabDoubleTapped()
}

@objc protocol MZRootTilesViewControllerDelegate : NSObjectProtocol
{
	func tilesTabVisibleStatusUpdate(_ isVisible:Bool)
    func tilesTabDoubleTapped()
    func selectTab(tab: String)
}

@objc protocol MZRootUserProfileViewControllerDelegate : NSObjectProtocol
{
	func userProfileTabVisibleStatusUpdate(_ isVisible:Bool)
}

class MZRootViewController: BaseViewController, MZTabBarDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VLCMediaPlayerDelegate, MZCardsTabViewControllerDelegate
{
  
	@IBOutlet weak var tabBar: MZTabBar!
	@IBOutlet weak var imageBeta: UIImageView!
	@IBOutlet weak var contentScrollView: UICollectionView!
	//@IBOutlet var screenTopMarginConstraint: [NSLayoutConstraint]!

	var wireframe : MZRootWireframe?
	var interactor: MZRootInteractor?
	var timelineTabBarItem : MZTabBarItem?
	var workersTabBarItem : MZTabBarItem?
	var tilesTabBarItem : MZTabBarItem?
	var userProfileTabBarItem : MZTabBarItem?
	
    var player : VLCMediaPlayer?

	var alertView : UIAlertView?
	
	var previouslyReachable : Bool = false
	var firstLayoutPass : Bool = true
	var tabsOrder : NSMutableArray = []
	
	
	var cardsDelegate : MZRootCardsViewControllerDelegate?
	var workersDelegate : MZRootWorkersViewControllerDelegate?
	var tilesDelegate : MZRootTilesViewControllerDelegate?
	var userProfileDelegate : MZRootUserProfileViewControllerDelegate?
	
	enum MZTabType : Int
	{
		case cardsTab
		case workersTab
		case tilesTab
		case profileTab
	}
	
	convenience init(rootInteractor: MZRootInteractor, wireframe: MZRootWireframe)
	{
		self.init()
		self.wireframe = wireframe
		self.interactor = rootInteractor
		let cardsEnabled = MZThemeManager.sharedInstance.features.cards
		
		if(cardsEnabled)
		{
            self.tabsOrder = NSMutableArray(array: [MZTabType.cardsTab.rawValue, MZTabType.workersTab.rawValue, MZTabType.tilesTab.rawValue, MZTabType.profileTab.rawValue])
		}
		else
		{
            self.tabsOrder = NSMutableArray(array: [MZTabType.workersTab.rawValue, MZTabType.tilesTab.rawValue, MZTabType.profileTab.rawValue])
		}
		NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "RefreshAllTabs"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showServicesTab), name: NSNotification.Name(rawValue: "ShowServicesTab"), object: nil)

        self.startReachabilityObserver()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		
		self.contentScrollView = nil
	}
	
	override func viewDidAppear(_ animated: Bool)
    {
		super.viewDidAppear(animated)
		
		if(self.tabBar.selectedItem != nil && self.tabBar.selectedItem.index >= 0)
		{
			self.tabDisplayedEvent(Int(self.tabBar.selectedItem.index))
			self.slideToItem(self.tabBar.selectedItem, animated: false)
		}
	}
	
    func showServicesTab()
    {
        if(self.tabBar != nil)
        {
            self.tilesDelegate?.selectTab(tab: "services")
        }
    }
    override func reloadData()
    {
		if(self.tabBar != nil)
		{
			self.tabBar.showItems(animated: true)
		}
		self.reloadSubModulesData()
	}
    
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(receiveBackgroundAudioOnNotification), name: NSNotification.Name(rawValue: "StartBackgroundAudioStream"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(receiveBackgroundAudioOffNotification), name: NSNotification.Name(rawValue: "StopBackgroundAudioStream"), object: nil)
		self.setupInterface()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		self.transitionCoordinator?.animate(alongsideTransition: { (context) in
			
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MZThemeManager.sharedInstance.colors.primaryColorText]
			self.navigationController?.navigationBar.tintColor = MZThemeManager.sharedInstance.colors.primaryColorText
			self.navigationController?.navigationBar.barTintColor = MZThemeManager.sharedInstance.colors.primaryColor
			self.navigationController?.navigationBar.backgroundColor = MZThemeManager.sharedInstance.colors.primaryColor
			
			}, completion: { (context) in
		})
		
		
		if(self.tabsOrder.contains(MZTabType.cardsTab.rawValue))
		{
			if(self.wireframe!.cardsTabViewController != nil)
			{
				self.wireframe!.cardsTabViewController.viewWillAppear(animated)
			}
		}
        
		if(self.tabsOrder.contains(MZTabType.workersTab.rawValue))
		{
			if(self.wireframe!.workersViewController != nil)
			{
				self.wireframe!.workersViewController.viewWillAppear(animated)
			}
		}
        
		if(self.tabsOrder.contains(MZTabType.tilesTab.rawValue))
		{
			if(self.wireframe != nil)
			{
				if(self.wireframe!.tilesViewController != nil)
				{
					self.wireframe!.tilesViewController.viewWillAppear(animated)
				}
			}
		}
        
		if(self.tabsOrder.contains(MZTabType.profileTab.rawValue))
		{
			if(self.wireframe!.userProfileViewController != nil)
			{
				self.wireframe!.userProfileViewController.viewWillAppear(animated)
			}
		}
	}
	
    func cardsOnboardingShown() {
        if tabsOrder.contains(MZTabType.tilesTab.rawValue)
        {
            self.scrollToTab(.tilesTab, animated: true)
        }
    }
    
	func receiveBackgroundAudioOnNotification(_ notification: Notification)
	{
        let streamUrl = notification.object as! String
        self.startBackgroundAudioPlayer(streamUrl)
	}

	func receiveBackgroundAudioOffNotification(_ notification: Notification)
	{
        self.stopBackgroundAudioPlayer()
	}
	
	
	func numberOfSections(in collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return self.tabsOrder.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
		cell.backgroundColor = UIColor.clear
		
		for subview in cell.contentView.subviews
		{
			subview.removeFromSuperview()
		}
		
		var subModuleView = UIView()
		let index = indexPath.item
		let tab : Int = Int(self.tabsOrder[index] as! NSNumber)
		
		switch tab
		{
			case MZTabType.cardsTab.rawValue:
				subModuleView = self.wireframe!.cardsTabViewController.view
				break
			
			case MZTabType.workersTab.rawValue:
				subModuleView = self.wireframe!.workersViewController.view
				break
			
			case MZTabType.tilesTab.rawValue:
				if(self.wireframe!.tilesViewController != nil)
				{
					subModuleView = self.wireframe!.tilesViewController.view
				}
				break
				
			case MZTabType.profileTab.rawValue:
				subModuleView = self.wireframe!.userProfileViewController.view
				break
				
			default:
				break
		}
		
		subModuleView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.tabBar.frame.height - UIApplication.shared.statusBarFrame.height)
		cell.contentView.addSubview(subModuleView)
		
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		return collectionView.bounds.size
	}
	
	func handleRemoteNotificationSelection()
	{
		self.wireframe!.showRemoteNotificationScreenIfNeeded()
	}
	
	func setupInterface()
	{
		self.edgesForExtendedLayout = []
		self.previouslyReachable = true
		self.firstLayoutPass = true
		
		self.view.backgroundColor = MZThemeManager.sharedInstance.colors.primaryColor
		self.tabBar.barTintColor = MZThemeManager.sharedInstance.colors.primaryColor
		self.tabBar.tintColor = MZThemeManager.sharedInstance.colors.primaryColorText
		
		self.tabBar.delegate = self
		self.tabBar.frame = CGRect(x: self.tabBar.frame.origin.x, y: self.tabBar.frame.origin.y, width: UIScreen.main.bounds.width, height: self.tabBar.frame.height)
        
        var iconTimeline = UIImage(named: "IconTimeline")!.withRenderingMode(.alwaysTemplate)
        
        if MZThemeManager.sharedInstance.appInfo.namespace == "allianz.smarthome"
        {
            iconTimeline = UIImage(named: "IconTimelineAllianz")!.withRenderingMode(.alwaysTemplate)
        }
	
		let iconWorkers = UIImage(named: "IconWorkers")!.withRenderingMode(.alwaysTemplate)
		let iconDevices = UIImage(named: "IconDevices")!.withRenderingMode(.alwaysTemplate)
		let iconProfile = UIImage(named: "IconProfile")!.withRenderingMode(.alwaysTemplate)
		
		self.timelineTabBarItem = MZTabBarItem()
		self.workersTabBarItem = MZTabBarItem()
		self.tilesTabBarItem = MZTabBarItem()
		self.userProfileTabBarItem = MZTabBarItem()

		var arrayTabs = [MZTabBarItem]()
		
		if(tabsOrder.contains(MZTabType.cardsTab.rawValue))
		{
			self.timelineTabBarItem!.setImage(iconTimeline, for: .normal)
			self.timelineTabBarItem!.setImage(iconTimeline, for: .selected)
            self.timelineTabBarItem?.tintColor = UIColor.purple
			self.timelineTabBarItem!.index = Int32(self.tabsOrder.index(of: MZTabType.cardsTab.rawValue))
			self.tilesTabBarItem?.isSelected = false
			self.tilesTabBarItem?.isHighlighted = false

			arrayTabs.append(self.timelineTabBarItem!)
		}
		
		if(tabsOrder.contains(MZTabType.workersTab.rawValue))
		{
			self.workersTabBarItem!.setImage(iconWorkers, for: .normal)
			self.workersTabBarItem!.setImage(iconWorkers, for: .selected)
			self.workersTabBarItem!.index = Int32(self.tabsOrder.index(of: MZTabType.workersTab.rawValue))
			self.tilesTabBarItem?.isSelected = false
			self.tilesTabBarItem?.isHighlighted = false

			arrayTabs.append(self.workersTabBarItem!)
		}
		
		if(tabsOrder.contains(MZTabType.tilesTab.rawValue))
		{
			self.tilesTabBarItem!.setImage(iconDevices, for: .normal)
			self.tilesTabBarItem!.setImage(iconDevices, for: .selected)
			self.tilesTabBarItem!.index = Int32(self.tabsOrder.index(of: MZTabType.tilesTab.rawValue))
			self.tilesTabBarItem?.isSelected = false
			self.tilesTabBarItem?.isHighlighted = false

			arrayTabs.append(self.tilesTabBarItem!)
		}
		
		if(tabsOrder.contains(MZTabType.profileTab.rawValue))
		{
			self.userProfileTabBarItem!.setImage(iconProfile, for: .normal)
			self.userProfileTabBarItem!.setImage(iconProfile, for: .selected)
			self.userProfileTabBarItem!.index = Int32(self.tabsOrder.index(of: MZTabType.profileTab.rawValue))
			self.tilesTabBarItem?.isSelected = false
			self.tilesTabBarItem?.isHighlighted = false
			arrayTabs.append(self.userProfileTabBarItem!)
		}
		
		self.tabBar.hideItems(animated: false)
		self.tabBar.addItems(arrayTabs)

		if(self.tabsOrder.contains(MZTabType.cardsTab.rawValue))
		{
			let index = self.tabsOrder.index(of: MZTabType.cardsTab.rawValue)
			self.tabBar.selectedItem = tabBar.items[index] as! MZTabBarItem
		}
		else
		{
			if(self.tabsOrder.contains(MZTabType.tilesTab.rawValue))
			{
				let index = self.tabsOrder.index(of: MZTabType.tilesTab.rawValue)
				self.tabBar.selectedItem = tabBar.items[index] as! MZTabBarItem
			}
			else
			{
				self.tabBar.selectedItem = tabBar.items.first! as! MZTabBarItem
			}
		}
		
		self.contentScrollView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        self.contentScrollView.backgroundColor = MZThemeManager.sharedInstance.colors.primaryColor
		self.contentScrollView.delegate = self
		self.contentScrollView.dataSource = self
		self.contentScrollView.allowsSelection = false
		
//        var isRunningTestFlightBeta = false
//        if(Bundle.main .appStoreReceiptURL != nil)
//        {
//            isRunningTestFlightBeta = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
//        }
		
		self.imageBeta.isHidden = true //!isRunningTestFlightBeta
	}
	
	func reloadSubModulesData()
	{
        if(self.wireframe != nil)
        {
            if(self.wireframe!.cardsTabViewController != nil)
            {
                self.wireframe!.cardsTabViewController.reloadData()
            }
            if(self.wireframe!.workersViewController != nil)
            {
                self.wireframe!.workersViewController.reloadData()
            }
            
            if(self.wireframe!.tilesViewController != nil)
            {
                if(self.wireframe!.tilesViewController.devicesViewController != nil)
                    {
                        self.wireframe!.tilesViewController.devicesViewController!.reloadData()
                }
                if(self.wireframe!.tilesViewController.servicesViewController != nil)
                {
                    self.wireframe!.tilesViewController.servicesViewController?.reloadData()
                }
            }
            
		self.wireframe!.userProfileViewController.reloadData()
        }
        
		
	}
	
    
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.tabBar.handleScroll(scrollView)
	}
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.tabBar.handleScroll(scrollView)
        let contentWidth = scrollView.contentSize.width
        let itemsCount = self.tabBar.items.count
        
        let itemWidth = Int(contentWidth) / itemsCount
        let currentIndex = Int(Int(scrollView.contentOffset.x) / itemWidth)
        
        self.tabBar.selectedItem = self.tabBar.items[currentIndex] as! MZTabBarItem
        self.sendAnalyticsNavigateTo(currentIndex)
        self.tabDisplayedEvent(currentIndex)
    }
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		self.tabBar.handleScroll(scrollView)
		let contentWidth = scrollView.contentSize.width
		let itemsCount = self.tabBar.items.count

		let itemWidth = Int(contentWidth) / itemsCount
		let currentIndex = Int(Int(scrollView.contentOffset.x) / itemWidth)
		
		self.tabBar.selectedItem = self.tabBar.items[currentIndex] as! MZTabBarItem
		self.sendAnalyticsNavigateTo(currentIndex)
		self.tabDisplayedEvent(currentIndex)
	}
	
	func startReachabilityObserver()
	{
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange), name: NSNotification.Name.reachabilityChanged, object: nil)
	}
	
	
	func reachabilityDidChange(_ notification: Notification)
	{
        MZContextManager.shared.sendWifiInfo(unknownStart: false) { (error) in
        }
        
		let reachability = notification.object as? Reachability
		if(reachability!.currentReachabilityStatus() == ReachableViaWiFi || reachability!.currentReachabilityStatus() == ReachableViaWWAN)
		{
			if(!self.previouslyReachable)
			{
				self.reloadSubModulesData()
				self.previouslyReachable = true
			}
		}
		else
		{
			self.previouslyReachable = false
		}
	}
	
	func tabBar(_ tabBar: MZTabBar!, didSelect item: MZTabBarItem!)
    {
		self.slideToItem(item, animated: false)
	}
	

    func tabBar(_ tabBar: MZTabBar!, didDoubleTap item: MZTabBarItem!)
    {
        let itemIndex : Int = Int((self.tabBar.items as! NSArray).index(of: item))
        
        var tabSelected = -1
        
        if(itemIndex != -1)
        {
            tabSelected = self.tabsOrder[itemIndex] as! Int
        }
        
        switch(tabSelected)
        {
            case MZTabType.cardsTab.rawValue:
                if(self.cardsDelegate != nil)
                {
                    self.cardsDelegate?.cardsTabDoubleTapped()
                }
            break
            
        case MZTabType.workersTab.rawValue:
            if(self.workersDelegate != nil)
            {
                self.workersDelegate?.workersTabDoubleTapped()
            }
            break
            
        case MZTabType.tilesTab.rawValue:
            if(self.tilesDelegate != nil)
            {
                self.tilesDelegate?.tilesTabDoubleTapped()
            }
            break
            
            default:
            break
        }
    }
    
	func slideToItem(_ item : MZTabBarItem, animated: Bool)
	{
		let itemIndex : Int = Int((self.tabBar.items as! NSArray).index(of: item))
        self.tabBar.selectedItem = item
		self.contentScrollView.scrollToItem(at: IndexPath(item: itemIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: animated)
		self.sendAnalyticsNavigateTo(itemIndex)
        self.tabDisplayedEvent(itemIndex)

	}
	

	func scrollToTab(_ tab: MZTabType, animated: Bool)
	{
		let index = tabsOrder.index(of: tab.rawValue)
		var newIndex = index
		if(newIndex >= self.tabBar.items.count)
		{
			newIndex = self.tabBar.items.count - 1
		}
		
		self.slideToItem(self.tabBar.items[newIndex] as! MZTabBarItem, animated: animated)
	}
	
    func scrollToItemIndex(_ index: Int, animated: Bool)
	{
		var newIndex = index
		if(newIndex >= self.tabBar.items.count)
		{
			newIndex = self.tabBar.items.count - 1
		}
		self.slideToItem(self.tabBar.items[newIndex] as! MZTabBarItem, animated: animated)
	}
	
	func tabDisplayedEvent(_ itemIndex : Int)
	{
		var tabSelected = -1
		
		if(itemIndex != -1)
		{
			tabSelected = self.tabsOrder[itemIndex] as! Int
		}
		
		switch(tabSelected)
		{
			case MZTabType.cardsTab.rawValue:
				if(self.cardsDelegate != nil)
				{
					self.cardsDelegate?.cardsTabVisibleStatusUpdate(true)
					if(self.workersDelegate != nil) { self.workersDelegate?.workersTabVisibleStatusUpdate(false) }
					if(self.tilesDelegate != nil) { self.tilesDelegate?.tilesTabVisibleStatusUpdate(false)}
					if(self.userProfileDelegate != nil) { self.userProfileDelegate?.userProfileTabVisibleStatusUpdate(false)}
				}
				
				break
			
			case MZTabType.workersTab.rawValue:
				if(self.workersDelegate != nil)
				{
					self.workersDelegate?.workersTabVisibleStatusUpdate(true)
					if(self.cardsDelegate != nil) { self.cardsDelegate?.cardsTabVisibleStatusUpdate(false) }
					if(self.tilesDelegate != nil) { self.tilesDelegate?.tilesTabVisibleStatusUpdate(false)}
					if(self.userProfileDelegate != nil) { self.userProfileDelegate?.userProfileTabVisibleStatusUpdate(false)}
				}
				break

			case MZTabType.tilesTab.rawValue:
				if(self.tilesDelegate != nil)
				{
					self.tilesDelegate?.tilesTabVisibleStatusUpdate(true)
					if(self.cardsDelegate != nil) { self.cardsDelegate?.cardsTabVisibleStatusUpdate(false) }
					if(self.workersDelegate != nil) { self.workersDelegate?.workersTabVisibleStatusUpdate(false)}
					if(self.userProfileDelegate != nil) { self.userProfileDelegate?.userProfileTabVisibleStatusUpdate(false)}
				}
				break
			
			case MZTabType.profileTab.rawValue:
				if(self.userProfileDelegate != nil)
				{
					self.userProfileDelegate?.userProfileTabVisibleStatusUpdate(true)
					if(self.cardsDelegate != nil) { self.cardsDelegate?.cardsTabVisibleStatusUpdate(false) }
					if(self.workersDelegate != nil) { self.workersDelegate?.workersTabVisibleStatusUpdate(false)}
					if(self.tilesDelegate != nil) { self.tilesDelegate?.tilesTabVisibleStatusUpdate(false)}
				}
				break
		
			default:
				
				if(self.cardsDelegate != nil) { self.cardsDelegate?.cardsTabVisibleStatusUpdate(false) }
				if(self.workersDelegate != nil) { self.workersDelegate?.workersTabVisibleStatusUpdate(false)}
				if(self.tilesDelegate != nil) { self.tilesDelegate?.tilesTabVisibleStatusUpdate(false)}
				if(self.userProfileDelegate != nil) { self.userProfileDelegate?.userProfileTabVisibleStatusUpdate(false)}
				break
		}
	}
	
	func presentNetworkUnavailableAlert()
	{
		self.alertView = UIAlertView(title: NSLocalizedString("mobile_no_internet_title", comment: ""), message: NSLocalizedString("mobile_no_internet_text", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: ""), otherButtonTitles: "", "")
		self.alertView!.alertViewStyle = UIAlertViewStyle.default
		self.alertView!.show()
	}
	
	func sendAnalyticsNavigateTo(_ itemIndex: Int)
	{
		switch (itemIndex)
		{
			case 0:
				MZAnalyticsInteractor.navigateToEvent("Suggestions")
				break
			case 1:
				MZAnalyticsInteractor.navigateToEvent("Routines")
				break
			case 2:
				MZAnalyticsInteractor.navigateToEvent("Devices")
				break
			case 3:
				MZAnalyticsInteractor.navigateToEvent("User Profile")
				break
			default:
				break;
		}
	}

	
	func startBackgroundAudioPlayer(_ streamUrl: String)
	{
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch
        {
//            dLog(message: "Error setting category! " + (error as NSError).localizedDescription)
        }

        do
        {
            try AVAudioSession.sharedInstance().setActive(true)
            self.stopBackgroundAudioPlayer()

            if(self.player == nil)
            {
                player = VLCMediaPlayer()
                player!.delegate = self
                player!.media = VLCMedia(url: URL(string: streamUrl)!)
                player!.play()

            }
        }
        catch
        {
//            dLog(message: "Could not activate audio session. " + (error as NSError).localizedDescription);
        }
		
	}
	
	func stopBackgroundAudioPlayer()
	{
        if(self.player != nil)
        {
            self.player?.stop()
            self.player = nil
        }
	}
}


