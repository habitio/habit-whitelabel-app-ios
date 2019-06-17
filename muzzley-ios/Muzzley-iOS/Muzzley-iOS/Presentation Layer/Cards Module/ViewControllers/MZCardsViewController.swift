//
//  MZCardsViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/11/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZCardsScrollDelegate : NSObjectProtocol
{
    func cardsScrollDetected(_ scrolledUp: Bool)
}

class MZCardsViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    MZRootCardsViewControllerDelegate,
    MZCardCellDelegate,
    MZCardInfoViewDelegate,
    UIGestureRecognizerDelegate,
    MZBlankStateDelegate
{
    @IBOutlet weak var uiClearButtonView: UIView!
    @IBOutlet weak var uiBtClearCards: UIButton!
    @IBOutlet weak var uiCardsTableView: UITableView!
    @IBOutlet weak var uiBlankState: MZBlankStateView!
    @IBOutlet weak var uiCardsView: UIView!
    @IBOutlet weak var uiOverlayView: UIView!
    
    var loadingView = MZLoadingView()
    var cardsScrollDelegate : MZCardsScrollDelegate?
    var parentWireframe : MZRootWireframe?
    
    fileprivate var refreshControl: MZRefreshControl?
    fileprivate var cards = [MZCardViewModel]()
    fileprivate var interactor : MZCardsInteractor?
    var isCardsViewVisible = false
    var pullToRefreshToast : MZToast? // <---- CHECK WHAT THIS IS FOR
    var isFirstTime = true
    var helpPopup : MZCardInfoView?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupInterface()
    }
    
    func setupBlankState()
    {
        self.uiCardsView.isHidden = true
        self.uiBlankState.delegate = self
        self.uiBlankState.setup(blankStateImage: UIImage(named: "BlankStateTimeline")!,
                                blankStateTitle: NSLocalizedString("mobile_cards_blankstate_empty_title", comment: ""),
                                blankStateText: NSLocalizedString("mobile_cards_blankstate_empty_text", comment: ""),
                                blankStatebuttonTitle: nil,
                                loadingStateTitle: NSLocalizedString("mobile_cards_blankstate_empty_title", comment: ""),
                                loadingStateText: NSLocalizedString("mobile_cards_blankstate_loading_text", comment: ""))
        
        self.uiBlankState.setState(state: .blank)
    }

    func blankStateRefreshTriggered() {
        refreshCards()
    }
    
    func blankStateButtonPressed()
    {
        // Do nothing because there's no button for now.
    }
    
    
    
    func setupInterface()
    {
        self.interactor = MZCardsInteractor()
       
        setupBlankState()
        
        self.uiClearButtonView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
        self.uiBtClearCards.setTitle(NSLocalizedString("mobile_clear", comment: ""), for: .normal)
        self.setClearButtonState(enabled: false)
        
        self.uiCardsTableView!.delegate = self
        self.uiCardsTableView!.dataSource = self
        self.uiCardsTableView.rowHeight = UITableViewAutomaticDimension
        self.uiCardsTableView.estimatedRowHeight = 85
        self.uiCardsTableView!.register(UINib(nibName: "MZCardCell", bundle: Bundle.main), forCellReuseIdentifier: "MZCardCell")

        self.uiCardsTableView.backgroundColor = .muzzleyDarkWhiteColor(withAlpha: 1)
       
        self.refreshControl = MZRefreshControl(tableView: self.uiCardsTableView)
        self.refreshControl!.addTarget(self, action: #selector(self.refreshCards), for: .valueChanged)

        getCards()
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    func refreshCards()
    {
        if self.view == nil { return }
        
        if self.view.window == nil { return }
        
        if (self.pullToRefreshToast != nil)
        {
            self.pullToRefreshToast?.dismiss(self)
            self.pullToRefreshToast = nil
        }
        
        var internetReachable = Reachability.forInternetConnection()
        
        if(internetReachable?.currentReachabilityStatus() == NotReachable)
        {
            self.uiBlankState.setState(state: .noInternet)
            return
        }
        
        getCards()
    }
    
    func removeCard(_ card: MZCardViewModel)
    {
        if self.cards.contains(card)
        {
            let index = self.cards.index(of: card)
            self.cards.remove(at:index!)

            let indexPath = IndexPath(row: index!, section: 0)
            self.uiCardsTableView.beginUpdates()
            self.uiCardsTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.uiCardsTableView.endUpdates()
        }
    }
    
    
    func cardsTabDoubleTapped()
    {
        self.uiCardsTableView.setContentOffset(.zero, animated: true)
    }
    
    func cardsTabVisibleStatusUpdate(_ isVisible: Bool)
    {
        self.isCardsViewVisible = isVisible
        if self.isCardsViewVisible
        {
            self.showOnboardings()
        }
    }
    
    func setClearButtonState(enabled: Bool)
    {
        if(self.uiBtClearCards != nil)
        {
            if enabled
            {
                self.uiBtClearCards.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
                self.uiBtClearCards.isUserInteractionEnabled = true
            }
            else
            {
                self.uiBtClearCards.tintColor = UIColor.muzzleyGrayColor(withAlpha: 1)
                self.uiBtClearCards.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func uiBtClearCards_TouchUpInside(_ sender: Any)
    {
        let alert = UIAlertController(title: NSLocalizedString("mobile_clear_cards_confirmation", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
            
//            if !self.refreshControl!.isRefreshing
//            {
//                self.loadingView.updateLoadingStatus(true, container: self.view)
//            }
            
            self.interactor?.deleteAutomationCards(completion: { (error) in
                if(error == nil)
                {
                    self.getCards()
                }
                else
                {
                    self.loadingView.updateLoadingStatus(false, container: self.view)
                }
            })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showOnboardings()
    {
        if self.view == nil { return }
        if self.view.window == nil { return }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if (velocity.y > 0)
        {
            self.cardsScrollDelegate?.cardsScrollDetected(false)
        }
        if (velocity.y < 0)
        {
            self.cardsScrollDelegate?.cardsScrollDetected(true)
        }
    }
    
    
    func showPullToRefresh()
    {
        if self.pullToRefreshToast == nil
        {
            self.pullToRefreshToast = MZToast.showPullToRefreshToastOnScrollview(self.uiCardsTableView)
        }
    }

    func showCardInfo(cardVM: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    {
        
        if helpPopup != nil
        {
            helpPopup!.removeFromSuperview()
        }
        
        helpPopup = Bundle.main.loadNibNamed("MZCardInfoView", owner: self, options: nil)?.first as! MZCardInfoView
        helpPopup?.setCardViewModel(cardVM)
        helpPopup?.setActionViewModel(action)
        helpPopup?.delegate = self
        helpPopup?.frame = self.uiOverlayView.bounds
        self.uiOverlayView.addSubview(helpPopup!)
        
        self.showOverlay()

    }
    
    func exitInfo()
    {
        self.hideOverlay()
        
        if helpPopup != nil
        {
            helpPopup?.removeFromSuperview()
            helpPopup = nil
        }
    }
    
  
    func cardContentDidChange(indexPath: IndexPath)
    {
        self.uiCardsTableView.beginUpdates()
        self.uiCardsTableView.endUpdates()
    }
    
    func exitCardInfo()
    {
        self.exitInfo()
    }
    
    func hideOverlay()
    {
        if self.uiOverlayView.alpha == 1
        {
            UIView.animate(withDuration: 0.3, animations: {
                 self.uiOverlayView.alpha = 0
            }, completion: { (finished) in
                self.uiOverlayView.isHidden = true
            })
        }
    }
    
    func showOverlay()
    {
        self.uiOverlayView!.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.6)
        self.uiOverlayView!.alpha = 0
        self.uiOverlayView.isHidden = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        tap.delegate = self

        self.uiOverlayView!.addGestureRecognizer(tap)

        UIView.animate(withDuration: 0.3)
        {
            self.uiOverlayView!.alpha = 1
        }
    }
    
    func dismissAll()
    {
        self.hideOverlay()
        self.exitCardInfo()
    }
    
    func filterSupportedCards(allCards: [MZCardViewModel]) -> [MZCardViewModel]
    {
        var filteredCards = [MZCardViewModel]()
        
        for card in allCards
        {
            let stagesWithUnsupportedPickers = (card.stages.flatMap { $0.fields.filter({!MZCardsSupported.pickers.contains($0.type)})}).count
            let stagesWithUnsupportedActions = (card.stages.flatMap { $0.actions.filter({!MZCardsSupported.actions.contains($0.type)})}).count

            if stagesWithUnsupportedPickers == 0 && stagesWithUnsupportedActions == 0
            {
                filteredCards.append(card)
            }
        }

        return filteredCards
    }
    
    func getCards()
    {
        self.setClearButtonState(enabled: false)

    
        if self.isFirstTime || self.cards.count  == 0
        {
            self.uiBlankState.setState(state: .loading)
        }
        else
        {
            self.uiBlankState.hide()
            
            if !self.refreshControl!.isRefreshing
            {
                self.loadingView.updateLoadingStatus(true, container: self.view)
            }
        }
        
        self.interactor?.getCards({ (results, error) in
            
            
            var internetReachable = Reachability.forInternetConnection()
            
            if(internetReachable?.currentReachabilityStatus() == NotReachable)
            {
                self.uiBlankState.setState(state: .noInternet)
                return
            }
            
            if self.isFirstTime
            {
                self.isFirstTime = false;
            }
            
        
            if error != nil
            {
                if error?.domain == NSURLErrorDomain &&
                    (error!.code == NSURLErrorNotConnectedToInternet || error!.code == NSURLErrorCannotFindHost)
                {
                    self.uiBlankState.setState(state: .noInternet)
                }
                else
                {
                    self.uiBlankState.setState(state: .error)
                }

                self.cards.removeAll()
                
                if self.refreshControl!.isRefreshing
                {
                    self.refreshControl?.endRefreshing()
                }

                self.loadingView.updateLoadingStatus(false, container: self.view)

                return
            }

            if results != nil
            {
                if results!.count == 0
                {
                    self.cards.removeAll()
                    self.uiBlankState.setState(state: .blank)
                }
                else
                {
                    self.cards.removeAll()
                    
                    self.cards = results as! [MZCardViewModel]
                    self.cards = self.filterSupportedCards(allCards: results as! [MZCardViewModel])

//                   // For testing purposes only
//                    for index in 1...500
//                    {
//                        self.cards.append(contentsOf: self.filterSupportedCards(allCards: results as! [MZCardViewModel]))
//                    }
//                    print("ncards:")
//                    print(self.cards.count)

                    for card in self.cards
                    {
                        if card.type == "automation"
                        {
                            self.setClearButtonState(enabled: true)
                            break
                        }
                    }
                }

                self.uiCardsTableView.reloadData()
                
                if self.refreshControl!.isRefreshing
                {
                    self.refreshControl?.endRefreshing()
                }

            }

            self.loadingView.updateLoadingStatus(false, container: self.view)
            if self.cards.count == 0
            {
                self.uiBlankState.setState(state: .blank)
            }
            else
            {
                self.uiBlankState.hide()
                self.uiCardsView.isHidden = false

            }
        })
    }
    
    /// TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cards != nil
        {
            return cards.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MZCardCell =  self.uiCardsTableView.dequeueReusableCell(withIdentifier: "MZCardCell", for: indexPath) as! MZCardCell
        cell.delegate = self
        cell.setCardViewModel(viewModel: self.cards[indexPath.row], parentViewController: self, indexPath: indexPath)

        return cell
    }
    
   
}
