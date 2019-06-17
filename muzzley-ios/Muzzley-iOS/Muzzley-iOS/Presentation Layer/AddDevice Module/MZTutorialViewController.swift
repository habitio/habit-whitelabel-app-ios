//
//  MZTutorialViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/10/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import UIKit
@objc protocol MZTutorialViewControllerDelegate: NSObjectProtocol
{
	func didFinishTutorial()
	func tutorialCancel()
}

class MZTutorialViewController : UIViewController, UIPageViewControllerDataSource
{
	@IBOutlet weak var uiBtDone: MZColorButton!

	@IBOutlet weak var uiBtNext: UIButton!
	@IBOutlet weak var uiBtPrevious: UIButton!

    @IBOutlet weak var uiLoading: UIActivityIndicatorView!
    
	@IBOutlet weak var uiPageControl: UIPageControl!
	
	@IBOutlet weak var uiViewStepContent: UIView!
	
	var loadingView = MZLoadingView()
	var tutorial : MZTutorialViewModel!
	
	var delegate: MZTutorialViewControllerDelegate?

    var showLoading: Bool = false
	
	var pageController : UIPageViewController?
	
	convenience init(tutorial: MZTutorialViewModel)
	{
        self.init(nibName: "MZTutorialViewController", bundle: Bundle.main)
		self.tutorial = tutorial
	}
    
