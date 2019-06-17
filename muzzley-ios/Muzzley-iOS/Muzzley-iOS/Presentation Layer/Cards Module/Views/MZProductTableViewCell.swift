//
//  MZProductTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 17/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZProductTableViewCell: UITableViewCell {

    static let contentMinHeight: CGFloat = CGFloat(134.0)
    static let contentWidth: CGFloat = UIScreen.main.bounds.size.width - 32.0
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    fileprivate var model: MZProduct?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sponsoredLabel.font = UIFont.boldFontOfSize(12)
        self.sponsoredLabel.textColor = UIColor.muzzleyGray4Color(withAlpha: 1.0)
        self.sponsoredLabel.text = NSLocalizedString("mobile_sponsored", comment: "").uppercased()
        
        self.nameLabel.font = UIFont.boldFontOfSize(23)
        self.nameLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        self.nameLabel.text = ""
        
        self.descriptionLabel.font = UIFont.regularFontOfSize(15)
        self.descriptionLabel.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        self.descriptionLabel.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.productImageView.cancelImageDownloadTask()
        self.nameLabel.text = ""
        self.descriptionLabel.text = ""
    }
    
    internal func configure(_ model: MZProduct) {
        self.model = model
        
        self.productImageView.cancelImageDownloadTask()
        self.productImageView.setImageWith(URL(string: model.imageURL)!)
        
        self.nameLabel.text = model.name
        self.descriptionLabel.text = model.productDescription
    }
    
}
