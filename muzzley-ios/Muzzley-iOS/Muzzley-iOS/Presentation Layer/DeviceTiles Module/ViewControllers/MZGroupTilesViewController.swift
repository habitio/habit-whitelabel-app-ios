//
//  MZGroupTilesViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 01/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZGroupTilesViewController: UIViewController, UICollectionViewDelegateFlowLayout, DeviceTilesDataSourceDelegate {
    
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var closeButton: MZColorButton!
    @IBOutlet weak var editButton: MZColorButton!
    @IBOutlet weak var collectionView: MZCollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    
    internal var backgroundView: UIView!
    internal var delegate: DeviceTilesViewControllerDelegate?
    internal var areas: [MZTileAreaViewModel]? {
        didSet {
            self.updateInteraction()
        }
    }
    internal var groupMV: MZTileGroupViewModel? {
        didSet {
            self.updateInteraction()
        }
    }
    internal var deviceTilesDataSource: DeviceTilesDataSource!
    
    fileprivate var wireframe: DeviceTilesWireframe!
    fileprivate var interactor:MZDeviceTilesInteractor!
    fileprivate var loadingView: UIView!
    fileprivate var tabBarOverlay: UIView!
    fileprivate var interactionVC: MZDeviceInteractionViewController?
    fileprivate var synchronizer: Int = 0
    
    convenience init(withWireframe wireframe: DeviceTilesWireframe, andInteractor interactor: MZDeviceTilesInteractor) {
        self.init(nibName: "MZGroupTilesViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overlayTabBar()
        self.deviceTilesDataSource = DeviceTilesDataSource(collectionView: self.collectionView)
        self.deviceTilesDataSource.delegate = self
        self.groupTitle.text = self.groupMV!.title
        self.setupInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.interactionVC != nil {
            self.interactionVC = nil
            (self.areas?[0].tilesViewModel[0] as! GroupInteractionTileViewModel).isDetail = false
            self.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[0].isSelected = false
		
            self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
		}
        if self.parent != nil {
            self.parent?.view.bringSubview(toFront: self.view)
            self.view.layer.zPosition = 9999
        }
    }
    
    fileprivate func overlayTabBar() {
        if self.tabBarOverlay == nil {
            if self.parent?.view.superview?.superview?.superview?.superview != nil {
                var tabBar: MZTabBar? = nil
                
                for (_, view) in (self.parent?.view.superview?.superview?.superview?.superview?.subviews.enumerated())! {
                    if view is UICollectionView {
                        (view as! UICollectionView).isScrollEnabled = false
                    } else if view is MZTabBar {
                        tabBar = view as? MZTabBar
                    }
                }
                
				self.tabBarOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: tabBar!.frame.size.height))
                self.tabBarOverlay.tag = 9999
                self.tabBarOverlay.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.5)
                self.tabBarOverlay.alpha = 0.0
                tabBar?.addSubview(self.tabBarOverlay)
                tabBar?.bringSubview(toFront: self.tabBarOverlay)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.tabBarOverlay.alpha = 1.0
                })
            }
        }
    }
    
    fileprivate func setupInterface()
    {
        self.backgroundView = UIView(frame: UIScreen.main.bounds)
        self.backgroundView.backgroundColor = UIColor.clear
        self.parent?.view.insertSubview(self.backgroundView, belowSubview: self.view)
        
        self.view.layer.cornerRadius = 10.0
		self.view.layer.shadowOffset = CGSize(width:0, height:0)
        self.view.layer.shadowColor = UIColor.muzzleyBlackColor(withAlpha: 1).cgColor
        self.view.layer.shadowRadius = 24
        self.view.layer.shadowOpacity = 1
		
        self.collectionView.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.1)
        self.headerView.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.1)
        self.lineHeight.constant = 1.0 / UIScreen.main.scale
        self.closeButton.tintColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        self.editButton.setImage(self.editButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.editButton.tintColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        self.groupTitle.textColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        
        self.collectionView.dataSource = self.deviceTilesDataSource
        self.collectionView.allowsSelection = true
        
        self.deviceTilesDataSource.setData(self.areas! as NSArray)
        self.deviceTilesDataSource.isDetail = false
    }
    
    internal func showLoadingView() {
        if self.interactionVC != nil {
            self.interactionVC?.showLoadingView()
        }
        
        var lFrame: CGRect = self.view.frame
        lFrame.origin.x = 0.0
        lFrame.origin.y = 0.0
        self.loadingView = UIView(frame: lFrame)
        self.loadingView.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.2)
        self.loadingView.layer.cornerRadius = 10.0
        self.loadingView.layer.masksToBounds = true
        
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        var frame: CGRect = self.loadingView.frame
        frame.origin.x = frame.size.width / 2.0 - loading.frame.size.width / 2.0
        frame.origin.y = frame.size.height / 2.0 - loading.frame.size.height / 2.0
        frame.size = loading.frame.size
        loading.frame = frame
        self.loadingView.addSubview(loading)
        self.loadingView.alpha = 0.0
        self.view.addSubview(self.loadingView)
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.loadingView.alpha = 1.0
            loading.startAnimating()
        }
    }
    
    internal func hideLoadingView() {
        if self.loadingView != nil {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.loadingView.alpha = 0.0
            }, completion: { (success) -> Void in
                if self.loadingView != nil {
                    self.loadingView.subviews.forEach{ $0.removeFromSuperview() }
                    self.loadingView.removeFromSuperview()
                    self.loadingView = nil
                }
            })
        }
         //FIX ME patch to prevent top bar disappearing
        if self.parent != nil {
            self.parent?.view.bringSubview(toFront: self.view)
        }
    }
    
    fileprivate func updateInteraction() {
        self.synchronizer += 1
        if self.synchronizer == 2 {
            self.interactionVC?.tiles = self.areas
            self.interactionVC?.groupVM = self.groupMV
            (self.interactionVC?.tiles?[0].tilesViewModel[0] as? GroupInteractionTileViewModel)?.isDetail = true
            self.interactionVC?.deviceTilesDataSource.setData((self.interactionVC?.tiles)! as NSArray)
            self.interactionVC?.deviceTilesDataSource.isDetail = true
            self.interactionVC?.deviceTilesDataSource.deviceAreaViewModelList[0].tilesViewModel[0].isSelected = true
            self.interactionVC?.collectionView.reloadSections(IndexSet(integer: 0))
			
            if self.interactionVC?.timer != nil {
                self.interactionVC?.timer.invalidate()
            }
            self.interactionVC?.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self.interactionVC!, selector: #selector(MZDeviceInteractionViewController.changeCollectionViewVisibility(_:)), userInfo: nil, repeats: false)
            self.synchronizer = 0
            
            if self.interactionVC != nil {
                self.interactionVC?.hideLoadingView()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Helper methods
    
//    internal override func setInfoPlaceholderVisible(visible: Bool) {
//        self.infoPlaceholderView!.alpha = CGFloat(visible)
//        self.collectionView.alpha = CGFloat(!visible)
//    }
    
    fileprivate func reveal() {
        if self.view.frame.origin.y == 4.0 {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var newFrame: CGRect = self.view.frame
                newFrame.origin.y = self.view.frame.size.height / 3.0
                self.view.frame = newFrame
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                var newFrame: CGRect = self.view.frame
                newFrame.origin.y = 4.0
                self.view.frame = newFrame
            })
        }
    }
    
    fileprivate func hoverMainList(_ isHover: Bool) {
        self.backgroundView.backgroundColor = isHover ? UIColor.muzzleyBlueColor(withAlpha: 0.5) : UIColor.clear
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //FIX ME patch to prevent top bar disappearing
        if self.parent != nil {
            self.parent?.view.bringSubview(toFront: self.view)
        }
        let flowLayout: UICollectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let sectionInsetsHSpacing: CGFloat = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let minimumInteritemSpacing: CGFloat = flowLayout.minimumInteritemSpacing
        let twoItemWidth: CGFloat = collectionView.bounds.size.width - sectionInsetsHSpacing - minimumInteritemSpacing
        let oneItemWidth: CGFloat = twoItemWidth * 0.5
		return CGSize(width: oneItemWidth, height: oneItemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: 0.01)
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.interactionVC = MZDeviceInteractionViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
        self.interactionVC?.tiles = self.areas
        self.interactionVC?.index = indexPath.row
        self.interactionVC?.groupVM = self.groupMV
        self.wireframe.parent?.pushViewController(toEnd: self.interactionVC, animated: true)
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func closeAction(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            var newFrame: CGRect = self.view.frame
            newFrame.origin.y = UIScreen.main.bounds.size.height
            self.view.frame = newFrame
            if self.tabBarOverlay != nil {
                self.tabBarOverlay.alpha = 0.0
            }
        }) { (success) -> Void in
            if self.tabBarOverlay != nil {
                self.tabBarOverlay.removeFromSuperview()
                self.tabBarOverlay = nil
            }
            
            self.backgroundView.removeFromSuperview()
            
            if self.parent != nil {
                for (_, view) in (self.parent?.view.superview?.superview?.superview?.superview?.subviews.enumerated())! {
                    if view is UICollectionView {
                        (view as! UICollectionView).isScrollEnabled = true
                    }
                }
                
            }
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    
    @IBAction func editAction(_ sender: AnyObject) {
        let area: MZTileAreaViewModel = self.deviceTilesDataSource.deviceAreaViewModelList[0]
        var tiles: [MZAreaChildViewModel] = area.tilesViewModel
        tiles.removeFirst()
        
        let settingsVC: MZGroupSettingsViewController = MZGroupSettingsViewController(withWireframe: self.wireframe, andInteractor:self.interactor)
        //TODO improve me
        settingsVC.groupVM = self.groupMV
        settingsVC.devicesInGroup = tiles
        self.wireframe.parent?.push(settingsVC, animated: true)
    }
    
    //MARK  DeviceTilesDataSourceDelegate
    func deviceTilesDataSource(_ toggle: MZTriStateToggle, dataSource: DeviceTilesDataSource, didSelectSwitchTileState: MZAreaChildViewModel)
    {
        self.interactor.sendStatusToDevice(didSelectSwitchTileState, completion: nil)
    }
}
