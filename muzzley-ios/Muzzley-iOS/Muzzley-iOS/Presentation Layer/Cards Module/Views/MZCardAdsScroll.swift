//
//  MZCardAdsScroll.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 15/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

@objc protocol MZCardAdsScrollDelegate: NSObjectProtocol
{
    func buttonTapped(_ viewModel: MZFieldViewModel)
}


class IndexedCollectionView: UICollectionView {
    
    var indexPath: NSIndexPath!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MZCardAdsScroll: UIViewController {

    @IBOutlet weak var scrollViewContainer: UIView!
    var collectionView: IndexedCollectionView!
    
    var delegateAds: (UICollectionViewDelegate & UICollectionViewDataSource)?
    var delegate: MZCardAdsScrollDelegate?

    
    var value : NSObject?
    var card: MZCardViewModel?
    var field: MZFieldViewModel?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setViewModel(_ cardViewModel: MZCardViewModel, fieldViewModel: MZFieldViewModel, indexPath : IndexPath)
    {
        self.card = cardViewModel
        self.field = fieldViewModel
        self.indexPath = indexPath
    }
    
    func setupUI()
    {
        
        if let previousValue : [MZAdsPlaceholderViewModel] = self.field?.getValue() as? [MZAdsPlaceholderViewModel]
        {
            self.value = previousValue as NSObject
        } else {
            self.value = field!.placeholders as? [MZAdsPlaceholderViewModel] as! NSObject
        }
        
        self.setAdsView()
    }
    
    
    
    
    func setAdsView()
    {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
		layout.itemSize = CGSize(width: 150, height: 200)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0,left: 16,bottom: 0,right: 16)
        
        self.collectionView = IndexedCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.register(UINib(nibName: "MZCardAdCell", bundle: nil), forCellWithReuseIdentifier:"MZCardAdCell")
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.clear
        
        for subview in self.scrollViewContainer!.subviews
        {
            subview.removeFromSuperview()
        }
        self.scrollViewContainer!.addSubview(self.collectionView)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = NSLayoutConstraint(item: self.collectionView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: self.scrollViewContainer!,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0);
        self.scrollViewContainer!.addConstraint(leadingConstraint);
        
        let trailingConstraint = NSLayoutConstraint(item: self.collectionView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: self.scrollViewContainer!,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0);
        self.scrollViewContainer!.addConstraint(trailingConstraint);
        
        let topConstraint = NSLayoutConstraint(item: self.collectionView,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self.scrollViewContainer!,
                                               attribute: .top,
                                               multiplier: 1,
                                               constant: 0);
        self.scrollViewContainer!.addConstraint(topConstraint);
        
        let bottomConstraint = NSLayoutConstraint(item: self.collectionView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self.scrollViewContainer!,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0);
        self.scrollViewContainer!.addConstraint(bottomConstraint);
        
        let frame = self.view.bounds
        self.collectionView.frame = CGRect(x: 0, y: 0.5, width: frame.size.width, height: frame.size.height - 1)

    }
	

    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, indexPath: IndexPath) {
        self.delegateAds = delegate
        self.indexPath = indexPath
        
        self.collectionView.dataSource = self.delegateAds
        self.collectionView.delegate = self.delegateAds
        self.collectionView.indexPath = self.indexPath as! NSIndexPath
        self.collectionView.tag = self.indexPath!.section
        self.collectionView.reloadData()
    }
    
    
    @IBAction func buttonTapped () {
        self.delegate?.buttonTapped(self.field!)
    }
}
