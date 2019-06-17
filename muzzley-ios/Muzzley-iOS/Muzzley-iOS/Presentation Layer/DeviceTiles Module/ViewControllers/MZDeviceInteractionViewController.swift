//
//  MZDeviceInteractionViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 07/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
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


class MZDeviceInteractionViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, MZHTMLViewControllerDelegate, MZWidgetStoreDelegate, MZVideoPlayerControllerDelegate
{



    @IBOutlet weak var webViewPlaceholder: UIView!
    @IBOutlet weak var collectionView: MZCollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var expandButtonPosition: NSLayoutConstraint!
    @IBOutlet weak var expandView: UIView!
    @IBOutlet weak var expandViewBotttom: NSLayoutConstraint!
    @IBOutlet weak var htmlContainerLabel: UILabel!
    @IBOutlet weak var nativeComponentsView: UIView!
    @IBOutlet weak var nativeComponentsViewHeight: NSLayoutConstraint!

	var cameraVC: MZVideoPlayerController?

    internal var index: Int?
    internal var tile: MZTileViewModel?
    internal var tiles: [MZTileAreaViewModel]?
    internal var groupVM: MZTileGroupViewModel?
    internal var deviceTilesDataSource: DeviceTilesDataSource!

    fileprivate enum ThingInteractionUIState: Int
	{
        case initial = 0,
        unableToLoad,
        loading,
        loaded
    }
    
    fileprivate enum NativeComponentTypes: String
	{
        case Video = "video"
    }
    
    fileprivate enum NativeComponentsActions: String
	{
//        case PlayLibraryVideo = "play_vid_library"
//        case PlayStreamVideo = "play_live_stream"
//        case LowBattery = "low_batt_notification"
//        case Recording = "recording"
//        case PauseVideo = "pause_video"
		case playVideo = "play_video"
		case audio = "audio"
		case microphone = "microphone"
		case background_audio = "background_audio"
		//case Alert = "alert"
    }

	fileprivate var videoHeight : CGFloat = 230.0
    fileprivate var wireframe: DeviceTilesWireframe!
    fileprivate var interactor: MZDeviceTilesInteractor?
    internal var timer: Timer!
    fileprivate var htmlViewController: MZHTMLViewController!
    fileprivate var widgetStore: MZWidgetStore!
    fileprivate var nativeComponents: [AnyObject] = []
    fileprivate var openExpandGradient: CAGradientLayer!
    fileprivate var closeExpandGradient: CAGradientLayer!
    fileprivate var loadingView: UIView!
	
