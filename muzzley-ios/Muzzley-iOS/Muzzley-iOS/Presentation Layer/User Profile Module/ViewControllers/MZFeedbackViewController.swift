//
//  MZFeedbackViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZFeedbackViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextView: MZTextView!
    @IBOutlet weak var doneButton: MZColorButton!
    
    fileprivate var loadingView: UIView!

    
    fileprivate enum Options: Int {
        case first = 200,
        second,
        third,
        fourth
    }
    
    fileprivate var wireframe: UserProfileWireframe!
    fileprivate var selectedOption: Int?
    
    convenience init(withWireframe wireframe: UserProfileWireframe) {
        self.init(nibName: "MZFeedbackViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.dismissKeyboardWithTap()
        
        self.setupInterface()
        
        MZAnalyticsInteractor.feedbackStartEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scrollView.startObservingKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.scrollView.stopObservingKeyboardNotifications()
    }
    
    fileprivate func setupInterface() {
        self.title = NSLocalizedString("mobile_feedback_title", comment: "")
        let background: UIView = UIView(frame: self.view.frame)
        background.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.1)
        self.view.insertSubview(background, at: 0)
        
        self.contentView.frame = self.view.frame
        
        self.titleLabel.textColor = UIColor.muzzleyGray2Color(withAlpha: 1)
        self.titleLabel.text = NSLocalizedString("mobile_feedback_text", comment: "")
        
        (self.view.viewWithTag(Options.first.rawValue) as! MZFeedbackButton).setTitle(NSLocalizedString("mobile_feedback_option1", comment: ""), for: .normal)
        (self.view.viewWithTag(Options.second.rawValue) as! MZFeedbackButton).setTitle(NSLocalizedString("mobile_feedback_option2", comment: ""), for: .normal)
        (self.view.viewWithTag(Options.third.rawValue) as! MZFeedbackButton).setTitle(NSLocalizedString("mobile_feedback_option3", comment: ""), for: .normal)
        (self.view.viewWithTag(Options.fourth.rawValue) as! MZFeedbackButton).setTitle(NSLocalizedString("mobile_feedback_option4", comment: ""), for: .normal)
        
        self.commentTextView.text = NSLocalizedString("mobile_feedback_hint", comment: "")
        self.commentTextView.textColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        self.commentTextView.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        
        self.doneButton.setTitle(NSLocalizedString("mobile_send", comment: ""), for: .normal)
        self.doneButton.isEnabled = false
        
        // TODO: - configure hint label attributtes
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - UITextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == NSLocalizedString("mobile_feedback_hint", comment: "") {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.commentTextView.frame.origin.y), animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.doneButton.isEnabled = self.isCommentValid()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = NSLocalizedString("mobile_feedback_hint", comment: "")
            textView.textColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        }
    }
    

    // MARK: - UIButtons Actions
	
    @IBAction func selectResponseAction(_ sender: AnyObject) {
        (self.view.viewWithTag(Options.first.rawValue) as! MZFeedbackButton).select = false
        (self.view.viewWithTag(Options.second.rawValue) as! MZFeedbackButton).select = false
        (self.view.viewWithTag(Options.third.rawValue) as! MZFeedbackButton).select = false
        (self.view.viewWithTag(Options.fourth.rawValue) as! MZFeedbackButton).select = false
        (sender as! MZFeedbackButton).select = true
        self.selectedOption = (sender as! MZFeedbackButton).tag
        self.doneButton.isEnabled = self.isCommentValid()
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        var answers: [[String: Any]] = [[String: AnyObject]]()
        
        if self.optionFromSelected() != ""
        {
            answers.append(["id": "when-use-muzzley-option", "answer": [self.optionFromSelected()]])
        }
        
        if self.commentTextView.text != "" && self.commentTextView.text != NSLocalizedString("mobile_feedback_hint", comment: "")
        {
            let version: String = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
			 //let version: String = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) + (((Bundle.main.infoDictionary!["CFBundleIcons"]!["CFBundlePrimaryIcon"]!!["CFBundleIconFiles"] as! [AnyObject]).first as! String).lowercased().range(of: "beta") != nil ? "-beta" : "") + "/" + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
			
            let feedbackText : String =  self.commentTextView.text + ". Version: iOS/" + version
            
            answers.append(["id": "when-use-muzzley-comment", "answer": [feedbackText]])
        }
        
        let parameters: [String: AnyObject] = ["id": "general-survey-201602" as AnyObject,
            "answers": answers as AnyObject]
        
        self.textViewDidEndEditing(self.commentTextView)
        self.showLoadingView()
		
		MZUserWebService.sharedInstance.postFeedbackForUser(parameters as NSDictionary) { (success, error) in
	            self.hideLoadingView()
            if error == nil {
                MZAnalyticsInteractor.feedbackFinishEvent("when-use-muzzley-option", optionId: self.optionFromSelected(), detail: nil)
            
                let success: MZFeedbackSuccessViewController = MZFeedbackSuccessViewController(withWireframe: self.wireframe)
                self.wireframe.parent?.pushViewController(toEnd: success, animated: true)
            } else {
                MZAnalyticsInteractor.feedbackFinishEvent("when-use-muzzley-option", optionId: self.optionFromSelected(), detail: error?.localizedDescription)
                
                let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                self.wireframe.parent?.present(error, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func optionFromSelected() -> String {
        if self.selectedOption != nil
        {
            switch self.selectedOption!
			{
            case Options.first.rawValue: return "works according needs"
            case Options.second.rawValue: return "features not working"
            case Options.third.rawValue: return "not intuitive"
            case Options.fourth.rawValue: return "more features"
                
            default: return ""
            }
        }
        return ""
    }
    
    fileprivate func isCommentValid() -> Bool
    {
        return self.selectedOption != nil || (!self.commentTextView.text.isEmpty && self.commentTextView.text != NSLocalizedString("mobile_feedback_hint", comment: ""))
    }
    
    //TODO move to unique place to be used anywhere!!!
    internal func showLoadingView() {
        var lFrame: CGRect = self.view.frame
        lFrame.origin.x = 0.0
        lFrame.origin.y = 0.0
        self.loadingView = UIView(frame: lFrame)
        self.loadingView.backgroundColor = UIColor.muzzleyBlackColor(withAlpha: 0.2)
        
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        var frame: CGRect = self.loadingView.frame
        frame.origin.x = frame.size.width / 2.0 - loading.frame.size.width / 2.0
        frame.origin.y = frame.size.height / 2.0 - loading.frame.size.height / 2.0
        frame.size = loading.frame.size
        loading.frame = frame
        self.loadingView.addSubview(loading)
        self.loadingView.alpha = 0.0
        self.view.addSubview(self.loadingView)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.loadingView.alpha = 1.0
            loading.startAnimating()
        }) 
    }
    
    //TODO move to unique place to be used anywhere!!!
    internal func hideLoadingView() {
        if self.loadingView != nil {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.loadingView.alpha = 0.0
                }, completion: { (success) -> Void in
                    if self.loadingView != nil {
                        self.loadingView.subviews.forEach{ $0.removeFromSuperview() }
                        self.loadingView.removeFromSuperview()
                        self.loadingView = nil
                    }
            })
        }
    }
    

    
}
