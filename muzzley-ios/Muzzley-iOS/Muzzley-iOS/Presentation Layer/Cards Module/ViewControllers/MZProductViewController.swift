//
//  MZProductViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 17/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZProductViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, MZProductStoreTableViewCellDelegate {

    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var parentWireframe: MZRootWireframe!
    fileprivate var cardsInteractor: MZCardsInteractor!
    fileprivate var productVM: MZProduct?
    
    internal var cardId: String!
   // internal var productId: String!
    internal var detailUrl: String!
    
    convenience init(parentWireframe: MZRootWireframe, interactor: MZCardsInteractor) {
        self.init(nibName: String(describing: MZProductViewController.self), bundle: Bundle.main)
        
        self.parentWireframe = parentWireframe
        self.cardsInteractor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initLayout()
        self.initData()
    }
    
    fileprivate func initLayout() {
        self.tableView?.tableFooterView = UIView()
        self.tableView?.register(UINib(nibName: String(describing: MZProductTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MZProductTableViewCell.self))
        self.tableView?.register(UINib(nibName: String(describing: MZProductStoreTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MZProductStoreTableViewCell.self))
        
        self.setInfoPlaceholderVisible(false)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    fileprivate func initData() {
        self.reloadData()
    }
    
    override func reloadData() {
        super.reloadData()
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.cardsInteractor.getProductDetails(self.detailUrl) { (result, error) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            if error == nil {
                self.setInfoPlaceholderVisible(false)
                self.productVM = result
                self.tableView?.reloadData()
            } else {
                self.setEmptyResultsInfoPlaceholderWithPlaceholderImageName("ohNoIcon",  title: NSLocalizedString("mobile_blankstate_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), buttonTitle: NSLocalizedString("mobile_retry", comment: ""), andButtonAction: #selector(MZProductViewController.reloadData))
                self.infoPlaceholderView.title = NSLocalizedString("mobile_error_title", comment: "")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
	{
		return self.productVM != nil ? (self.productVM?.specs != nil ? 3 : 2) : 0

		//return self.productVM != nil ? 2 + Int(self.productVM?.specs != nil) : 0 // No longer supported in Swift3
	
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return (self.productVM?.stores.count)!
        case 2: return 4
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let aCell: MZProductTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MZProductTableViewCell.self), for: indexPath) as! MZProductTableViewCell
                aCell.configure(self.productVM!)
                cell = aCell
                
            default: break
            }
        case 1:
            let aCell: MZProductStoreTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MZProductStoreTableViewCell.self), for: indexPath) as! MZProductStoreTableViewCell
            aCell.configure((self.productVM?.stores[indexPath.row])!, index: indexPath.row)
            aCell.delegate = self
            cell = aCell
        case 2:
            switch indexPath.row {
            case 1:
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "titleSpecsCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "titleSpecsCell")
                }
                aCell?.textLabel?.numberOfLines = 0
                aCell?.textLabel?.lineBreakMode = .byWordWrapping
                aCell?.textLabel?.font = UIFont.boldFontOfSize(15)
                aCell?.textLabel?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
                aCell?.textLabel?.text = NSLocalizedString("mobile_cards_product_description_title", comment: "")
                cell = aCell
                break
            case 2:
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "specsCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "specsCell")
                }
                aCell?.textLabel?.numberOfLines = 0
                aCell?.textLabel?.lineBreakMode = .byWordWrapping
                aCell?.textLabel?.font = UIFont.regularFontOfSize(15)
                aCell?.textLabel?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
                aCell?.textLabel?.text = self.productVM?.specs
                cell = aCell
                break
            case 0, 3:
                var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "spacerCell")
                if aCell == nil {
                    aCell = UITableViewCell(style: .default, reuseIdentifier: "spacerCell")
                }
                cell = aCell
                
            default: break
            }
            
        default: break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.lineBreakMode = .byWordWrapping
            return ((9.0 * UIScreen.main.bounds.size.width) / 16.0) + MZProductTableViewCell.contentMinHeight + (NSString(string: (self.productVM?.productDescription)!).boundingRect(with: CGSize(width: MZProductTableViewCell.contentWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.regularFontOfSize(15)], context: nil).size.height)
        case 1: return MZProductStoreTableViewCell.contentHeight
        case 2:
            switch indexPath.row {
            case 0: return 35.0
            case 1: return 35.0
            case 2:
                let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                style.lineBreakMode = .byWordWrapping
                return NSString(string: (self.productVM?.specs)!).boundingRect(with: CGSize(width: MZProductTableViewCell.contentWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.regularFontOfSize(15)], context: nil).size.height
            case 3: return 45.0
                
            default: return 0.0
            }
            
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let currentStore: MZStore = (self.productVM?.stores[indexPath.row])!
            if !currentStore.hasBeenViewed {
                currentStore.hasBeenViewed = true
                self.cardsInteractor.setCardViewFeedback(self.cardId, storeId: currentStore.id, completion: { (result, error) -> Void in
                    // Do something
                })
            }
        }
    }
    
    
    // MARK: - MZProductStoreTableViewCellDelegate
    
    func didPressBuyNow(_ index: Int)
    {
        let currentStore: MZStore = (self.productVM?.stores[index])!
        //removed internal webview till issue with incorrect page view fixed
//        let webView = MZWebViewController()
//        webView.url = NSURL(string: currentStore.url)
//        self.parent.pushViewControllerToEnd(webView, animated: true)
        
        self.cardsInteractor.setCardClickFeedback(self.cardId, storeId: currentStore.id) { (result, error) -> Void in
            // Do something
        }
        
        if let urlString: String = currentStore.url as? String
        {
            UIApplication.shared.openURL(URL(string: urlString)!)
        }
    }
    
}
