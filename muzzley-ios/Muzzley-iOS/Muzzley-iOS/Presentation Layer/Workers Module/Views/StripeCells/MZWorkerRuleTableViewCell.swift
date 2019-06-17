//
//  MZWorkerRuleTableViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 18/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZWorkerRuleTableViewCell: MZStripeTableViewCell {

    static let minHeight: CGFloat = CGFloat(96.0)
    static let contentMinHeight: CGFloat = CGFloat(21.0)
    static let contentWidth: CGFloat = UIScreen.main.bounds.size.width - 139.0
    
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deleteButton: MZWorkerDeleteButton!
    @IBOutlet weak var placeholderView: UIView!
    
    internal var actionParameters: [UILabel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.deviceImageView.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
        self.deviceImageView.layer.cornerRadius = self.deviceImageView.bounds.size.height / 2.0
        self.deviceImageView.layer.borderWidth = 1.0
        self.deviceImageView.layer.borderColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
        self.deviceImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.deviceImageView.cancelImageDownloadTask()
        self.deviceImageView.image = nil
        self.deviceNameLabel.text = ""
        self.placeholderView.subviews.forEach{ $0.removeFromSuperview() }
        self.actionParameters.removeAll()
    }
    
    internal func setViewModel(_ viewModel: MZBaseWorkerDeviceViewModel, indexPath: IndexPath) {
        super.drawStripe()
        
        self.deviceImageView.cancelImageDownloadTask()
        if viewModel.imageUrl == nil {
            self.deviceImageView.image = nil
        } else {
			let url = viewModel.imageUrlAlt!
            self.deviceImageView.setImageWith(url)
        }
        
        self.deviceNameLabel.text = viewModel.title
        self.deviceNameLabel.textColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.deleteButton.model = viewModel
        self.deleteButton.indexPath = indexPath
        
        if viewModel.type == MZWorker.key_action {
            self.configurePlaceholderView(orActionParameters: viewModel.items, andIndexPath: indexPath)
        } else {
            self.configurePlaceholderView(withStateDescription: viewModel.items.first?.stateDescription.string)
        }
    }
    
    fileprivate func configurePlaceholderView(withStateDescription description: String? = nil, orActionParameters parameters: [MZBaseWorkerItemViewModel]? = nil, andIndexPath indexPath: IndexPath? = nil) {
        if parameters != nil {
            var y: CGFloat = 0.0
            for (i, parameter) in parameters!.enumerated() {
                let label: MZWorkerDeleteLabel = MZWorkerDeleteLabel(frame: CGRect(x: 0.0, y: y + 3.0, width: MZWorkerRuleTableViewCell.contentWidth, height: 21.0))
                label.numberOfLines = 3
                label.lineBreakMode = .byTruncatingTail
                label.font = UIFont.systemFont(ofSize: 14.0)
                label.text = "\u{2A2F}  " + parameter.stateDescription.string
                label.textColor = UIColor.muzzleyGray4Color(withAlpha: 1)
                label.isUserInteractionEnabled = true
                label.sizeToFit()
                label.parentModel = self.deleteButton.model
                label.model = parameter
                label.indexPath = indexPath!
                label.position = i
                self.placeholderView.addSubview(label)
                self.actionParameters.append(label)
                y += 24.0
                
                if i + 1 != parameters?.count {
                    let line: UIView = UIView(frame: CGRect(x: -4.0, y: y, width: MZWorkerRuleTableViewCell.contentWidth, height: 1.0 / UIScreen.main.scale))
                    line.backgroundColor = UIColor.muzzleyGray4Color(withAlpha: 1.0)
                    self.placeholderView.addSubview(line)
                    y += 1.0 / UIScreen.main.scale
                }
            }
        } else if description != nil {
            let label: UILabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: MZWorkerRuleTableViewCell.contentWidth, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.text = description
            label.textColor = UIColor.muzzleyGray4Color(withAlpha: 1)
            label.sizeToFit()
            self.placeholderView.addSubview(label)
        }
    }
    
}
