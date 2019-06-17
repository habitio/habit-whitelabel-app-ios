//
//  MZWorkerUsecaseCell.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 12/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//


class MZWorkerUsecaseCell : MZWorkerCell
{
    @IBOutlet weak var lbUsecaseCategory: UILabel?
    @IBOutlet weak var lbUsecaseDescription: UILabel?
	@IBOutlet weak var uiClientImage: UIImageView!
	@IBOutlet weak var uiCategoryImage: UIImageView!
	
	@IBOutlet weak var uiWorkerLabelLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var uiWorkerDescriptionLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var uiWorkerLabelTopConstraint: NSLayoutConstraint!
	
    override func setViewModel (_ viewModel: MZWorkerViewModel)
    {
        super.setViewModel(viewModel)
        
        self.lbUsecaseCategory?.text = viewModel.category.uppercased()
        self.lbUsecaseCategory?.textColor = viewModel.categoryColor
        self.lbUsecaseDescription?.text = viewModel.desc
		
		self.uiWorkerLabelTopConstraint.constant = 20
		if(viewModel.categoryImage != nil)
		{
			uiCategoryImage.setImageWith(viewModel.categoryImage!)
			uiWorkerLabelLeadingConstraint.constant = CGFloat(15 + 52 + 20)
			uiWorkerDescriptionLeadingConstraint.constant = CGFloat(15 + 52 + 20)
			uiCategoryImage.isHidden = false
		}
		else
		{
			uiWorkerLabelLeadingConstraint.constant = 15
			uiWorkerDescriptionLeadingConstraint.constant = 15
			uiCategoryImage.isHidden = true
		}

		if(viewModel.clientImage != nil)
		{
			uiClientImage.setImageWith(viewModel.clientImage!)
			uiClientImage.isHidden = false
		}
		else
		{
			uiClientImage.isHidden = true
		}

    }
	
	
    override func layoutSubviews()
    {
		
        super.layoutSubviews()
        
        self.lbUsecaseCategory?.font = UIFont.boldFontOfSize(12)
		
        self.lbUsecaseDescription?.font = UIFont.lightFontOfSize(13)
        self.lbUsecaseDescription?.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
    }
    
}