    convenience init(withWireframe wireframe: DeviceTilesWireframe, andInteractor interactor: MZDeviceTilesInteractor) {
        self.init(nibName: "MZDeviceInteractionViewController", bundle: Bundle.main)
		
        self.wireframe = wireframe
        self.interactor = interactor
        self.widgetStore = MZWidgetStore()
		self.widgetStore.delegate = self
    }
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
        self.setupInterface()
    }
	
    override func viewWillAppear(_ animated: Bool)
	{
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.htmlViewController = MZHTMLViewController()
        self.htmlViewController.delegate = self
        self.addChildViewController(self.htmlViewController)
        self.htmlViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.htmlViewController.view.frame = CGRect(x: 0,y: 0, width: self.webViewPlaceholder.frame.width, height: self.webViewPlaceholder.frame.height)
		
		self.webViewPlaceholder.addSubview(self.htmlViewController.view)
		
        self.htmlViewController.enableActivityIndicator(true)
        
        self.fetchWidgetInterface()
        
        self.collectionView.reloadData()
        if self.collectionViewHeight.constant != 0.0
		{
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MZDeviceInteractionViewController.changeCollectionViewVisibility(_:)), userInfo: nil, repeats: false)
        }
        
        if self.tiles != nil
		{
            self.title = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!].title
        }
		else
		{
            self.title = self.tile!.title
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
	{
        super.viewWillDisappear(animated)
		
		if(cameraVC != nil)
		{
			cameraVC?.dismiss(animated: false, completion: {})
			cameraVC = nil
		}
        if self.timer != nil
		{
            self.timer.invalidate()
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    internal func setupInterface()
	{
		
		self.nativeComponentsView.backgroundColor = UIColor.black
        self.view.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "IconEdit"), style: .done, target: self, action: #selector(MZDeviceInteractionViewController.editAction(_:)))
		
        self.expandButton.isHidden = true
        self.expandView.isHidden = true
        self.expandViewBotttom.constant = -142.0
        
        if self.tiles != nil
		{
            self.expandView.backgroundColor = UIColor.clear
            
            if self.openExpandGradient == nil
			{
                self.openExpandGradient = CAGradientLayer()
                self.openExpandGradient.frame = self.expandView.bounds
                self.openExpandGradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.muzzleyGray4Color(withAlpha: 0.7).cgColor, UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor]
                self.openExpandGradient.locations = [NSNumber(value: 0.0 as Float), NSNumber(value: 1.0 - 21.0 / 34.0 as Float), NSNumber(value: 1.0 - 21.0 / 34.0 as Float), NSNumber(value: 1.0 as Float)]
                self.expandView.layer.insertSublayer(self.openExpandGradient, at: 0)
            }
            
            if self.closeExpandGradient == nil
			{
                self.closeExpandGradient = CAGradientLayer()
                self.closeExpandGradient.frame = self.expandView.bounds
                self.closeExpandGradient.colors = [UIColor.muzzleyGray4Color(withAlpha: 0.0).cgColor, UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor]
            }
            
            self.expandButton.isHidden = false
            self.expandView.isHidden = false
            self.expandViewBotttom.constant = -6.0
            self.expandButtonPosition.constant = 3.0
            
            self.expandButton.layer.shadowColor = UIColor.muzzleyGrayColor(withAlpha: 0.8).cgColor
            self.expandButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.expandButton.layer.shadowOpacity = 0.9
            self.expandButton.layer.shadowRadius = 0.0
            
            self.collectionView.backgroundView = UIView()
            let topBorder: CALayer = CALayer()
            topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.collectionView.backgroundView!.bounds.size.width, height: 4.0)
            topBorder.backgroundColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
            self.collectionView.backgroundView?.layer.addSublayer(topBorder)
            
            self.deviceTilesDataSource = DeviceTilesDataSource(collectionView: self.collectionView)
            self.collectionView.dataSource = self.deviceTilesDataSource
            self.collectionView.allowsSelection = true
            
            self.tiles?.forEach{ $0.title = "" }
            self.tiles?.forEach{ $0.tilesViewModel.forEach{ $0.isSelected = false } }
            (self.tiles?[0].tilesViewModel[0] as! GroupInteractionTileViewModel).isDetail = true
            self.deviceTilesDataSource.setData(self.tiles! as NSArray)
            self.deviceTilesDataSource.isDetail = true
            self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!].isSelected = true
        }
		else
		{
            self.collectionViewHeight.constant = 0.0
        }
        
        self.setupNativeView()
    }

	
    fileprivate func setupNativeView()
	{
        let tile: MZAreaChildViewModel
		
        if self.tiles == nil
		{
            tile = self.tile!
        }
		else
		{
            tile = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!]
        }
        
        // For testing purposes ONLY
        // Used to force to show the video component. Then need to change the use_test_stream flag in MZVideoPlayerController
