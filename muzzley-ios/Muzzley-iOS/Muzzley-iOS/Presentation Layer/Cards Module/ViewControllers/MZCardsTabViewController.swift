//
//  MZCardsTabViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/11/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit


@objc protocol MZCardsTabViewControllerDelegate : NSObjectProtocol
{
    func cardsOnboardingShown()
}

class MZCardsTabViewController: UIViewController, MZRootCardsViewControllerDelegate, MZCardsScrollDelegate, MZShortcutsHeaderViewDelegate, MZOnboardingViewControllerDelegate
{
    fileprivate var interactor : MZCardsInteractor?
    var wireframe: MZCardsWireframe!
//    fileprivate var refreshControl: MZRefreshControl?

    fileprivate var isCardsViewVisible = false
    
    var cardsDelegate : MZCardsTabViewControllerDelegate?
    
    var showShortcuts = false
    var cardsView = MZCardsViewController()
    
    @IBOutlet weak var uiShortcutsView: UIView!
    @IBOutlet weak var uiCardsView: UIView!
    
    @IBOutlet weak var uiStackView: UIStackView!
    
    func shouldAddShortcut(_ interactor: MZShortcutsInteractor)
    {
        
    }
    
    func didPressShowMore(_ interactor: MZShortcutsInteractor)
    {
        let shortcutsVC = MZShortcutsViewController(withWireframe: self.wireframe.parent as! MZRootWireframe, andInteractor: interactor)
        shortcutsVC.myShortcuts = (self.uiShortcutsView.subviews[0] as! MZShortcutsHeaderView).shortcuts
        shortcutsVC.delegate = (self.uiShortcutsView.subviews[0] as! MZShortcutsHeaderView)
        shortcutsVC.view.alpha = 0
        var newFrame = self.view.frame
        newFrame.size.width = UIScreen.main.bounds.size.width
        shortcutsVC.view.frame = newFrame
        
        self.addChildViewController(shortcutsVC)
        self.view.addSubview(shortcutsVC.view)
        self.view.bringSubview(toFront: shortcutsVC.view)
        UIView.animate(withDuration: 0.3)
        {
            shortcutsVC.view.alpha = 1
        }
    }
    
    func cardsTabDoubleTapped()
    {


//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
//            self.uiShortcutsView.isHidden = false
//        })

        if self.showShortcuts
        {
            UIView.animate(withDuration: 0.3)
            {
                self.uiShortcutsView.isHidden = false
            }
        }
    }
    
    func cardsTabVisibleStatusUpdate(_ isVisible: Bool)
    {
        self.isCardsViewVisible = isVisible
        if self.isCardsViewVisible
        {
            self.showOnboardings()
        }
    }
  
    
    func showOnboardings()
    {
        if self.view == nil { return }
        
        if self.view.window == nil { return }
        
        if(!MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_cards))
        {
            self.definesPresentationContext = true;
            
            let onboarding = MZCardsOnboardingViewController(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext, highlightViews: [])
            self.present(onboarding, animated: false, completion: nil)
            onboarding.show()
            onboarding.delegate = self
            MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_cards, shownStatus: true)
            
        }
    }
    
    func contextualOnboardingDidDismiss() {
        if self.cardsDelegate != nil
        {
            self.cardsDelegate!.cardsOnboardingShown()
        }
    }
    
    func cardsScrollDetected(_ scrolledUp: Bool)
    {
        if showShortcuts
        {
            if(scrolledUp)
            {
                UIView.animate(withDuration: 0.3)
                {
                    self.uiShortcutsView.isHidden = false
                }
            }
            else
            {
                UIView.animate(withDuration: 0.3)
                {
                    self.uiShortcutsView.isHidden = true
                }
            }
        }
    }
 
    
    init(wireframe : MZCardsWireframe, interactor: MZCardsInteractor)
    {
        super.init(nibName: "MZCardsTabViewController", bundle: Bundle.main)
        self.interactor = interactor
        self.wireframe = wireframe
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        (self.wireframe.parent as! MZRootWireframe).rootViewController.cardsDelegate = self
        
        self.view.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
        cardsView.parentWireframe = (self.wireframe.parent as! MZRootWireframe)
        cardsView.cardsScrollDelegate = self
        cardsView.view.frame = CGRect(x: 0, y: 0, width : self.uiCardsView.frame.width, height: self.uiCardsView.frame.height)
        self.uiCardsView.addSubview(cardsView.view)
        
        self.showShortcuts = false// MZThemeManager.sharedInstance.features(MZThemeFeatures.shortcuts) as! Bool
        if self.showShortcuts
        {
            let shortcutsView = MZShortcutsHeaderView(frame: self.uiShortcutsView.frame)
            shortcutsView.delegate = self
            self.uiShortcutsView.addSubview(shortcutsView)

            self.uiShortcutsView.isHidden = false
            getShortcuts()
        }
        else
        {
            
            self.uiShortcutsView.isHidden = true
        }
    }

    func getShortcuts()
    {
        let shortcutsInteractor = MZShortcutsInteractor()
        shortcutsInteractor.getShortcuts { (results, error) in
            if error == nil
            {
                for vc in self.childViewControllers
                {
                    if vc.isKind(of: MZShortcutsViewController.self)
                    {
                        (vc as! MZShortcutsViewController).myShortcuts = results as! [MZShortcutViewModel]
                        (vc as! MZShortcutsViewController).tableView.reloadSections(NSIndexSet(index:0) as IndexSet, with: UITableViewRowAnimation.automatic)
                        (vc as! MZShortcutsViewController).hideLoadingView()
                    }
                }
            }
            else
            {
                for vc in self.childViewControllers
                {
                    if vc.isKind(of: MZShortcutsViewController.self)
                    {
                        (vc as! MZShortcutsViewController).hideLoadingView()
                        break
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func reloadData()
    {
        self.cardsView.refreshCards()

    }
}
