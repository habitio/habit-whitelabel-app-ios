//
//  MZBaseFieldPicker.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 14/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

class MZBaseFieldPicker : MZCardElement
{
    @IBOutlet weak var titleLabel : UILabel?
    
    var value : NSObject?
    var field : MZFieldViewModel?
    
    override func viewDidLoad() {
        self.titleLabel?.textColor = self.card?.colorMainText
    }

    
    func setFieldViewModel(_ viewModel: MZFieldViewModel)
    {
        self.field = viewModel
  //      self.titleLabel?.numberOfLines = 0;
        self.titleLabel?.text = self.field?.label
        //        self.titleLabel?.sizeToFit()
    }
}