    convenience init(tutorial: MZTutorialViewModel, showLoading: Bool)
    {
        self.init(tutorial: tutorial)
        self.tutorial = tutorial
        self.showLoading = showLoading
    }
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		setupInterface()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingView.updateLoadingStatus(false, container: self.view)
    }
	
	func setupInterface()
	{
		self.uiBtPrevious.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)

		self.uiBtPrevious.setImage(UIImage(named: "icon_card_arrow")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
		self.uiBtPrevious.tintColor = UIColor.muzzleyGray4Color(withAlpha: 1)
		self.uiBtPrevious.imageView?.contentMode = .scaleAspectFit

		
		self.uiBtNext.setImage(UIImage(named: "icon_card_arrow")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
		self.uiBtNext.imageView?.contentMode = .scaleAspectFit
		self.uiBtNext.tintColor = UIColor.muzzleyGray4Color(withAlpha: 1)


		self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
		self.uiPageControl.currentPageIndicatorTintColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
		self.uiPageControl.pageIndicatorTintColor = UIColor.muzzleyGray4Color(withAlpha: 1.0)
		
		let barButton: UIBarButtonItem = UIBarButtonItem()
		barButton.title = ""
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
		let button = UIButton(type: .custom)
		button.tintColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
		button.bounds = CGRect(x: 0, y: 0, width: 22, height: 22)
		
		button.setImage(UIImage(named: "icon_i_info"), for: UIControlState())
		
		if(self.tutorial.infoURL != nil && !self.tutorial.infoURL!.absoluteString.isEmpty)
		{
		button.addTarget(self, action: #selector(self.showInfoButtonPressedAction(_:)), for: .touchUpInside)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
		self.navigationItem.rightBarButtonItem?.isEnabled = true
		}
		self.title = NSLocalizedString("mobile_tutorial_title", comment: "")
	
		self.pageController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
		self.pageController!.view.frame = CGRect(x: self.pageController!.view.frame.origin.x, y: self.pageController!.view.frame.origin.y, width: self.uiViewStepContent.frame.width, height: self.uiViewStepContent.frame.height)//self.pageController!.view.frame.height)
	
		
		self.pageController?.dataSource = self
		let stepContentVC = MZTutorialContentViewController(tutorialStep: self.tutorial.steps[0], stepNumber: self.uiPageControl.currentPage, maxSteps:self.uiPageControl.numberOfPages, atIndex: 0)
		
		var stepsVCs = [MZTutorialContentViewController]()

		stepsVCs.append(stepContentVC)

		self.pageController!.setViewControllers(stepsVCs, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
		self.addChildViewController(self.pageController!)
		self.uiViewStepContent.addSubview((self.pageController?.view)!)
		self.pageController?.didMove(toParentViewController: self)
		
		self.uiPageControl.numberOfPages = tutorial.steps.count
		self.uiPageControl.currentPage = 0
		updateButtons()

        
        self.uiBtDone.isHidden = showLoading
        self.uiLoading.isHidden = !showLoading
		
        if !showLoading
        {
            self.uiLoading.stopAnimating()
        }
	}

	
		@IBAction func uiBtPrevious_TouchUpInside(_ sender: AnyObject)
		{
			if(uiPageControl.currentPage > 0)
			{
				uiPageControl.currentPage -= 1
				
				var stepsVCs = [MZTutorialContentViewController]()
				let stepContentVC = MZTutorialContentViewController(tutorialStep: self.tutorial.steps[uiPageControl.currentPage], stepNumber: self.uiPageControl.currentPage, maxSteps:self.uiPageControl.numberOfPages, atIndex: self.uiPageControl.currentPage)
				
				stepsVCs.append(stepContentVC)
				
				self.pageController!.setViewControllers(stepsVCs, direction: UIPageViewControllerNavigationDirection.reverse, animated: false, completion: nil)
			
			}
			updateButtons()

		}
	
		@IBAction func uiBtNext_TouchUpInside(_ sender: AnyObject)
		{
			if (uiPageControl.currentPage <= uiPageControl.numberOfPages-1)
			{
				uiPageControl.currentPage += 1
				
				var stepsVCs = [MZTutorialContentViewController]()
				let stepContentVC = MZTutorialContentViewController(tutorialStep: self.tutorial.steps[uiPageControl.currentPage], stepNumber: self.uiPageControl.currentPage, maxSteps:self.uiPageControl.numberOfPages, atIndex: self.uiPageControl.currentPage)
				
				stepsVCs.append(stepContentVC)
				
				self.pageController!.setViewControllers(stepsVCs, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
			}
			updateButtons()
		}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
	{
		updateButtons()

		var index = (viewController as! MZTutorialContentViewController).index
		self.uiPageControl.currentPage = index

		
		if (index == 0)
		{
			return nil
		}
		
		
		index -= 1
		

		let stepContentVC = MZTutorialContentViewController(tutorialStep: self.tutorial.steps[index], stepNumber: index, maxSteps: self.uiPageControl.numberOfPages, atIndex: index)
			stepContentVC.view.frame = (self.pageController?.view.frame)!
		
		return stepContentVC
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
	{
		updateButtons()

		var index = (viewController as! MZTutorialContentViewController).index
		self.uiPageControl.currentPage = index

		if(index == uiPageControl.numberOfPages-1)
		{
			return nil
		}

		index+=1

		let stepContentVC = MZTutorialContentViewController(tutorialStep: self.tutorial.steps[index], stepNumber: index, maxSteps: self.uiPageControl.numberOfPages, atIndex: index)
		
		stepContentVC.view.frame = (self.pageController?.view.frame)!

		return stepContentVC
	}


	func showInfoButtonPressedAction(_ sender: AnyObject)
	{
		UIApplication.shared.openURL(self.tutorial.infoURL! as URL)
	}

	func updateButtons()
	{
		updateDoneButton()
		updateArrowButtons()
	}
	
	func updateDoneButton()
	{
		if (pageController?.viewControllers![0] as! MZTutorialContentViewController).index < tutorial.steps.count - 1
		{
			self.uiBtDone.setTitle(NSLocalizedString("mobile_skip_tutorial", comment: ""), for: .normal)
            //TODO
			//(self.uiBtDone as MZColorButton).invertedButton = false
		}
		else
		{
			self.uiBtDone.setTitle(NSLocalizedString("mobile_next", comment: ""), for: .normal)
            //TODO
			//(self.uiBtDone as MZColorButton).invertedButton = true
		}
	}
	
	@IBAction func uiBtDone_TouchUpInside(_ sender: AnyObject)
	{
		self.loadingView.updateLoadingStatus(true, container: self.view)
		self.delegate?.didFinishTutorial()
	}
	
	func updateArrowButtons()
	{
		
		if((pageController?.viewControllers![0] as! MZTutorialContentViewController).index > 0 && self.uiPageControl.numberOfPages > 1)
		{
			self.uiBtPrevious.isHidden = false
		}
		else
		{
			self.uiBtPrevious.isHidden = true
		}
		
		
		if((pageController?.viewControllers![0] as! MZTutorialContentViewController).index == self.uiPageControl.numberOfPages - 1)
		{
			self.uiBtNext.isHidden = true
		}
		else
		{
			self.uiBtNext.isHidden = false
		}
		
	}

	override func viewWillDisappear(_ animated : Bool)
	{
		super.viewWillDisappear(animated)
		
		if (self.isMovingFromParentViewController)
		{
			self.delegate?.tutorialCancel()
		}
	}
	
}
