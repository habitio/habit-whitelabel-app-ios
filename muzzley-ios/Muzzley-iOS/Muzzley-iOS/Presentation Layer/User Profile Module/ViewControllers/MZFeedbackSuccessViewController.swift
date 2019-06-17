//
//  MZFeedbackSuccessViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 30/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZFeedbackSuccessViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var doneButton: MZColorButton!
    
    fileprivate var wireframe: UserProfileWireframe!
    
    convenience init(withWireframe wireframe: UserProfileWireframe) {
        self.init(nibName: "MZFeedbackSuccessViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupInterface()
    }
    
    fileprivate func setupInterface() {
        self.title = NSLocalizedString("mobile_feedback_title", comment: "")
        let background: UIView = UIView(frame: self.view.frame)
        background.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.1)
        self.view.insertSubview(background, at: 0)
        
        self.titleLabel.font = UIFont.semiboldFontOfSize(20)
        self.titleLabel.text = NSLocalizedString("mobile_feedback_success_title", comment: "")
        self.descriptionLabel.font = UIFont.lightFontOfSize(16)
        self.descriptionLabel.text = NSLocalizedString("mobile_feedback_success_text", comment: "")
        
        self.doneButton.setTitle(NSLocalizedString("mobile_done", comment: ""), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UIButtons Actions
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.wireframe.parent?.popToRootViewController(animated: true)
    }

}
