
//  MZUserAuthCustomSignInViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 21/06/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

@objc protocol MZUserAuthCustomSignInViewControllerDelegate : NSObjectProtocol
{
	func signedInWithSuccess()
	func signInCanceled()
}


class MZUserAuthCustomSignInViewController: BaseViewController, UIWebViewDelegate, NSURLConnectionDataDelegate
{
	
	@IBOutlet weak var uiWebview: UIWebView!
	
	var delegate : MZUserAuthCustomSignInViewControllerDelegate?
	
	fileprivate var vodafoneInteractor : MZCustomVodafoneOAuthInteractor!
	fileprivate var loadingView = MZLoadingView()
	
	convenience init()
	{
		self.init(nibName: "MZUserAuthCustomSignInViewController", bundle: Bundle.main)
		self.vodafoneInteractor = MZCustomVodafoneOAuthInteractor()
		self.loadingView.updateLoadingStatus(false, container: self.view)
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		setupInterface()
		requestAuthenticationCode()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		self.navigationController?.navigationBar.tintColor = UIColor.clear
		self.navigationController?.navigationBar.barTintColor = UIColor.clear
		self.navigationController?.navigationBar.backgroundColor = UIColor.clear
		self.navigationController?.navigationBar.tintColorDidChange()
	}
	
	func setupInterface()
	{
		self.title = NSLocalizedString("mobile_account", comment: "")
		self.uiWebview.delegate = self
		self.navigationController?.navigationBar.tintColor = MZThemeManager.sharedInstance.colors.primaryColorText
		self.navigationController?.navigationBar.barTintColor = MZThemeManager.sharedInstance.colors.primaryColor
		self.navigationController?.navigationBar.backgroundColor = MZThemeManager.sharedInstance.colors.primaryColor
		
		// TODO: Finish this
	}
	
	func requestAuthenticationCode()
	{
		var request : URLRequest = URLRequest(url: URL(string: vodafoneInteractor.authorizationPath)!)
		
		for cookie in HTTPCookieStorage.shared.cookies!
		{
			HTTPCookieStorage.shared.deleteCookie(cookie)
		}
		
		self.uiWebview.loadRequest(request)
	}
	
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
 {
		if(request.url?.absoluteString.hasPrefix("https://api.platform.muzzley.com/v3/third-party/credentials/inbox") == true)
		{
			self.loadingView.updateLoadingStatus(true, container: self.view)

			let url = URLComponents(string: (request.url?.absoluteString)!)
			let code: String = (url!.queryItems!.filter({ (item) in item.name == "code" }).first?.value!)!
//            dLog(comessage: de)
			self.vodafoneInteractor.authenticateViaVodafone(code, completion: { (success, error) in
				if(success)
				{
					self.loadingView.updateLoadingStatus(false, container: self.view)
					
				}
				else
				{
					let alert = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .default, handler: { action in
						self.loadingView.updateLoadingStatus(false, container: self.view)

						
					}))
					
					self.present(alert, animated: true, completion: nil)

				}
			})
			return false
		}
		return true
	}
	
	func webViewDidStartLoad(_ webView: UIWebView) {
		self.loadingView.updateLoadingStatus(true, container: self.view)
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		self.loadingView.updateLoadingStatus(false, container: self.view)

	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: NSError) {
		//self.loadingView.updateLoadingStatus(false, container: self.view)
	}
}
