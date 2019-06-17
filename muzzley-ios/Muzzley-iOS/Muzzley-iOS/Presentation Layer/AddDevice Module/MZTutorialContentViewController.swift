//
//  MZTutorialContentViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/11/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZTutorialContentViewController : UIViewController
{
	
	@IBOutlet weak var uiLbTitle: UILabel!
	
	@IBOutlet weak var uiStepImage: UIImageView!
	
	@IBOutlet weak var uiDescription: UITextView!

	var step : MZTutorialStepViewModel?
	
	var index : Int = 0
	var currentStepNumber : Int = 0
	var numberOfSteps : Int = 0
	
	convenience init(tutorialStep: MZTutorialStepViewModel, stepNumber: Int, maxSteps : Int, atIndex: Int)
	{
		self.init(nibName: "MZTutorialContentViewController", bundle: Bundle.main)
		self.step = tutorialStep
		self.currentStepNumber = stepNumber
		self.numberOfSteps = maxSteps
		self.index = atIndex
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		uiDescription.isSelectable = false
	}
	
	func setupInterface()
	{
		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)

		self.uiLbTitle.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		self.uiDescription.text = self.step!.stepDescription
		self.uiDescription.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
		self.uiDescription.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		
		// Set Title
		if step!.stepTitle!.isEmpty
		{
			let str = NSLocalizedString("mobile_step", comment: "") + " " + String(currentStepNumber + 1)
			self.uiLbTitle.text = 	str
		}
		else
		{
			self.uiLbTitle.text = step!.stepTitle!
		}
		
		// Set Image
		if step!.imageUrl != nil
		{
			self.uiStepImage.setImageWith(step!.imageUrl! as! URL)
			
		}
		else if step!.image != nil
		{
			self.uiStepImage.image = step!.image
		}
		
		// Set Description
		self.uiDescription.text = step!.stepDescription
	}
	

	

}
