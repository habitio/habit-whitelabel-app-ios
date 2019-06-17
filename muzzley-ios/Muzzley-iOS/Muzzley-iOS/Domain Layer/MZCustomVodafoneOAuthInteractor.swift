//
//  MZCustomVodafoneOAuthInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/06/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
import RxSwift


class MZCustomVodafoneOAuthInteractor: NSObject
{
	var alertView: UIAlertView = UIAlertView()
	let disposeBag = DisposeBag()
	var webservice : MZCustomVodafoneOAuthWebService
	
	let authorizationPath = ""
	
    override init()
	{
		webservice = MZCustomVodafoneOAuthWebService()
		
		super.init()
	}
	
	func authenticateViaVodafone(_ code : String, completion: @escaping (_ success: Bool, _ error: NSError?) -> Void)
	{
		// Get access token
		getAccessToken(code) { (accessToken, error) in
			if(accessToken != nil)
			{
				self.getUserInformation(accessToken!, completion: { (userInformation, error) in
					if(userInformation != nil && userInformation! is NSDictionary)
					{
						let name = (userInformation! as! NSDictionary).value(forKey: "name") as! String
						var contact = (userInformation! as!  NSDictionary).value(forKey: "contact") as! String 
						var mutableDict = NSMutableDictionary()
						
						mutableDict.addEntries(from: ["authType":"email", "email": contact, "password": code])

//						contact = "testemailsignup4@muzzley.com"
						MZSession.sharedInstance.signIn(username: contact, password: code, completion: { (success, error) in
							if(success == true)
							{
								MZSessionDataManager.sharedInstance.getSessionInfo({ (success) in
								
									if(success)
									{
										NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserAuthModuleDidAuthenticateNotification"), object: nil)
										MZAnalyticsInteractor.configureIdentity(MZSession.sharedInstance.authInfo)
										MZAnalyticsInteractor.signInFinishEvent("email", errorMessage: nil)
										MZAnalyticsInteractor.flush()
									}
									
									completion(success, nil)
								})
								
							}
							else
							{
								// For testing purposes only.
//								mutableDict["email"] = contact
								mutableDict.addEntries(from: ["name": name])
								mutableDict.addEntries(from: ["cdata": ["code": code]])
								
								MZSession.sharedInstance.signUp(parameters: mutableDict, completion: { (success, error) in
									if(success)
									{
										MZAnalyticsInteractor.signUpFinishEvent("email", errorMessage: nil)
										MZAnalyticsInteractor.flush()
										
										
										MZSession.sharedInstance.signIn(username: contact, password: code, completion: { (success, error) in
											if(success == true)
											{
												
												MZSessionDataManager.sharedInstance.getSessionInfo({ (success) in
													if(success)
													{
														NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserAuthModuleDidAuthenticateNotification"), object: nil)
														MZAnalyticsInteractor.configureIdentity(MZSession.sharedInstance.authInfo)
														MZAnalyticsInteractor.signInFinishEvent("email", errorMessage: nil)
														MZAnalyticsInteractor.flush()
														NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserAuthModuleDidAuthenticateNotification"), object: nil)
													}
											
													completion(success, nil)
												})
											}
											else
											{
												self.alertView = UIAlertView(title: NSLocalizedString("mobile_signin_error", comment: ""), message:NSLocalizedString("mobile_error_text", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: ""))
											
												self.alertView.alertViewStyle = UIAlertViewStyle.default
												self.alertView.show()
											}
										})
									
									}
									else
									{
                                        self.alertView = UIAlertView(title: NSLocalizedString("mobile_signup_error", comment: ""), message:NSLocalizedString("mobile_error_text", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: ""))
                                        
                                        self.alertView.alertViewStyle = UIAlertViewStyle.default
                                        self.alertView.show()

//										dLog(message: "could not signup neither signin")
										MZSession.sharedInstance.signOut()
										let errorMessage = !(error?.localizedDescription.isEmpty)! ? error?.localizedDescription : ""
										MZAnalyticsInteractor.signUpFinishEvent("email", errorMessage: errorMessage)
										MZAnalyticsInteractor .flush()
										completion(false, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
									}
								})
							}
						})
					}
					else
					{
						completion(false, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
					}
				})
			}
			else
			{
				if(error != nil)
				{
					completion(false, error)
				}
				else
				{
					completion(false, NSError(domain: MZTilesDataManagerErrorDomain, code: 0, userInfo: nil))
				}
			}
		}
	}
	
	func getAccessToken(_ code: String, completion: @escaping (_ accessToken: String?, _ error: NSError?) -> Void)
	{
		self.webservice.getAccessToken(code) { (accessToken, error) in
			completion(accessToken, error)
		}
	}
	
	func getUserInformation(_ accessToken: String, completion: @escaping (_ userInformation: NSDictionary?, _ error: NSError?) -> Void)
	{
			self.webservice.getUserInformation(accessToken) { (userInfo, error) in
				completion(userInfo, error)
		}
	}
}
