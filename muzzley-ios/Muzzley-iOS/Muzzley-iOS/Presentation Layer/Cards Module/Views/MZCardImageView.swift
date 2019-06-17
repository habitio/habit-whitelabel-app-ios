//
//  MZCardImageView.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 17/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZCardImageView : UIViewController {

    @IBOutlet weak var imgView: UIImageView?
    
    var card: MZCardViewModel?
    var stage: MZStageViewModel?
    
    
    func setCardViewModel(_ viewModel: MZCardViewModel)
    {
        self.card = viewModel
        self.stage = viewModel.stages[viewModel.unfoldedStagesIndex]
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI()
    {
        self.view.backgroundColor = self.card?.colorMainBackground

        
        if let imageUrl = self.stage!.imageUrl
        {
            let imageRequest: URLRequest = URLRequest(url: imageUrl as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
            self.imgView?.setImageWith(imageRequest, placeholderImage: UIImage(), success: nil, failure: nil)
            self.imgView?.clipsToBounds = true;
        }
        else
        {
            self.imgView?.image = nil
            self.imgView?.frame.size.height = 0
        }
    }
}
