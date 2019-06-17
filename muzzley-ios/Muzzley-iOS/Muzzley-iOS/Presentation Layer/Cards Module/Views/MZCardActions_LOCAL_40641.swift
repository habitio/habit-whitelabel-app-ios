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
    func gotoStageTapped(_ card: MZCardViewModel, action: MZActionViewModel)
    func replyTapped(_ card: MZCardViewModel, action: MZActionViewModel)
    func browseTapped(_ card: MZCardViewModel, action: MZActionViewModel, url: URL)
	func pubMQTT(_ card: MZCardViewModel, action: MZActionViewModel, topic: String, payload: NSDictionary)
    func doneTapped(_ card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    func dismissTapped(_ card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    func showInfo(_ card: MZCardViewModel, action: MZActionViewModel, stage: MZStageViewModel)
    
    func actionTapped(_ card: MZCardViewModel, action: MZActionViewModel)

   // func navigateTapped(card: MZCardViewModel, action: MZActionViewModel)
  //  func createWorkerTapped(card: MZCardViewModel, action: MZActionViewModel)
    
    func nextField(_ card: MZCardViewModel)
    func resetCard(_ card: MZCardViewModel)
}

class MZCardActions : MZBaseCell
{
    var feedbackView : UIView? = nil

    fileprivate enum BtnRows: Int {
        case rowCancel = 0,
        rowNext
    }
    
    @IBOutlet weak var actionsContainer: UIView!
    
    var stackView : OAStackView?
    var delegate: MZCardActionsDelegate?
    
    var actions: [MZActionViewModel]?
    var actionButtons: [MZColorButton] = []

    override func setCardViewModel(_ viewModel: MZCardViewModel)
    {
        super.setCardViewModel(viewModel)
        self.actions = self.stage!.actions
        
        self.stackView?.removeFromSuperview()
        self.stackView = nil
        
        self.feedbackView?.removeFromSuperview()
        self.feedbackView = nil

        if self.card!.state != MZCardViewModel.CardState.none
        {
            self.setFeedbackView()
        } else {
            self.setActionButtons()
        }
    }
    
    func setFeedbackView()
    {
        switch self.card!.state {
        case MZCardViewModel.CardState.loading:
            feedbackView = Bundle.main.loadNibNamed("MZCardLoadingFeedback", owner: nil, options: nil)![0] as? UIView
            break
        case MZCardViewModel.CardState.success:
            feedbackView = Bundle.main.loadNibNamed("MZCardSuccessFeedback", owner: nil, options: nil)![0] as? UIView
            break
        case MZCardViewModel.CardState.error:
            feedbackView = Bundle.main.loadNibNamed("MZCardErrorFeedback", owner: nil, options: nil)![0] as? UIView
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
            let VConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[feedbackView]|", options: .alignAllTop, metrics: nil, views: dBindings)
            self.actionsContainer!.addConstraints(VConstraint)
            let HConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[feedbackView]|", options: .alignAllTop, metrics: nil, views: dBindings)
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
                for (i, action) in actions.enumerated() {
                    let actionButton = self.getNewActionButton()
                    actionButton.setTitle(action.label.uppercased(), for: .normal)
                    switch action.role
                    {
                    case .primary:
                        actionButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
                    default: break
                    }
                    
                    switch action.icon
                    {
                    case .info:
                        let image = UIImage(named: "infoCards")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
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
                case BtnRows.rowCancel.rawValue:
                    actionButton.setTitle(NSLocalizedString("mobile_next", comment: "").uppercased(), for: UIControlState.normal)
                    actionButton.titleLabel?.font = UIFont.heavyFontOfSize(12)
                case BtnRows.rowNext.rawValue:
                    actionButton.setTitle(NSLocalizedString("mobile_cancel", comment: "").uppercased(), for: UIControlState.normal)
                    
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
        
        let VConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .alignAllTop, metrics: nil, views: dBindings)
        self.actionsContainer!.addConstraints(VConstraint)
        
        let HConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]", options: .alignAllTop, metrics: nil, views: dBindings)
        self.actionsContainer!.addConstraints(HConstraint)
    }
    
    
    func getNewActionButton () -> MZColorButton
    {
        let actionButton : MZColorButton = MZColorButton()
        actionButton.setTitleColor(self.card!.colorActionBarText, for: .normal)
        actionButton.contentEdgeInsets = UIEdgeInsetsMake(0,16,0,16)
        let disabledColor = self.card!.colorActionBarText?.withAlphaComponent(0.3)
        actionButton.setTitleColor(disabledColor, for: .disabled)
        actionButton.defaultBackgroundColor = UIColor.clear
        actionButton.highlightBackgroundColor = self.card!.colorActionBarText?.withAlphaComponent(0.1)
        actionButton.cornerRadiusScale = 0
        actionButton.titleLabel?.font = UIFont.mediumFontOfSize(12)
        actionButton.addTarget(self, action: #selector(MZCardActions.didTapAction(_:)), for: UIControlEvents.touchUpInside)
    
        return actionButton
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.actionsContainer!.backgroundColor = self.card!.colorActionBarBackground
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)        
        
        self.showShadowAndRoundCorners(self.baseView!.bounds, corners: UIRectCorner.bottomLeft.union(.bottomRight), radius: CORNER_RADIUS, rowPosition: .last)
    }

    
    func didTapAction(_ sender : UIButton)
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
                delegate?.browseTapped(self.card!, action:action, url: URL(string: (action.args.url))!)
            } else
//			if (action.type == MZActionViewModel.key_pubMQTT) {
//				delegate?.pubMQTT(self.card!, action:action, topic:action.args.topic, payload: action.args.payload!)
//			} else
            if (action.type == MZActionViewModel.key_done) {
                delegate?.doneTapped(self.card!, action: action, stage: stage!)
            } else
            if (action.type == MZActionViewModel.key_dismiss) {
                delegate?.dismissTapped(self.card!, action: action, stage: stage!)
            }
            if (action.type == MZActionViewModel.key_showInfo) {
                delegate?.showInfo(self.card!, action: action, stage: stage!)
            }
			
          /*  else if (action.type == MZActionViewModel.key_navigate) {
                delegate?.navigateTapped(self.card!)
            } else
            if (action.type == MZActionViewModel.key_createWorker) {
                delegate?.createWorkerTapped(self.card!)
            }*/
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
