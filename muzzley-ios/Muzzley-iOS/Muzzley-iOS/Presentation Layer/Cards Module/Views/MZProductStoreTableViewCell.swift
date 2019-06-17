//
//  MZProductStoreTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 17/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

protocol MZProductStoreTableViewCellDelegate {
    func didPressBuyNow(_ index: Int)
}

class MZProductStoreTableViewCell: UITableViewCell {

    static let contentHeight: CGFloat = CGFloat(130.0)
    
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var brandLogoImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyContainerView: UIView!
    @IBOutlet weak var buyNowLabel: UILabel!
    @IBOutlet weak var highlightedImageView: UIImageView!
    @IBOutlet weak var touchArea: UIButton!
    
    fileprivate var model: MZStore?
    fileprivate var index: Int?
    fileprivate var startDisplayDate: Date?
    
    internal var delegate: MZProductStoreTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.infoContainerView.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        self.infoContainerView.layer.cornerRadius = 3.0
        self.infoContainerView.layer.borderWidth = 1.0
        self.infoContainerView.layer.borderColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1.0).cgColor
        self.infoContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.infoContainerView.layer.shadowColor = UIColor.muzzleyBlackColor(withAlpha: 0.28).cgColor
        self.infoContainerView.layer.shadowRadius = 3.0
        self.infoContainerView.layer.shadowOpacity = 0.28
        self.infoContainerView.layer.masksToBounds = true
        
        self.deliveryLabel.font = UIFont.boldItalicFontOfSize(10)
        self.deliveryLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)
        self.deliveryLabel.text = ""
        self.locationLabel.font = UIFont.boldItalicFontOfSize(10)
        self.locationLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)
        self.locationLabel.text = ""
        
        self.priceLabel.font = UIFont.boldFontOfSize(23)
        self.priceLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        self.priceLabel.text = ""
        
        self.buyContainerView.backgroundColor = UIColor.muzzleyBlueColor(withAlpha: 0.1)
        self.buyNowLabel.font = UIFont.heavyFontOfSize(12)
        self.buyNowLabel.textColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
        self.buyNowLabel.text = NSLocalizedString("mobile_cards_product_shop", comment: "").uppercased()
        
        self.highlightedImageView.isHidden = true
        
//        self.buyContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didPressBuyNowAction:"))
//        self.buyNowLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didPressBuyNowAction:"))
        
        self.touchArea.backgroundColor = UIColor.clear
        self.touchArea.layer.cornerRadius = 3.0
        self.touchArea.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.infoContainerView.layer.borderColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1.0).cgColor
        self.deliveryLabel.text = ""
        self.locationLabel.text = ""
        self.brandLogoImageView.cancelImageDownloadTask()
        self.priceLabel.text = ""
        self.highlightedImageView.isHidden = true
        self.touchArea.backgroundColor = UIColor.clear
    }
    
    internal func configure(_ model: MZStore, index: Int) {
        self.model = model
        self.index = index
        
        if model.highlighted {
            self.highlightedImageView.isHidden = false
            self.infoContainerView.layer.borderColor = UIColor.muzzleyYellowColor(withAlpha: 1.0).cgColor
        }
        
        if model.deliverTimeSpan.count > 0 {
            self.deliveryLabel.text = (NSLocalizedString("mobile_store_delivery", comment: "") + " \(model.deliverTimeSpan.first!)-\(model.deliverTimeSpan.last!) " + model.deliverUnit).uppercased()
        }
        
        if model.locations.count > 0 && model.nearestStore != -1.0 // -1.0 means that there is no physical store (To remove this magic number)
		{
			if(MZSessionDataManager.sharedInstance.session.userProfile.preferences.units == "imperial")
			{
				self.locationLabel.text = ("\(model.locations.count) " + NSLocalizedString(model.locations.count > 1 ? "locations" : "location", comment: "") + NSLocalizedString("mobile_location_near", comment: "") + (NSString(format: "%.2f ", model.nearestStore) as String) + NSLocalizedString("mobile_mile_unit", comment: "")).uppercased()
			}
			else
			{
				self.locationLabel.text = ("\(model.locations.count) " + NSLocalizedString(model.locations.count > 1 ? "locations" : "location", comment: "") + NSLocalizedString("mobile_location_near", comment: "") + (NSString(format: "%.2f ", model.nearestStore) as String) + NSLocalizedString("mobile_km_unit", comment: "")).uppercased()
			}
        }
        
        self.brandLogoImageView.cancelImageDownloadTask()
        self.brandLogoImageView.setImageWith(URL(string: model.logoURl)!)
        self.priceLabel.text = model.price
    }
    
    @IBAction func didPressBuyNowAction(_ sender: AnyObject) {
        self.touchArea.backgroundColor = UIColor.clear
        self.delegate?.didPressBuyNow(self.index!)
    }
    
    @IBAction func touchAreaHighlight(_ sender: AnyObject) {
        self.touchArea.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.1)
    }
}
