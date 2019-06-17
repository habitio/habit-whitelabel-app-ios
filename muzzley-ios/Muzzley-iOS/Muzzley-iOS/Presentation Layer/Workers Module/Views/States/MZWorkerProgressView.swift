//
//  MZWorkerProgressView.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 15/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZWorkerProgressView : UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: MZWorkerProgressViewModel!

    
//    func setViewModel(viewModel:MZWorkerProgressViewModel)
//    {
//        self.viewModel = viewModel
//        self.titleLabel.text = self.viewModel.title
//    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.titleLabel.font = UIFont.lightFontOfSize(16)
        self.titleLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
    }

}
