//
//  MZUserPhotoEditControllerViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZUserPhotoEditControllerViewController: BaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var takePhotoButton: MZColorButton!
    @IBOutlet weak var libraryButton: MZColorButton!
    @IBOutlet weak var doneButton: MZColorButton!
    
    internal var profilePhotoURL: URL?
    
    fileprivate enum Buttons: Int {
        case takePhoto = 200,
        library,
        done
    }
    
    fileprivate var wireframe: UserProfileWireframe!
    
    convenience init(withWireframe wireframe: UserProfileWireframe) {
        self.init(nibName: "MZUserPhotoEditControllerViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupInterface()
    }
    
    fileprivate func setupInterface() {
        self.title = NSLocalizedString("mobile_edit_photo_title", comment: "")
        let background: UIView = UIView(frame: self.view.frame)
        background.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.1)
        self.view.insertSubview(background, at: 0)
        
        if self.profilePhotoURL != nil {
            self.userPhotoImageView.setImageWith(self.profilePhotoURL!, placeholderImage: UIImage(named: "icon_guest_profile"))
        } else {
            self.userPhotoImageView.image = UIImage(named: "icon_guest_profile")
        }
        
        self.userPhotoImageView.layer.cornerRadius = self.userPhotoImageView.bounds.size.height / 2.0
        self.userPhotoImageView.layer.masksToBounds = true
        
        self.hintLabel.text = NSLocalizedString("mobile_edit_photo_text", comment: "")
        self.takePhotoButton.setTitle(NSLocalizedString("mobile_take_photo", comment: ""), for: .normal)
        self.takePhotoButton.isHidden = !UIImagePickerController.isSourceTypeAvailable(.camera)
        self.libraryButton.setTitle(NSLocalizedString("mobile_choose_library", comment: ""), for: .normal)
        self.doneButton.setTitle(NSLocalizedString("mobile_save", comment: ""), for: .normal)
        self.doneButton.isEnabled = false
        
        // TODO: - configure hint label attributtes
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func openPhotoSourceAction(_ sender: AnyObject) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        switch (sender as! UIButton).tag {
        case Buttons.takePhoto.rawValue:
            picker.sourceType = .camera
        case Buttons.library.rawValue:
            picker.sourceType = .photoLibrary
            
        default: break
        }
        
        self.wireframe.parent?.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        // TODO: update model
    }
    
    
    // MARK: - UIImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.doneButton.isEnabled = true
        // TODO: deal with image choosed
        
        picker.dismiss(animated: true, completion: nil)
    }

}
