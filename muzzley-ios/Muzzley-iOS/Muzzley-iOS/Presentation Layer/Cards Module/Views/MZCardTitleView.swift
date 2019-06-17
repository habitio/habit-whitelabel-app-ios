//
//  MZCardTitleView.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 24/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZCardTitleViewDelegate: NSObjectProtocol {
    func feedbackButtonTappedWithCard(_ card: MZCardViewModel)
}


class MZCardTitleView : UIViewController
{
    @IBOutlet weak var timestampCardLbl: UILabel!
    @IBOutlet weak var titleCardLbl: UILabel!
    @IBOutlet weak var titleStageLbl: UILabel!
    @IBOutlet weak var btnHide: UIButton!
    
    
    var card: MZCardViewModel?
    var stage: MZStageViewModel?
    var indexPath: IndexPath?
    
    
    override func viewDidLoad() {
        setupUI()
    }
    
    var delegate: MZCardTitleViewDelegate?

    func setCardViewModel(_ viewModel: MZCardViewModel)
    {
        self.card = viewModel
        self.stage = viewModel.stages[viewModel.unfoldedStagesIndex]
    }
    
    func setupUI()
    {
       

        self.view.backgroundColor = self.card?.colorMainBackground
        
        self.titleCardLbl?.font = UIFont.boldFontOfSize(11)
        self.titleCardLbl?.textColor = self.card?.colorMainTitle

        self.timestampCardLbl?.font = UIFont.lightFontOfSize(11)
        self.timestampCardLbl?.textColor = self.card?.colorMainTitle

        self.titleStageLbl?.font = UIFont.boldFontOfSize(11)
        self.titleStageLbl?.textColor = self.card?.colorMainText
        self.titleStageLbl?.alpha = 0.5

        self.btnHide?.tintColor = self.card?.colorBtnHideOptions
        
        self.titleStageLbl.text = self.stage?.title!.uppercased()
        self.titleCardLbl.text = self.card?.title!.uppercased()
        self.timestampCardLbl.text = self.card?.timestamp

        if !self.titleStageLbl!.text!.isEmpty && !self.titleCardLbl!.text!.isEmpty
        {
            self.titleCardLbl?.text = self.titleCardLbl!.text! + ": "
        }

        if self.card!.feedback.isEmpty
        {
            self.btnHide!.isHidden = true
        }
        else
        {
            self.btnHide!.isHidden = false
        }
    }

    @IBAction func openFeedbackPopup ()
    {
        // TODO: Cards. Handle this event
        delegate?.feedbackButtonTappedWithCard (self.card!)
    }
}
