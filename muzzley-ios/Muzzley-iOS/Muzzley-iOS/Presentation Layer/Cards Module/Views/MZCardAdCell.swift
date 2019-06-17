//
//  MZCardAdCell.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 16/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

@objc protocol MZCardAdCellDelegate: NSObjectProtocol {
    func onAdTap(_ adsViewModel : MZAdsPlaceholderViewModel)
 }

class MZCardAdCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage : UIImageView?
    @IBOutlet weak var productName : UILabel?
    @IBOutlet weak var productPrice : UILabel?
    @IBOutlet weak var btnAd: MZColorButton!
    
    var delegate: MZCardAdCellDelegate?
    var indexPath: NSIndexPath!
    var adsViewModel : MZAdsPlaceholderViewModel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productName?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        self.productName?.font = UIFont.boldFontOfSize(14)
        self.productPrice?.textColor = UIColor.muzzleyGrayColor(withAlpha: 1.0)
        self.productPrice?.font = UIFont.italicFontOfSize(12)
        
        let adLayer: CALayer = self.layer;
        adLayer.cornerRadius = 5;
        adLayer.masksToBounds = true;
        
        self.btnAd?.defaultBackgroundColor = UIColor.clear
        self.btnAd?.highlightBackgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.btnAd?.cornerRadiusScale = 0
    }
    
    
    func setViewModel(_ viewModel:MZAdsPlaceholderViewModel)
    {
        self.adsViewModel = viewModel
        self.productName?.text = self.adsViewModel?.label

        self.productPrice?.text = String(format: NSLocalizedString("mobile_product_price", comment: ""), self.adsViewModel!.priceRange)
        self.productImage?.setImageWith(self.adsViewModel!.image! as! URL)
        
   //     self.productName?.sizeToFit()
   //     self.productPrice?.sizeToFit()
    }
    
    //TODO - use uicollectionview delegate instead this
    @IBAction func onAdTap(_ sender: AnyObject) {
        delegate?.onAdTap(self.adsViewModel!)
    }
}
