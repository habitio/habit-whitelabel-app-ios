//
//  MZChannelTemplatesCollectionViewController.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 04/11/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

private let reuseIdentifier = "MZProfileServiceCollectionCell"

@objc protocol MZChannelTemplatesCollectionViewControllerDelegate: NSObjectProtocol
{
    func channelTemplatesViewController(_ viewController : MZChannelTemplatesCollectionViewController, didSelectChannelTemplate channelTemplate : MZChannelTemplate);
	func getChannelTemplatesFinished()
	func getChannelTemplatesFinishedWithError()

}

class MZChannelTemplatesCollectionViewController: UICollectionViewController
{
	var loadingView = MZLoadingView()
    var delegate: MZChannelTemplatesCollectionViewControllerDelegate?
    var interactor: MZChannelTemplatesInteractor = MZChannelTemplatesInteractor()
	var channelTemplatesArray : NSMutableArray = NSMutableArray()
    
	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		updateLoadingStatus(false)
	}
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MZAnalyticsInteractor.deviceAddStartEvent()
		self.loadingView.updateLoadingStatus(true, container: self.view)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
        self.collectionView!.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
        self.collectionView!.register(UINib(nibName: "MZProfileServiceCollectionCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.reloadData()
        self.channelTemplatesArray.removeAllObjects()

        
        interactor.getChannelTemplates { (result, error) in
            if(error == nil)
            {
                self.channelTemplatesArray.removeAllObjects()
                
                if let elements = (result as! NSDictionary).value(forKey: "elements") as? NSArray
                {
                    for element in elements
                    {
                        self.channelTemplatesArray.add(MZChannelTemplate(dictionary: element as! NSDictionary))
                        
                    }
                }
                
                self.getChannelTemplatesFinished()
            }
            else
            {
                self.getChannelTemplatesFinishedWithError()
            }
            self.updateView()
        }
    }

	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.channelTemplatesArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let flowLayout : UICollectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let sectionInsetsHSpacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
        let twoItemWidth = collectionView.bounds.size.width - sectionInsetsHSpacing - minimumInteritemSpacing
        let oneItemWidth = twoItemWidth * 0.5
		return CGSize(width: oneItemWidth, height: oneItemWidth);
    }
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	
        let aCell : MZProfileServiceCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MZProfileServiceCollectionCell
        
        aCell.uiImage.image = nil
        aCell.uiLabel.text = ""


        let channelTemplate : MZChannelTemplate = channelTemplatesArray[indexPath.row] as! MZChannelTemplate
        aCell.uiLabel.text = channelTemplate.name
        if !channelTemplate.photoUrlSquared.isEmpty
        {
            aCell.uiImage.setImageWith(URL(string: channelTemplate.photoUrlSquared)!)

        }
        
        if(!channelTemplate.overlay.isEmpty)
        {
            aCell.uiOverlayImage.isHidden = false
            aCell.uiOverlayImage.setImageWith(URL(string: channelTemplate.overlay)!)
        }
        else
        {
            aCell.uiOverlayImage.isHidden = true
        }

        return aCell
    }

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	
		updateLoadingStatus(true)
        let dataSource : NSArray = self.channelTemplatesArray as! NSArray
        let channelTemplate = dataSource[indexPath.row] as! MZChannelTemplate
        
        MZAnalyticsInteractor.deviceAddSelectDeviceEvent(channelTemplate.identifier)

        self.delegate?.channelTemplatesViewController(self, didSelectChannelTemplate: channelTemplate)
        
    }
    
    func updateLoadingStatus(_ isLoading : Bool)
    {
        self.loadingView.updateLoadingStatus(isLoading, container: self.view)
    }
    
    func updateView()
    {
        self.loadingView.updateLoadingStatus(false, container: self.view)
        self.collectionView!.reloadData()
    }
	
	func getChannelTemplatesFinished()
	{
		self.delegate!.getChannelTemplatesFinished()
	}
	
	func getChannelTemplatesFinishedWithError()
	{
		self.delegate!.getChannelTemplatesFinishedWithError()
	}
	
    func setTableViewInteractionEnabled(_ enabled:Bool)
    {
        self.collectionView!.isUserInteractionEnabled = enabled
    }
}

