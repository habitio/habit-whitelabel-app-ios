//
//  MZWorkerConfigViewController.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 19/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


class MZWorkerConfigViewController: UIViewController, MZHTMLViewControllerDelegate {
    @IBOutlet weak var webViewPlaceholder: UIView!
    
    var deviceVMs: [MZDeviceViewModel]!
    var workerVM: MZWorkerViewModel!
    var type:String!
    var isEdit:Bool = false
    var isUpdate:Bool = false
    var isShortcut:Bool = false
    
    fileprivate enum ThingInteractionUIState: Int {
        case initial = 0,
        unableToLoad,
        loading,
        loaded
    }
    
    fileprivate var wireframe: MZRootWireframe!
    fileprivate var interactor: MZWorkersInteractor!
    fileprivate var htmlViewController: MZHTMLViewController!
    
    convenience init(withWireframe wireframe: MZRootWireframe, andInteractor interactor: MZWorkersInteractor) {
        self.init(nibName: "MZWorkerConfigViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        
        self.htmlViewController = MZHTMLViewController()
        self.htmlViewController.delegate = self
        self.addChildViewController(self.htmlViewController)
        self.htmlViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.htmlViewController.view.frame = self.webViewPlaceholder.bounds
        self.webViewPlaceholder.addSubview(self.htmlViewController.view)
        self.htmlViewController.enableActivityIndicator(true)
		
		
		
        self.htmlViewController.load(with:URLRequest(url: self.interactor.getWorkerURL()), withOptions: self.interactor.getOptionsPayload(self.deviceVMs, type: self.type!) as! [AnyHashable: Any])
		
		//.loadWithURLRequest(NSURLRequest(URL: self.interactor.getWorkerURL() as URL), withOptions: self.interactor.getOptionsPayload(self.deviceVMs, type: self.type!) as! [AnyHashable: Any])

    }
    
    
    // MARK: - MZHTMLViewController Delegate
    
    func htmlViewController(_ htmlViewController: MZHTMLViewController!, didFailLoadWithError error: NSError!) {
        if error.code != NSURLErrorCancelled {
        }
    }
    
    func htmlViewController(_ htmlViewController: MZHTMLViewController!, onMessage message: [AnyHashable: Any]?)
    {
        if message != nil
        {
            workerVM = self.interactor.updateWorkerViewModel(workerVM!, message: message!, isUpdate: self.isUpdate, isEdit: self.isEdit, isShortcut: self.isShortcut)
            if self.navigationController != nil
            {
                for vc in self.navigationController!.viewControllers
                {
                    if vc is MZCreateWorkerViewController {
                        self.navigationController!.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        }
    }
}