//          tile.nativeComponents = [MZTileNativeComponentViewModel(withModel: MZNativeComponent(withDictionaty: ["size" : "1.3", "type":"video"]))]
        
        self.nativeComponentsViewHeight.constant = 0.0
        if tile.nativeComponents?.count > 0 {
            for (_, tileNativeComponent) in (tile.nativeComponents?.enumerated())! {
                switch tileNativeComponent.type {
                case NativeComponentTypes.Video.rawValue:
					
					self.videoHeight = UIScreen.main.bounds.width / tileNativeComponent.size
				
					self.nativeComponentsViewHeight.constant += self.videoHeight
					
                    self.nativeComponentsView.layoutIfNeeded()
                    
                    var interactor = MZCameraInteractor()
            
                    
                    cameraVC = MZVideoPlayerController(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height, width: UIScreen.main.bounds.width, height: self.videoHeight), tileVM: tile as! MZTileViewModel, interactor:interactor)

                    self.cameraVC!.componentId = tileNativeComponent.identifier as! String
                    
                    self.addChildViewController(self.cameraVC!)
                    self.nativeComponentsView.insertSubview(self.cameraVC!.view, at: 0)
                    self.cameraVC!.didMove(toParentViewController: self)
                    self.nativeComponents.append(self.cameraVC!)

                    self.nativeComponentsView.layoutIfNeeded()

                    //cameraVC.delegate = self

					break;
                    
                default: self.nativeComponentsViewHeight.constant -= tileNativeComponent.size
                }
            }
        }
    }
    
    internal func showLoadingView()
    {
        var lFrame: CGRect = self.view.frame
        lFrame.origin.x = 0.0
        lFrame.origin.y = 0.0
        self.loadingView = UIView(frame: lFrame)
        self.loadingView.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.2)
		
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        var frame: CGRect = self.loadingView.frame
        frame.origin.x = frame.size.width / 2.0 - loading.frame.size.width / 2.0
        frame.origin.y = frame.size.height / 2.0 - loading.frame.size.height / 2.0
        frame.size = loading.frame.size
        loading.frame = frame
        self.loadingView.addSubview(loading)
        self.loadingView.alpha = 0.0
        self.view.addSubview(self.loadingView)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.loadingView.alpha = 1.0
            loading.startAnimating()
        }) 
    }
    
    internal func hideLoadingView()
	{
        if self.loadingView != nil
		{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.loadingView.alpha = 0.0
                }, completion: { (success) -> Void in
                    if self.loadingView != nil
					{
                        self.loadingView.subviews.forEach{ $0.removeFromSuperview() }
                        self.loadingView.removeFromSuperview()
                        self.loadingView = nil
                    }
            })
        }
        //FIX ME patch to prevent top bar disappearing
        if self.parent != nil
		{
            self.parent?.view.bringSubview(toFront: self.view)
        }
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setUIState(_ state: ThingInteractionUIState) {
        switch state {
        case .initial:
            self.htmlViewController.view.alpha = 0.0
            self.htmlContainerLabel.text = ""
        case .loading:
            self.htmlViewController.view.alpha = 0.0
            self.htmlContainerLabel.text = ""
        case .loaded:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.htmlViewController.view.alpha = 1.0
                self.htmlContainerLabel.text = ""
                }, completion: nil)
            
        default:
            self.htmlViewController.view.alpha = 0.0
            self.htmlContainerLabel.text = "Unable to load."
        }
    }
	
    
    @IBAction func changeCollectionViewVisibility(_ sender: AnyObject)
	{
        if self.collectionViewHeight.constant == 0.0
		{
            self.expandViewBotttom.constant = -6.0
            UIView.animate(withDuration: 0.05, animations: { () -> Void in
                self.expandView.layoutIfNeeded()
            }, completion: { (success) -> Void in
                self.expandViewBotttom.constant = -38.0
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.expandView.layoutIfNeeded()
                }, completion: { (success) -> Void in
                    self.closeExpandGradient.removeFromSuperlayer()
                    self.expandView.layer.insertSublayer(self.openExpandGradient, at: 0)
                    self.expandButton.layer.shadowRadius = 0.0
                    self.expandButtonPosition.constant = 3.0
                    self.collectionViewHeight.constant = 110.0
                    self.expandViewBotttom.constant = -6.0
                    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                })
            })
        }
		else
		{
            self.collectionViewHeight.constant = 114.0
            UIView.animate(withDuration: 0.05, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (success) -> Void in
                self.collectionViewHeight.constant = 0.0
                self.expandViewBotttom.constant = -38.0
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: { (success) -> Void in
                    self.openExpandGradient.removeFromSuperlayer()
                    self.expandView.layer.insertSublayer(self.closeExpandGradient, at: 0)
                    self.expandButton.layer.shadowRadius = 3.0
                    self.expandViewBotttom.constant = -6.0
                    self.expandButtonPosition.constant = -9.0
                    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.expandView.layoutIfNeeded()
                    }, completion: nil)
                })
            })
        }
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
	{
        return CGSize(width: collectionView.bounds.size.height, height: collectionView.bounds.size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
        if self.timer != nil {
            self.timer.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MZDeviceInteractionViewController.changeCollectionViewVisibility(_:)), userInfo: nil, repeats: false)
        
        if self.index != indexPath.row {
            self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!].isSelected = false
            self.index = indexPath.row
            self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!].isSelected = true
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.title = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!].title
            self.fetchWidgetInterface()
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	{
        if self.timer != nil {
            self.timer.invalidate()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	{
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MZDeviceInteractionViewController.changeCollectionViewVisibility(_:)), userInfo: nil, repeats: false)
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func editAction(_ sender: AnyObject) {
        if self.tiles != nil {
            let tile: MZAreaChildViewModel = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!]
            if tile is MZTileViewModel {
                let settingsVC: MZDeviceSettingsViewController = MZDeviceSettingsViewController(withWireframe: self.wireframe, andInteractor: self.interactor!)
                settingsVC.groupDevicesCount = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel.count - 1
                settingsVC.groupVM = self.groupVM
                settingsVC.device = tile as? MZTileViewModel
                settingsVC.locations = [] // TODO

                self.wireframe.parent?.pushViewController(toEnd: settingsVC, animated: true)
            } else if tile is GroupInteractionTileViewModel {
                var tiles: [MZAreaChildViewModel] = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel
                tiles.removeFirst()
                
                let settingsVC: MZGroupSettingsViewController = MZGroupSettingsViewController(withWireframe: self.wireframe, andInteractor:self.interactor!)
                //TODO improve me
                settingsVC.groupVM = self.groupVM
                settingsVC.devicesInGroup = tiles

                self.wireframe.parent?.pushViewController(toEnd: settingsVC, animated: true)
            }
        } else {
            let settingsVC: MZDeviceSettingsViewController = MZDeviceSettingsViewController(withWireframe: self.wireframe, andInteractor: self.interactor!)
            settingsVC.device = self.tile
            settingsVC.locations = [] // TODO

            self.wireframe.parent?.pushViewController(toEnd: settingsVC, animated: true)
        }
    }
    
    @IBAction func expandAction(_ sender: AnyObject)
	{
        if self.collectionViewHeight.constant != 0.0
		{
            if self.timer != nil {
                self.timer.invalidate()
            }
            self.changeCollectionViewVisibility(sender)
        }
		else
		{
            self.changeCollectionViewVisibility(sender)
            if self.timer != nil
			{
                self.timer.invalidate()
            }
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MZDeviceInteractionViewController.changeCollectionViewVisibility(_:)), userInfo: nil, repeats: false)
        }
    }
    
    fileprivate func fetchWidgetInterface()
	{
        let tile: MZAreaChildViewModel
        if self.tiles == nil
		{
            tile = self.tile!
        }
		else
		{
            tile = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!]
        }
        
        if tile.interfaceUUID == nil
		{
            //TODO UnableToLoad
        } else {
            self.widgetStore.fetchURLRequestForWidget(widgetUUID: tile.interfaceUUID!, channelId: tile.channelID!, eTag: tile.interfaceETAG!)
        }
    }
	
	
    
    
    func playerDidFinish()
    {
        for (_, tileNativeComponent) in (tile!.nativeComponents?.enumerated())!
        {
            if tileNativeComponent.type == NativeComponentTypes.Video.rawValue
            {
                for (_, nativeComponent) in self.nativeComponents.enumerated()
                {
                    if let cameraVC = nativeComponent as? MZVideoPlayerController
                    {
                        cameraVC.stop()

                        cameraVC.play()

                    }
                }
            }
        }
    }


    // MARK: - MZWidgetStoreDelegate
	
	
	func handleFetchedURLRequest(request: URLRequest, widgetId: String, channelId: String) {
		let tile: MZAreaChildViewModel
		if self.tiles == nil {
			tile = self.tile!
		}
		else
		{
			tile = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!]
		}
		
		if tile.channelID == channelId && tile.interfaceUUID == widgetId
		{
			var bridgeOptsWithPreferences = tile.bridgeOptions!
			
			if(MZSessionDataManager.sharedInstance.session.userProfile.preferences.dictionaryRepresentation.count > 0)
			{
				bridgeOptsWithPreferences["preferences"] = MZSessionDataManager.sharedInstance.session.userProfile.preferences.dictionaryRepresentation
			}
			bridgeOptsWithPreferences["apiVersion"] = MZEndpoints.WebviewAPIVersion as AnyObject
			
			
			self.htmlViewController.load(with: request, withOptions: bridgeOptsWithPreferences, andNativeComponents: tile.nativeComponents)
		}
	}
	
	
    // MARK: - MZHTMLViewController Delegate

    func htmlViewController(_ htmlViewController: MZHTMLViewController!, didFailLoadWithError error: NSError!)
	{
        if error.code != NSURLErrorCancelled
		{
            //TODO UnableToLoad
        }
    }
    
    func htmlViewControllerDidFinishLoad(_ htmlViewController: MZHTMLViewController!)
    {
        htmlViewController.isGroupView = self.index == 0
        if htmlViewController.isGroupView
        {
            htmlViewController.tilesCount = (self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel.count - 1 as NSNumber)
        }
    }
    
    
    func htmlViewController(_ htmlViewController: MZHTMLViewController!, didReceiveComponentAction action: String!, withMessage message: [AnyHashable: Any]!)
	{
        let tile: MZAreaChildViewModel
        if self.tiles == nil
		{
            tile = self.tile!
        }
		else
		{
            tile = self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[self.index!]
        }
		
		if (message["type"] as? String) != nil
		{
			let type = message["type"] as! String
			
		//
			switch type
			{
			case NativeComponentsActions.audio.rawValue:
				
				for (_, tileNativeComponent) in (tile.nativeComponents?.enumerated())!
				{
					if tileNativeComponent.type == NativeComponentTypes.Video.rawValue && tileNativeComponent.identifier == message["componentId"] as! String
					{

						for (_, nativeComponent) in self.nativeComponents.enumerated()
						{
							if let cameraVC = nativeComponent as? MZVideoPlayerController
							{
								if(cameraVC.componentId == message["componentId"] as! String)
								{
									if let turnOn = message["value"] as? Bool
									{
										if(turnOn)
										{
											cameraVC.audio_on()
										}
										else
										{
											cameraVC.audio_off()
										}
									}
								}
							}
						}
					}
				}

			case NativeComponentsActions.background_audio.rawValue:
				
				for (_, tileNativeComponent) in (tile.nativeComponents?.enumerated())!
				{
					if tileNativeComponent.type == NativeComponentTypes.Video.rawValue && tileNativeComponent.identifier == message["componentId"] as! String
					{
						for (_, nativeComponent) in self.nativeComponents.enumerated()
						{
							if let cameraVC = nativeComponent as? MZVideoPlayerController
							{
								if(cameraVC.componentId == message["componentId"] as! String)
								{
									
									if let turnOn = message["value"] as? Bool
									{
										if(turnOn)
										{
											//cameraVC.stop()
											cameraVC.backgroundAudio_on()
										}
										else
										{
											
											cameraVC.backgroundAudio_off()
											//cameraVC.play()
										}
									}
								}
							}
						}
					}
				}
				
			case NativeComponentsActions.microphone.rawValue:
				for (_, tileNativeComponent) in (tile.nativeComponents?.enumerated())!
				{
					if tileNativeComponent.type == NativeComponentTypes.Video.rawValue && tileNativeComponent.identifier == message["componentId"] as! String
					{
						for (_, nativeComponent) in self.nativeComponents.enumerated()
						{
							if let cameraVC = nativeComponent as? MZVideoPlayerController
							{
								if(cameraVC.componentId == message["componentId"] as! String)
								{
									if let turnOn = message["value"] as? Bool
									{
										if(turnOn)
										{
											self.cameraVC!.microphone_on()
										}
										else
										{
											cameraVC.microphone_off()
										}
									}
								}
							}
						}
					}
				}

			case NativeComponentsActions.playVideo.rawValue:
				for (_, tileNativeComponent) in (tile.nativeComponents?.enumerated())!
				{
					if tileNativeComponent.type == NativeComponentTypes.Video.rawValue && tileNativeComponent.identifier == message["componentId"] as! String
					{
						for (_, nativeComponent) in self.nativeComponents.enumerated()
						{
							if let cameraVC = nativeComponent as? MZVideoPlayerController
							{
								if(cameraVC.componentId == message["componentId"] as! String)
								{
									if let url = message["value"] as? String
									{
										if(!url.isEmpty)
										{
											
											
											cameraVC.stop()
											// TODO: Finish this
											
											cameraVC.loadVideo(path: url, isLiveFeed: false)
											
											
											
											cameraVC.play()
										}
									}
								}
							}
						}
					}
				}

				
			default:
				break
			}
		}
	}
}
