//
//  MZCardCell.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/10/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import UIKit


@objc protocol MZCardCellDelegate: NSObjectProtocol {
    func removeCard(_ card : MZCardViewModel)
    func showPullToRefresh()
    func showCardInfo(cardVM: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    func exitCardInfo()
    func cardContentDidChange(indexPath : IndexPath)
}

class MZCardCell: UITableViewCell,
    UITableViewDelegate,
    UITableViewDataSource,
    MZCardTitleViewDelegate,
    MZCardActionsDelegate,
    MZCardLocationPickerDelegate,
    MZCardDevicesPickerDelegate,
    MZCardDatePickerDelegate,
    MZCardAdsScrollDelegate,
    MZCardAdCellDelegate,
    MZCardLocationPickerViewControllerDelegate,
    MZAddDevicePopupViewControllerDelegate
{

    
 
    
    // This sets the order in which the card fields should appear.
    let CARD_IMAGE_INDEX = 0
    let CARD_TITLE_INDEX = 1
    let CARD_TEXT_INDEX = 2
    let CARD_FIELDS_INDEX = 3
    let CARD_ACTIONS_INDEX = 4
    
    // Time that the action feedback should stay visible (success/error)
    let DELAY_FEEDBACK = 2

    
    @IBOutlet weak var uiBackgroundView: UIView!
    // UI Outlets
    @IBOutlet weak var uiOverlayView: UIView!
    @IBOutlet weak var uiCardStackView: UIStackView!
    
    // Class variables
    var card : MZCardViewModel?
    var indexPath : IndexPath?
    var currentStageIndex : Int = 0
    
    
    var delegate : MZCardCellDelegate?
    var parentViewController : UIViewController?
    var cardsInteractor : MZCardsInteractor?
    var cellsOrder: Array<Int> = []
    
    // Tableview that displays the menu with the card options on ...
    var tableViewPopup = UITableView()
    var tableViewPopupItems : Array<String> = []
    
    var isFirstRender = true
    
    func setCardViewModel(viewModel : MZCardViewModel, parentViewController: UIViewController, indexPath : IndexPath)
    {
        self.card = viewModel
        self.parentViewController = parentViewController
        self.indexPath = indexPath
        self.cardsInteractor = MZCardsInteractor()

        self.isFirstRender = true
        updateCard()
    }
    
    /// Returns an array with the order in which the fields of the card should be displayed
    func getFieldsOrder(card: MZCardViewModel, stage: MZStageViewModel) -> [Int]
    {
        var arrayOrder = [Int]()
        if stage.imageUrl != nil
        {
            arrayOrder.append(self.CARD_IMAGE_INDEX)
        }

        if (stage.title != nil && !stage.title!.isEmpty) || (card.title != nil && !card.title!.isEmpty) || !card.feedback.isEmpty
        {
            arrayOrder.append(self.CARD_TITLE_INDEX)
        }
        
        if stage.text != nil && !stage.text.content.isEmpty
        {
            arrayOrder.append(self.CARD_TEXT_INDEX)
        }

        if stage.fields != nil && stage.fields.count > 0
        {
            for i in 0...stage.unfoldedFieldsIndex
            {
                arrayOrder.append(self.CARD_FIELDS_INDEX)
            }
        }

        if stage.actions != nil && stage.actions.count > 0
        {
            arrayOrder.append(self.CARD_ACTIONS_INDEX)
        }

        return arrayOrder
    }

    
    // Updates the card according the viewmodel state
    func updateCard()
    {
       
        for item in self.uiCardStackView.arrangedSubviews
        {
            self.uiCardStackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
        
        self.contentView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1)
        self.currentStageIndex = self.card!.unfoldedStagesIndex
        let cellsOrder = getFieldsOrder(card: card!, stage: card!.stages[currentStageIndex])
        let firstFieldIndex = cellsOrder.index(of: self.CARD_FIELDS_INDEX)
       
        
        for index in 0...cellsOrder.count-1
        {
            switch cellsOrder[index]
            {
            case self.CARD_IMAGE_INDEX:
                if card!.stages[currentStageIndex].imageUrl != nil
                {
                    let cardImageView = MZCardImageView()
                    cardImageView.setCardViewModel(card!)
                    self.parentViewController!.addChildViewController(cardImageView)
                    self.uiCardStackView.addArrangedSubview(cardImageView.view)
                }
                break
                
            case self.CARD_TITLE_INDEX:
                let cardTitleView = MZCardTitleView()
                cardTitleView.setCardViewModel(card!)
                cardTitleView.delegate = self
                self.parentViewController!.addChildViewController(cardTitleView)
                self.uiCardStackView.addArrangedSubview(cardTitleView.view)
                break
                
            case self.CARD_TEXT_INDEX:
                let cardTextView = MZCardTextView()
                cardTextView.setCardViewModel(card!)
                self.parentViewController!.addChildViewController(cardTextView)
                self.uiCardStackView.addArrangedSubview(cardTextView.view)
                break
                
            case self.CARD_ACTIONS_INDEX:
                let cardActionsView = MZCardActions()
                cardActionsView.setCardViewModel(card!)
                cardActionsView.delegate = self
                self.parentViewController!.addChildViewController(cardActionsView)
                self.uiCardStackView.addArrangedSubview(cardActionsView.view)
                break
                
            case self.CARD_FIELDS_INDEX:
                let field = card!.stages[currentStageIndex].fields[index-firstFieldIndex!]
                
                switch(field.type)
                {
                case MZFieldViewModel.key_location:
                    let picker = MZCardLocationPicker()
                    picker.setViewModel(card!, fieldViewModel: field)
                    picker.delegate = self
                    self.parentViewController!.addChildViewController(picker)
                    self.uiCardStackView.addArrangedSubview(picker.view)
                    break
                    
                case MZFieldViewModel.key_time:
                    let picker = MZCardDatePicker()
                    picker.setViewModel(card!, fieldViewModel: field)
                    picker.delegate = self
                    self.parentViewController!.addChildViewController(picker)
                    self.uiCardStackView.addArrangedSubview(picker.view)
                    break
                    
                case MZFieldViewModel.key_deviceChoice:
                    let picker = MZCardDevicesPicker()
                    picker.setViewModel(card!, fieldViewModel: field)
                    picker.delegate = self
                    self.parentViewController!.addChildViewController(picker)
                    self.uiCardStackView.addArrangedSubview(picker.view)
                    break
                    
                case MZFieldViewModel.key_text:
                    let picker = MZCardTextField()
                    picker.setViewModel(card!, fieldViewModel: field)
//                    picker.delegate = self
                    self.parentViewController!.addChildViewController(picker)
                    self.uiCardStackView.addArrangedSubview(picker.view)
                    break
                    
                case MZFieldViewModel.key_singleChoice,
                     MZFieldViewModel.key_multiChoice:

                    let picker = MZCardChoicePicker()
                    picker.setViewModel(card!, fieldViewModel: field)
//                    picker.delegate = self
                    self.parentViewController!.addChildViewController(picker)
                    self.uiCardStackView.addArrangedSubview(picker.view)
                    break
                    
                case MZFieldViewModel.key_adsList:
                    let picker = MZCardAdsScroll()
                    picker.setViewModel(card!, fieldViewModel: field, indexPath : self.indexPath!)
                    picker.delegate = self
                    self.parentViewController!.addChildViewController(picker)
                    self.uiCardStackView.addArrangedSubview(picker.view)
                    break
                    
                default:
                    break
                }
                
                
                break
                
            default:
                    break
            }
        
        }

        if !self.isFirstRender
        {
            self.delegate?.cardContentDidChange(indexPath: self.indexPath!)
        }
        self.isFirstRender = false
    }
    
    

    // UIStackView event for tapping an element. Commented here because we do not want selection to occur
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        //  super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    // Calls CardsViewController delegate to remove the card from the list
    func hideCard()
    {
        self.delegate?.removeCard(card!)
    }
    
    //
    func hideFeedback()
    {
        self.hideOverlay()
        
        self.card!.state = MZCardViewModel.CardState.none
        self.updateCard()
    }
    
    /// Overlay
    func showOverlay()
    {
        self.uiOverlayView!.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.6)
        self.uiOverlayView!.alpha = 0
        self.uiOverlayView.isHidden = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideFeedback))
        tap.delegate = self
        self.uiOverlayView!.addGestureRecognizer(tap)

        UIView.animate(withDuration: 0.3)
        {
            self.uiOverlayView!.alpha = 1
            self.tableViewPopup.frame = CGRect(x: 0.0, y: CGFloat(self.uiCardStackView.frame.size.height) - 40 * CGFloat(self.tableViewPopupItems.count), width: self.uiCardStackView.frame.size.width, height: 40.0 * CGFloat(self.tableViewPopupItems.count))
        }
    }

    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tableViewPopup) == true {
            return false
        }
        return true
    }
    func hideOverlay()
    {
        if self.tableViewPopup != nil
        {
            self.tableViewPopup.removeFromSuperview()

        }
        if self.uiOverlayView.alpha == 1
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.uiOverlayView.alpha = 0
            }, completion: { (finished) in
                self.uiOverlayView.isHidden = true
            })
        }
    }
    
    
    /// Card states
   func showSuccess()
    {
        self.card!.state = MZCardViewModel.CardState.success
        self.updateCard()
        self.perform(#selector(hideCard), with: nil, afterDelay: TimeInterval(DELAY_FEEDBACK))
    }

    func showError()
    {
        self.card!.state = MZCardViewModel.CardState.error
        self.updateCard()
        self.perform(#selector(hideFeedback), with: nil, afterDelay: TimeInterval(DELAY_FEEDBACK))

        // Hide feedback?
    }
    
    /// DELEGATES
    
    // MZCardTitleViewDelegate
    func feedbackButtonTappedWithCard(_ card: MZCardViewModel)
    {
        self.tableViewPopupItems = card.feedback
        self.showOverlay()

        let height : CGFloat = 40.0 * CGFloat(self.tableViewPopupItems.count)

        self.tableViewPopup = UITableView(frame: CGRect(x: 0, y: 0, width: self.uiCardStackView.frame.width, height: height))
        self.tableViewPopup.allowsSelection = true
        self.tableViewPopup.allowsMultipleSelection = false
        self.tableViewPopup.register(UITableViewCell, forCellReuseIdentifier: "Cell")
        self.tableViewPopup.backgroundColor = UIColor.white
        self.tableViewPopup.delegate = self
        self.tableViewPopup.dataSource = self

        let feedbackHeight = self.uiCardStackView.arrangedSubviews[0].frame.origin.y
        self.tableViewPopup.frame = CGRect(x: 40, y: feedbackHeight + 30, width: self.uiCardStackView.frame.size.width - 48, height: height)

        self.tableViewPopup.layer.masksToBounds = false
        self.tableViewPopup.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.tableViewPopup.layer.shadowColor = UIColor.muzzleyGray2Color(withAlpha: 1).cgColor
        self.tableViewPopup.layer.shadowOpacity = 0.4
        self.tableViewPopup.layer.shadowRadius = 4

        self.uiOverlayView.addSubview(self.tableViewPopup)
    }
    
    // MZCardActionsDelegate
    func gotoStageTapped(_ card: MZCardViewModel, action: MZActionViewModel) {
        var currentStage = card.stages[card.unfoldedStagesIndex]
        currentStage.unfoldedFieldsIndex = 0
        self.currentStageIndex = card.unfoldedStagesIndex
        self.card!.unfoldedStagesIndex = action.args.nStage
        self.updateCard()
    }
    
    func replyTapped(_ card: MZCardViewModel, action: MZActionViewModel) {
        self.card!.state = MZCardViewModel.CardState.loading
        
        self.showLoadingCard()

        self.cardsInteractor?.sendActionCard(card, action: action, completion: { (error) in
            if error == nil
            {
                self.showSuccess()
            }
            else
            {
                self.showError()
            }
        })
    }
    
    func showLoadingCard()
    {
        self.card?.state = MZCardViewModel.CardState.loading
        self.updateCard()
    }
    
    
    func browseTapped(_ card: MZCardViewModel, action: MZActionViewModel, url: URL) {
        UIApplication.shared.openURL(url)
    }
    
    func pubMQTT(_ card: MZCardViewModel, action: MZActionViewModel, topic: String, payload: NSDictionary) {
        
    }
    
    func doneTapped(_ card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel) {
       //  Show loading
        self.cardsInteractor?.sendActionCard(card, action: action, stage: stage, completion: { (error) in

            if(error == nil)
            {
                self.showSuccess()
            }
            else
            {
                self.showError()
                MZAnalyticsInteractor.cardFinishEvent(card.identifier, cardClass: card.cardModel.className, cardType: card.cardModel.type, action: action.type, detail: error != nil ? error!.description : nil)
            }
        })
    }
    
    func dismissTapped(_ card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel) {
        self.cardsInteractor?.sendActionCard(card, action: action, stage: stage, completion: { (error) in
        MZAnalyticsInteractor.cardFinishEvent(card.identifier, cardClass: card.cardModel.className, cardType: card.cardModel.type, action: action.type, detail: error != nil ? error!.description : nil)
                    })
        hideCard()
    }
    
    func showInfo(_ card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel) {
        self.delegate?.showCardInfo(cardVM: card, action: action, stage: stage)

    }
    
    func actionTapped(_ card: MZCardViewModel, action: MZActionViewModel) {
        self.cardsInteractor?.sendNotifyCard(card, action: action)

        if action.refreshAfter
        {
            self.delegate?.showPullToRefresh()
        }

        if action.pubMQTT != nil
        {
            self.cardsInteractor?.pubMQTT(action.pubMQTT!.topic, payload: action.pubMQTT!.payload)
        }
    }
    
    func nextField(_ card: MZCardViewModel) {
        let stage = card.stages[card.unfoldedStagesIndex]
        if(stage.fields.count > 0)
        {
            stage.unfoldedFieldsIndex += 1
        }
        
        updateCard()
    }
    
    func resetCard(_ card: MZCardViewModel) {
        self.currentStageIndex = 0
        updateCard()
    }

    func mapTapped(_ coordinates: CoordinatesTemp?, field: MZFieldViewModel) {
        var vc = MZCardLocationPickerViewController(nibName: "MZCardLocationPickerViewController", bundle: Bundle.main)
        vc.delegate = self
        vc.coordinates = coordinates
        vc.indexPath = self.indexPath
        vc.setup(field)

        
        (self.parentViewController! as! MZCardsViewController).parentWireframe?.push(vc, animated: true)
        
//        self.parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    func didMapChooseSetLocation(_ result: MZLocationPlaceholderViewModel, objectToUpdate: AnyObject, indexPath: IndexPath?) {
        
        let fieldToUpdate = objectToUpdate as! MZFieldViewModel
        fieldToUpdate.setValue(result)
        self.updateCard()
//        self.parentViewController?.dismiss(animated: true, completion: nil)

    }
    
    func addDeviceTapped(_ fieldVM: MZFieldViewModel, card: MZCardViewModel) {
        let deviceSelectionVC = MZAddDevicePopupViewController(interactor: self.cardsInteractor, fieldVM: fieldVM, filter: fieldVM.filters as [AnyObject], card: card)
        
        deviceSelectionVC.delegate = self
        if(indexPath != nil)
        {
            deviceSelectionVC.indexPath = indexPath as! NSIndexPath
        }

    (self.parentViewController! as! MZCardsViewController).parentWireframe?.push(deviceSelectionVC, animated: true)
    }
    
    func removeDeviceTapped(_ indexPath: IndexPath?) {
        self.delegate?.cardContentDidChange(indexPath: self.indexPath!)
    }
    
    
    func didDeviceChooseDone(_ card: MZCardViewModel) {
        updateCard()
    }
    

    func datePickerToggled() {
//        self.delegate?.cardContentDidChange(indexPath: self.indexPath!)
    }
    
    func buttonTapped(_ viewModel: MZFieldViewModel) {
        
    }
    
    func onAdTap(_ adsViewModel: MZAdsPlaceholderViewModel) {
        self.showProductDetailForCard(cardId: self.card!.identifier, detailUrl: adsViewModel.detailUrl)
    }
    
    func showProductDetailForCard(cardId : String, detailUrl: String)
    {
//        let productVC = MZProductViewController(parentWireframe: parentWireframe!, interactor: self.cardsInteractor!)
//        productVC.cardId = cardId
//        productVC.detailUrl = detailUrl
//        self.parentWireframe?.push(productVC, animated: true)
    }

    

    
    
    /// Feedback tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            return self.tableViewPopupItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tableViewPopupItem = self.tableViewPopupItems[indexPath.row]
        let cell = self.tableViewPopup.dequeueReusableCell(withIdentifier: "Cell")
        cell!.textLabel!.text = NSLocalizedString(tableViewPopupItem, comment: tableViewPopupItem)
        cell!.textLabel!.font = UIFont.regularFontOfSize(16)
        cell!.textLabel?.textColor = UIColor.muzzleyGray2Color(withAlpha: 1)
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.tableViewPopupItems[indexPath.row]
        self.hideCard()
        self.sendHideOption(hideOption: item)
        self.hidePopupItemsTableView()
    }
    
    func sendHideOption(hideOption: String)
    {
        MZAnalyticsInteractor.cardHideEvent(self.card!.identifier, cardClass: self.card!.cardModel.className, cardType: self.card!.cardModel.type, value: hideOption)
        self.cardsInteractor!.sendHideCard(self.card!, hideOption: hideOption, completion: nil)
    }
    
    func hidePopupItemsTableView()
    {
        self.tableViewPopup.removeFromSuperview()
        if(!self.uiOverlayView.isHidden)
        {
            self.uiOverlayView.isHidden = true
        }
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.uiBackgroundView.layer.cornerRadius = CORNER_RADIUS
        self.uiBackgroundView.clipsToBounds = true
        self.uiBackgroundView.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.uiBackgroundView.layer.shadowOpacity = 0.2
        self.uiBackgroundView.layer.shadowColor = UIColor.black.cgColor
        self.uiBackgroundView.layer.shadowRadius = 1
        self.uiBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: self.uiBackgroundView!.bounds, cornerRadius: self.uiBackgroundView!.layer.cornerRadius).cgPath
    }


    
}
