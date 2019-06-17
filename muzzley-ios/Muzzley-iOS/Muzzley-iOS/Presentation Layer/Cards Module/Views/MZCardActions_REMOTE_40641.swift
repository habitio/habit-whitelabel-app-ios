//
//  MZCardButtonsArray.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 18/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
import QuartzCore
import OAStackView

@objc protocol MZCardActionsDelegate: NSObjectProtocol
{
    func gotoStageTapped(card: MZCardViewModel, action: MZActionViewModel)
    func replyTapped(card: MZCardViewModel, action: MZActionViewModel)
    func browseTapped(card: MZCardViewModel, action: MZActionViewModel, url: NSURL)
	func pubMQTT(card: MZCardViewModel, action: MZActionViewModel, topic: String, payload: NSDictionary)
    func doneTapped(card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    func dismissTapped(card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    func showInfo(card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    func actionTapped(card: MZCardViewModel, action: MZActionViewModel)
    
    func nextField(card: MZCardViewModel)
    func resetCard(card: MZCardViewModel)
}

class MZCardActions : MZBaseCell
{
    var feedbackView : UIView? = nil

    private enum BtnRows: Int {
        case RowCancel = 0,
        RowNext
    }
    
    @IBOutlet weak var actionsContainer: UIView!
    
    var stackView : OAStackView?
    var delegate: MZCardActionsDelegate?
    
    var actions: [MZActionViewModel]?
    var actionButtons: [MZColorButton] = []

    override func setCardViewModel(viewModel: MZCardViewModel)
    {
        super.setCardViewModel(viewModel)
        self.actions = self.stage!.actions
        
        self.stackView?.removeFromSuperview()
        self.stackView = nil
        
        self.feedbackView?.removeFromSuperview()
        self.feedbackView = nil

        if self.card!.state != MZCardViewModel.CardState.None
        {
            self.setFeedbackView()
        } else {
            self.setActionButtons()
        }
    }
    
    func setFeedbackView()
    {
        switch self.card!.state {
        case MZCardViewModel.CardState.Loading:
            feedbackView = NSBundle.mainBundle().loadNibNamed("MZCardLoadingFeedback", owner: nil, options: nil)![0] as? UIView
            break
        case MZCardViewModel.CardState.Success:
            feedbackView = NSBundle.mainBundle().loadNibNamed("MZCardSuccessFeedback", owner: nil, options: nil)![0] as? UIView
            break
        case MZCardViewModel.CardState.Error:
            feedbackView = NSBundle.mainBundle().loadNibNamed("MZCardErrorFeedback", owner: nil, options: nil)![0] as? UIView
            break
        default:
            break
        }
        
        if feedbackView != nil
        {
            self.actionsContainer!.addSubview(self.feedbackView!)
            self.feedbackView!.translatesAutoresizingMaskIntoConstraints = false
            if let loadingView: MZCardLoadingFeedback = self.feedbackView! as? MZCardLoadingFeedback
            {
                loadingView.colorTextAndIndicator = self.card!.colorActionBarText!
            }

            let dBindings = ["feedbackView": self.feedbackView!]
            let VConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[feedbackView]|", options: .AlignAllTop, metrics: nil, views: dBindings)
            self.actionsContainer!.addConstraints(VConstraint)
            let HConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[feedbackView]|", options: .AlignAllTop, metrics: nil, views: dBindings)
            self.actionsContainer!.addConstraints(HConstraint)
        }
    }
    
    func setActionButtons()
    {
        actionButtons = []
        
        if ((self.stage!.unfoldedFieldsIndex + 1) == self.stage!.fields.count || self.stage!.fields.count <= 1)
        {
            if let actions : [MZActionViewModel] = self.actions
            {
                for (i, action) in actions.enumerate() {
                    let actionButton = self.getNewActionButton()
                    actionButton.setTitle(action.label.uppercaseString, forState: .Normal)
                    switch action.role
                    {
                    case .Primary:
                        actionButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
                    default: break
                    }
                    
                    switch action.icon
                    {
                    case .Info:
                        let image = UIImage(named: "infoCards")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                        actionButton.setImage(image)
                        actionButton.tintColor = self.card!.colorActionBarText
                    default: break
                    }
                    
                    actionButton.tag = i
                    actionButtons.append(actionButton)
                }
            }
        } else {
            for i in 0...1 {
                let actionButton = self.getNewActionButton()
                switch i
                {
                case BtnRows.RowCancel.rawValue:
                    actionButton.setTitle(NSLocalizedString("mobile_next", comment: "").uppercaseString, forState: UIControlState.Normal)
                    actionButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
                case BtnRows.RowNext.rawValue:
                    actionButton.setTitle(NSLocalizedString("mobile_cancel", comment: "").uppercaseString, forState: UIControlState.Normal)
                    
                default: break
                }
                actionButton.tag = i
                actionButtons.append(actionButton)
            }
        }
        
        self.stackView = OAStackView(arrangedSubviews: actionButtons)
        self.stackView!.translatesAutoresizingMaskIntoConstraints = false
        
        self.actionsContainer!.addSubview(self.stackView!)
        let dBindings = ["stackView": self.stackView!]
        
        let VConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[stackView]|", options: .AlignAllTop, metrics: nil, views: dBindings)
        self.actionsContainer!.addConstraints(VConstraint)
        
        let HConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]", options: .AlignAllTop, metrics: nil, views: dBindings)
        self.actionsContainer!.addConstraints(HConstraint)
    }
    
    
    func getNewActionButton () -> MZColorButton
    {
        let actionButton : MZColorButton = MZColorButton()
        actionButton.setTitleColor(self.card!.colorActionBarText, forState: .Normal)
        actionButton.contentEdgeInsets = UIEdgeInsetsMake(0,16,0,16)
        let disabledColor = self.card!.colorActionBarText?.colorWithAlphaComponent(0.3)
        actionButton.setTitleColor(disabledColor, forState: .Disabled)
        actionButton.defaultBackgroundColor = UIColor.clearColor()
        actionButton.highlightBackgroundColor = self.card!.colorActionBarText?.colorWithAlphaComponent(0.1)
        actionButton.cornerRadiusScale = 0
        actionButton.titleLabel?.font = UIFont.mediumFontOfSize(12)
        actionButton.addTarget(self, action: #selector(MZCardActions.didTapAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
        return actionButton
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.actionsContainer!.backgroundColor = self.card!.colorActionBarBackground
    }
    
    override func drawRect(rect: CGRect)
    {
        super.drawRect(rect)        
        
        self.showShadowAndRoundCorners(self.baseView!.bounds, corners: UIRectCorner.BottomLeft.union(.BottomRight), radius: CORNER_RADIUS, rowPosition: .Last)
    }

    
    func didTapAction(sender : UIButton)
    {
        let indexAction = sender.tag
        let action = self.actions![indexAction]
        
        if ((self.stage!.unfoldedFieldsIndex + 1) == stage!.fields.count || self.stage!.fields.count <= 1)
        {
            delegate?.actionTapped(self.card!, action: action)
            
            if (action.type == MZActionViewModel.key_gotoStage) {
                delegate?.gotoStageTapped(self.card!, action: action)
            } else
            if (action.type == MZActionViewModel.key_reply) {
                delegate?.replyTapped(self.card!, action: action)
            } else
            if (action.type == MZActionViewModel.key_browse) {
                delegate?.browseTapped(self.card!, action:action, url: NSURL(string: (action.args.url))!)
            } else
            if (action.type == MZActionViewModel.key_done) {
                delegate?.doneTapped(self.card!, action: action, stage: stage!)
            } else
            if (action.type == MZActionViewModel.key_dismiss) {
                delegate?.dismissTapped(self.card!, action: action, stage: stage!)
            }
            if (action.type == MZActionViewModel.key_showInfo) {
                delegate?.showInfo(self.card!, action: action, stage: stage!)
            }
        } else {
            if (indexAction == 1) {
                delegate?.resetCard(self.card!)
            } else
            if (indexAction == 0) {
                delegate?.nextField(self.card!)
            }
        }
    }
}
