//
//  MZUserProfileViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZUserProfileDelegate {
    func userProfileDidLogOut(_ userProfile: MZUserProfileViewController)
}

class MZUserProfileViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MZProfilePhotoTableViewCellDelegate, MZRootUserProfileViewControllerDelegate {

    @IBOutlet var tableView: UITableView!
    
    internal var delegate: MZUserProfileDelegate?
	
	internal var socialOptions = [Int]()
	internal var supportOptions = [Int]()
	internal var profileSections = [Int]()
	
	internal var isUserProfileViewVisible = false

	fileprivate enum Rows : Int
	{
		case feedback = 0,
		faq,
		settings,
		facebook,
		twitter,
		blog,
		about,
		logout,
		count
	}
	
	fileprivate enum Sections : Int
	{
		case profile = 0,
		support,
		settings,
		social,
		muzzley,
		count
	}
	

    fileprivate var wireframe: UserProfileWireframe!
    fileprivate var inEditMode: Bool = false
    //fileprivate var userProfile: MZUserProfile?
    fileprivate var isDOBPickerOpen: Bool = false
    fileprivate var selectedGender: Gender = Gender.Male
    fileprivate var debugActive: Bool = false
    
    convenience init(withWireframe wireframe: UserProfileWireframe)
	{
		self.init(nibName: "MZUserProfileViewController", bundle: Bundle.main)
        self.wireframe = wireframe
        self.wireframe.userProfileViewController = self
		
		self.isUserProfileViewVisible = false;

        MZNotifications.register(self, selector: #selector(self.checkIfDebugLogIsToBeDisplayed), notificationKey: MZNotificationKeys.UserProfile.DebugLogEnabled)
        
    }
	
	func userProfileTabVisibleStatusUpdate(_ isVisible: Bool) {
		self.isUserProfileViewVisible = isVisible
	}
	
	func availableOptions()
	{
		socialOptions = [Int]()
		supportOptions = [Int]()
		profileSections = [Int]()
		
		profileSections.append(Sections.profile.rawValue)
		profileSections.append(Sections.support.rawValue)
		
		supportOptions.append(Rows.feedback.rawValue)
		
		let faqUrl = MZThemeManager.sharedInstance.urls.faq
		if faqUrl != nil && !(faqUrl?.absoluteString.isEmpty)!
		{
			supportOptions.append(Rows.faq.rawValue)
		}
		
		profileSections.append(Sections.settings.rawValue)
		let facebookUrl = MZThemeManager.sharedInstance.urls.facebook
		if facebookUrl != nil && !(facebookUrl?.absoluteString.isEmpty)!
		{
			socialOptions.append(Rows.facebook.rawValue)
		}

		let twitterUrl = MZThemeManager.sharedInstance.urls.twitter
		if twitterUrl != nil && !(twitterUrl?.absoluteString.isEmpty)!
		{
			socialOptions.append(Rows.twitter.rawValue)
		}
		
		let blogUrl = MZThemeManager.sharedInstance.urls.blog
		if blogUrl != nil && !(blogUrl?.absoluteString.isEmpty)!
		{
			socialOptions.append(Rows.blog.rawValue)
		}
		
		if(socialOptions.count > 0)
		{
			profileSections.append(Sections.social.rawValue)
		}
		
		profileSections.append(Sections.muzzley.rawValue)
	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		self.setupInterface()
        self.uiReloadData()
        (self.wireframe.parent as! MZRootWireframe).rootViewController.userProfileDelegate = self;

    }
    
    func uiReloadData() {
        self.updateUserInterface()
    }
    
    fileprivate func setupInterface()
	{
		availableOptions()
		
		self.tableView.backgroundColor = UIColor.white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "MZProfilePhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "MZProfilePhotoTableViewCell")
        self.tableView.register(UINib(nibName: "MZImageAndLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "MZImageAndLabelTableViewCell")
        self.tableView.tableFooterView = UIView()
    }
    
    fileprivate func updateUserInterface()
	{
//		MZSession.sharedInstance.loadFromCache { (success) in
			//self.userProfile = MZSessionDataManager.sharedInstance.session.userProfile
			self.reloadData()
//		}
    }
    
    func checkIfDebugLogIsToBeDisplayed()
    {
        self.debugActive = UserDefaults.standard.bool(forKey: "DebugEnabled")
        self.tableView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
	{
        super.viewDidAppear(animated)
        self.checkIfDebugLogIsToBeDisplayed()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileSections.count //Sections.Count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        switch profileSections[section]
		{
			case Sections.profile.rawValue:
				return 1
			
			case Sections.support.rawValue:
				return supportOptions.count
			
			case Sections.settings.rawValue:
				return 1
			
			case Sections.social.rawValue:
				return socialOptions.count

			case Sections.muzzley.rawValue:
				return 2 + (self.debugActive ? 1 : 0)
        
        default: return 0
        }
    }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	{
		if profileSections[section] != Sections.profile.rawValue
		{
			return 35.0
		}
		return 0.0
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
	{
		if profileSections[section] != Sections.profile.rawValue
		{
			let header = view as! UITableViewHeaderFooterView
			header.textLabel?.font = UIFont(name: "SanFranciscoDisplay-Semibold", size: 13)!
			header.textLabel?.textColor = UIColor.muzzleyGray3Color(withAlpha: 1)
		
			view.tintColor = UIColor.groupTableViewBackground
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		switch profileSections[section]
		{
			case Sections.support.rawValue:
				return NSLocalizedString("mobile_user_profile_header_support", comment: "")
			
			case Sections.settings.rawValue:
				return NSLocalizedString("mobile_settings", comment: "")
			
			case Sections.social.rawValue:
				return NSLocalizedString("mobile_user_profile_header_social", comment: "")
			
			case Sections.muzzley.rawValue:
				return MZThemeManager.sharedInstance.appInfo.applicationName
			
			default: return ""
		}
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = UITableViewCell()
        
        switch profileSections[indexPath.section] {
			
        case Sections.profile.rawValue:
            let aCell: MZProfilePhotoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZProfilePhotoTableViewCell", for: indexPath) as! MZProfilePhotoTableViewCell
            
            aCell.selectedGender = self.selectedGender
            aCell.modeEdit = self.inEditMode
            aCell.dateOpened = self.isDOBPickerOpen
            if MZSessionDataManager.sharedInstance.session.userProfile != nil
			{
                aCell.userNameField.text = MZSessionDataManager.sharedInstance.session.userProfile.name
				aCell.profilePhoto = UIImage(named: "icon_guest_profile")!

				let url = URL(string: MZSessionDataManager.sharedInstance.session.userProfile.photoUrl)
				if(url != nil && !(url?.absoluteString.isEmpty)!)
				{
					aCell.profilePhotoImageView.setImageWith(URLRequest(url: url!), placeholderImage: UIImage(named: "icon_guest_profile"), success: { (request, response, image) in
						aCell.profilePhoto = image
					}, failure: { (request, response, error) in
						//
						aCell.profilePhoto = UIImage(named: "icon_guest_profile")!
					})
				}
				
			}
			else
			{
                aCell.userNameField.text = ""
                aCell.profilePhoto = UIImage(named: "icon_guest_profile")!
            }
            aCell.delegate = self
            aCell.userNameField.addTarget(self, action: #selector(MZUserProfileViewController.textFieldValueChanged(_:)), for: .valueChanged)
            aCell.separatorInset = UIEdgeInsetsMake(0.0, UIScreen.main.bounds.size.width, 0.0, 0.0)
		
            cell = aCell
			
        case Sections.support.rawValue:
			
            let aCell: MZImageAndLabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZImageAndLabelTableViewCell", for: indexPath) as! MZImageAndLabelTableViewCell
            switch supportOptions[indexPath.row]
			{
				case Rows.feedback.rawValue:
					aCell.cellImage.image = UIImage(named: "icon_feedback")
					aCell.cellText.text = NSLocalizedString("mobile_feedback_title", comment: "")
					break
				
				case  Rows.faq.rawValue:
					aCell.cellImage.image = UIImage(named: "icon_faq")
					aCell.cellText.text = NSLocalizedString("mobile_faq", comment: "")
				break

				default:
					break
			}
			cell = aCell
			
			break
			
		case Sections.settings.rawValue:
			
			let aCell: MZImageAndLabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZImageAndLabelTableViewCell", for: indexPath) as! MZImageAndLabelTableViewCell
			
			switch indexPath.row
			{
				case 0:
					aCell.cellImage.image = UIImage(named: "icon_settings")
					aCell.cellText.text = NSLocalizedString("mobile_settings", comment: "")
					break
				
				default:
					break
			}
			cell = aCell
			break
			
		case Sections.social.rawValue:
		
			let aCell: MZImageAndLabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZImageAndLabelTableViewCell", for: indexPath) as! MZImageAndLabelTableViewCell
			
			switch indexPath.row
			{
				case 0:
					aCell.cellImage.image = UIImage(named: "icon_facebook")
					aCell.cellText.text = NSLocalizedString("mobile_facebook", comment: "")
					break
				
				case 1:
					aCell.cellImage.image = UIImage(named: "icon_twitter")
					aCell.cellText.text = NSLocalizedString("mobile_twitter", comment: "")
					break
		
				case 2:
					aCell.cellImage.image = UIImage(named: "icon_blog")
					aCell.cellText.text = NSLocalizedString("mobile_blog", comment: "")
					break
			
				default:
					break
			}
			
			cell = aCell
			break
			
		case Sections.muzzley.rawValue:
			let aCell: MZImageAndLabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZImageAndLabelTableViewCell", for: indexPath) as! MZImageAndLabelTableViewCell
			
			switch indexPath.row
			{
				case 0:
					//let imageRequest: NSURLRequest = NSURLRequest(URL: MZThemeManager.sharedInstance.image(MZThemeImages.appIconUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
					//aCell.cellImage.setImageWithURLRequest(imageRequest, placeholderImage: UIImage(), success:nil, failure:nil)
					aCell.cellImage.image = UIImage(named: "square_logo")
					aCell.cellText.text = NSLocalizedString("mobile_about", comment: "")
					break
				
				case 1:
					aCell.cellImage.image = UIImage(named: "icon_logout")
					aCell.cellText.text = NSLocalizedString("mobile_logout", comment: "")
					break
				
				case 2:
					aCell.cellImage.image = UIImage(named: "icon_debug")
					aCell.cellText.text = NSLocalizedString("mobile_debug_logs", comment: "")
				
				default:
				break
            }
		
			cell = aCell
			break
		

			
            
			default: break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch profileSections[indexPath.section] {
        case 0: return 180.0 // FIXME: 240.0 + (self.inEditMode ? (self.isDOBPickerOpen ? 350.0 : 134.0) : 0.0)
        //case 1: return 44.0
            
        default: return 44.0
        }
    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section > 0
		{
			switch profileSections[indexPath.section]
			{
				case Sections.support.rawValue:
					switch supportOptions[indexPath.row]
					{
					
						case Rows.feedback.rawValue:
							let feedbackVC: MZFeedbackViewController = MZFeedbackViewController(withWireframe: self.wireframe)
							self.wireframe.parent?.pushViewController(toEnd: feedbackVC, animated: true)
						case Rows.faq.rawValue:
							let vc = MZWebViewController()
							vc.url = MZThemeManager.sharedInstance.urls.faq
							self.wireframe.parent?.pushViewController(toEnd: vc, animated: true)
					default:
						break
					}
			
			case Sections.settings.rawValue:
				switch indexPath.row
				{
					
				case 0:
					let settingsVC: MZSettingsViewController = MZSettingsViewController(withWireframe: self.wireframe)
                    //TODO remove?
					//settingsVC.delegate = self
					self.wireframe.parent?.pushViewController(toEnd: settingsVC, animated: true)
					//self.navigationController?.pushViewController(settingsVC, animated: true)
				default:
					break
				}

			case Sections.social.rawValue:
				switch socialOptions[indexPath.row]
				{
					
				case Rows.facebook.rawValue:
					UIApplication.shared.openURL(MZThemeManager.sharedInstance.urls.facebook!)
					break
				
				case Rows.twitter.rawValue:
					UIApplication.shared.openURL(MZThemeManager.sharedInstance.urls.twitter!)
					break
				
				case Rows.blog.rawValue:
					UIApplication.shared.openURL(MZThemeManager.sharedInstance.urls.blog!)
					break
					
				default:
					break
				}
				
			case Sections.muzzley.rawValue:
				switch indexPath.row
				{
					
				case 0:
					let aboutVC: MZAboutViewController = MZAboutViewController(withWireframe: self.wireframe)
					self.wireframe.parent?.pushViewController(toEnd: aboutVC, animated: true)
					
				case 1:
					//MZSession.sharedInstance.closeAndClear()
					//self.interactor.requestSessionClose(withEmail: self.userProfile?.email)
					MZSession.sharedInstance.signOut()
				case 2:
					if self.debugActive
					{
						self.wireframe.parent?.pushViewController(toEnd: MZDebugViewController(), animated: true)
					}
					
					
				default:
					break
				}
	
	
				
			default: break
			}
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - UIScrollView Delegate
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        self.tableView.indexPathsForVisibleRows?.forEach({
//            if $0.section == 0 {
//                (self.tableView.cellForRowAtIndexPath($0) as! MZProfilePhotoTableViewCell).cellOnTableView(self.tableView, didScrollOnView: self.view)
//            }
//        })
//    }
	
    
    // MARK: - MZProfilePhotoTableViewCell Delegate
    
    func didTapPhoto() {
        let photoEditor: MZUserPhotoEditControllerViewController = MZUserPhotoEditControllerViewController(withWireframe: self.wireframe)
        photoEditor.profilePhotoURL = URL(string: (MZSessionDataManager.sharedInstance.session.userProfile.photoUrl))
        self.wireframe.parent?.pushViewController(toEnd: photoEditor, animated: true)
    }
    
    func didChangeEditingState(_ state: Bool) {
        self.inEditMode = state
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    func didOpenDobDatePicker(_ open: Bool) {
        self.isDOBPickerOpen = open
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    func didSelectDobDate(_ date: Date) {
        // TODO: update user model
    }
    
    func didSelectGender(_ gender: Gender) {
        self.selectedGender = gender
        // TODO: deal gender change
    }
    
    
    // MARK: - UITextFields CB's
    
    @IBAction func textFieldValueChanged(_ textField: UITextField) {
        // TODO: update user model
    }
    
    // MARK: - MZUserProfileInteractorOutput

    
    func sessionClosed() {
        self.delegate?.userProfileDidLogOut(self)
    }

}
