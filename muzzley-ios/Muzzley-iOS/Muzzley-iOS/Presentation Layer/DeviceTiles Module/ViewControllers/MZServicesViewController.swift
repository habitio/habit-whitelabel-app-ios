//
//  MZServicesViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 07/04/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZServicesViewControllerDelegate: NSObjectProtocol
{
	func didSelectAddService()
}

class MZServicesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MZBlankStateDelegate {

	let key_serviceSubscriptions = "serviceSubscriptions"
	
	@IBOutlet weak var uiServicesCollection: UICollectionView!
    @IBOutlet weak var uiBlankState: MZBlankStateView!
    
    
    
    var refreshControl : MZRefreshControl?
	var serviceSubscriptions : [MZServiceSubscription] = [MZServiceSubscription]()
	var delegate : MZServicesViewControllerDelegate?
    var isFirstTime = true
    
	init()
	{
		super.init(nibName: "MZServicesViewController", bundle: Bundle.main)
		

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		setupInterface()
	}
	

	func setupInterface()
	{
        setupBlankState()
        
		//NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MZServicesViewController.reloadData), name: UIApplicationWillEnterForegroundNotification, object: nil)
		
		self.uiServicesCollection.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiServicesCollection.register(UINib(nibName: "MZServiceSubscriptionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MZServiceSubscriptionCollectionViewCell")
		self.uiServicesCollection.delegate = self
		self.uiServicesCollection.dataSource = self
		
		self.refreshControl = MZRefreshControl(collectionView: self.uiServicesCollection)
		self.refreshControl!.addTarget(self, action: #selector(MZServicesViewController.reloadData), for: .valueChanged)
		
		reloadData()
	}

    func reloadData()
	{
		if self.view == nil {
			return;
		}

		var internetReachable = Reachability.forInternetConnection()
		
		if(internetReachable?.currentReachabilityStatus() == NotReachable)
		{
            uiBlankState.setState(state: .noInternet)
			return
		}

		if(self.isFirstTime || self.serviceSubscriptions.count == 0)
		{
			
            uiBlankState.setState(state: .loading)
		}
		else
		{
            uiBlankState.hide()
		}
		
		
		self.refreshControl?.beginRefreshing()

		
		let servicesObservable = MZServicesDataManager.sharedInstance.getObservableOfServiceSubscriptions(MZSession.sharedInstance.authInfo!.userId)
		
		
		_ = servicesObservable.subscribe(
			onNext:{(dictionary) -> Void in
                if self.isFirstTime {
                    self.isFirstTime = false
                }
				if let serviceSubscriptionsJSON = dictionary[self.key_serviceSubscriptions] as? NSArray
				{
					var serviceSubs = [MZServiceSubscription]()
					
					for s in serviceSubscriptionsJSON
					{
						let newServiceSub = MZServiceSubscription(dictionary: s as! NSDictionary)
						serviceSubs.append(newServiceSub)
					}
				
					self.serviceSubscriptions = serviceSubs
					
					if(self.serviceSubscriptions.count > 0)
					{
                        self.uiBlankState.hide()
					}
					else
					{
                        self.uiBlankState.setState(state: .blank)
					}
					
					self.uiServicesCollection.reloadData()
				}
				else
				{
					
                    self.uiBlankState.setState(state: .error)
				}

			self.refreshControl!.endRefreshing()

				
			}, onError: { error in
                self.uiBlankState.setState(state: .error)

				self.refreshControl!.endRefreshing()
		})
	}
	
	
	@IBAction func addService(_ sender: AnyObject)
	{
		self.addService()
	}
    
    
    func addService()
    {
        if(self.delegate != nil)
        {
            self.delegate?.didSelectAddService()
        }
    }


    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let aCell : MZServiceSubscriptionCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MZServiceSubscriptionCollectionViewCell", for: indexPath) as! MZServiceSubscriptionCollectionViewCell
		
		aCell.uiLabel.text = (self.serviceSubscriptions[indexPath.row] as MZServiceSubscription).name
		aCell.uiImage.setImageWith(URL(string: (self.serviceSubscriptions[indexPath.row] as MZServiceSubscription).squaredImageUrl)!)
		aCell.state =  (self.serviceSubscriptions[indexPath.row] as MZServiceSubscription).state
		return aCell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		let flowLayout : UICollectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
		let sectionInsetsHSpacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right
		let minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
		let twoItemWidth = collectionView.bounds.size.width - sectionInsetsHSpacing - minimumInteritemSpacing
		let oneItemWidth = twoItemWidth * 0.5
		return CGSize(width: oneItemWidth, height: oneItemWidth);
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return serviceSubscriptions.count
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		let ss = serviceSubscriptions[indexPath.row]
        if(!ss.infoUrl.isEmpty)
        {
            if UIApplication.shared.canOpenURL(URL(string: ss.infoUrl)!)
            {
                UIApplication.shared.openURL(URL(string: ss.infoUrl)!)
            }
        }
	}
    
    
    /// Blank state
    func setupBlankState()
    {
        self.uiBlankState.delegate = self
        self.uiBlankState.setup(blankStateImage: UIImage(named: "BlankStateServices")!,
                                blankStateTitle: NSLocalizedString("mobile_service_blankstate_empty_title", comment: ""),
                                blankStateText: NSLocalizedString("mobile_service_blankstate_empty_text", comment: ""),
                                blankStatebuttonTitle: NSLocalizedString("mobile_service_add", comment: ""),
                                loadingStateTitle: NSLocalizedString("mobile_service_blankstate_empty_title", comment: ""),
                                loadingStateText: NSLocalizedString("mobile_service_blankstate_loading_text", comment: ""))
    
        self.uiBlankState.hide()
    }
    
    func blankStateRefreshTriggered() {
        self.reloadData()
    }
    
    func blankStateButtonPressed()
    {
        self.addService()
    }
}
