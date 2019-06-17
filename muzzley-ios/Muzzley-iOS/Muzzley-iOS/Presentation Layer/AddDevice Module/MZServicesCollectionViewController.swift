//
//  MZServicesCollectionViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 14/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZServicesCollectionViewControllerDelegate: NSObjectProtocol
{
	func didSelectService(_ service:MZService)
}


class MZServicesCollectionViewController : UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
	
	@IBOutlet weak var uiServicesCollection: UICollectionView!
	fileprivate var loadingView = MZLoadingView()
	var delegate: MZServicesCollectionViewControllerDelegate?
	var frameSize : CGRect!
	var services : [MZService] = [MZService]()
	{
		didSet
		{
			uiServicesCollection.reloadData()
		}
	}
	
	
	override func viewWillDisappear(_ animated: Bool)
	{
	
		super.viewWillDisappear(animated)
		
		self.loadingView.updateLoadingStatus(false, container: self.view)
	}
	
	
	

	override func viewDidLoad()
	{
		super.viewDidLoad()
        self.loadingView.updateLoadingStatus(true, container: self.view)

		self.navigationController?.setNavigationBarHidden(true, animated: false)
		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiServicesCollection.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiServicesCollection.register(UINib(nibName: "MZProfileServiceCollectionCell", bundle: nil), forCellWithReuseIdentifier: "MZProfileServiceCollectionCell")
		self.uiServicesCollection.delegate = self
		self.uiServicesCollection.dataSource = self
		uiServicesCollection.reloadData()
	}
	

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let aCell : MZProfileServiceCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MZProfileServiceCollectionCell", for: indexPath) as! MZProfileServiceCollectionCell
		
		aCell.uiLabel.text = (self.services[indexPath.row] as MZService).name
		let url = URL(string: (self.services[indexPath.row] as MZService).photoUrlSquared)!
		aCell.uiImage.setImageWith(url)

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
		return services.count
	}
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{

        self.delegate?.didSelectService(services[indexPath.row])
	}
	
	
	
	func updateLoadingStatus(_ isLoading : Bool)
	{
        self.loadingView.updateLoadingStatus(isLoading, container: self.view)
	}
}
