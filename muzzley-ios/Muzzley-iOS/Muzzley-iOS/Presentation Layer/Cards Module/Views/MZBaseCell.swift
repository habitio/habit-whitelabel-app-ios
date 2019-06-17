//
//  MZCardElement.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZCardElement : UIViewController
{
    var card: MZCardViewModel?
    var stage: MZStageViewModel?
	var indexPath: IndexPath?
    
    func setCardViewModel(_ viewModel: MZCardViewModel)
    {
        self.card = viewModel
        self.stage = viewModel.stages[viewModel.unfoldedStagesIndex]
    }

    override func viewDidLoad() {
        if(card != nil)
        {
            self.view.backgroundColor = card!.colorMainBackground
        }
    }
}
