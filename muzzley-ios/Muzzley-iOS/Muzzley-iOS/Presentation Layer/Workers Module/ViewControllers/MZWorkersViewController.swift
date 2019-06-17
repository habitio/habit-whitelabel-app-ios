//
//  MZWorkersViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 03/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift
import KLCPopup
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MZWorkersViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    MZWorkerCellDelegate,
    MZChangeWorkerDelegate,
    MZInfoViewDelegate,
	MZRootWorkersViewControllerDelegate,
    MZBlankStateDelegate
{
 

    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var addAgentButton: MZLightBorderButton!
    
    @IBOutlet weak var uiBlankState: MZBlankStateView!
    
    
    fileprivate enum WorkerAction {
        case trash, execute, changeState, none;
    }
    
    fileprivate var infoView : MZInfoView?

    fileprivate var interactor : MZWorkersInteractor?
    fileprivate var parentWireframe: MZRootWireframe!
    fileprivate var parsedWorkers : [MZWorkerViewModel] = [MZWorkerViewModel]()
    fileprivate var refreshControl: MZRefreshControl?
    fileprivate var popupView: KLCPopup?
    fileprivate var isWorkerChanged: Bool = false
    fileprivate var isDataUpdated: Bool = false
    fileprivate var isViewPresented: Bool = false
	fileprivate var viewIsLoaded: Bool = false
	fileprivate var isWorkersViewVisible = false
    fileprivate var isFirstTime = true

    init(nibName: String, bundle: Bundle, interactor: MZWorkersInteractor, parentWireframe: MZRootWireframe) {
        super.init(nibName: nibName, bundle: bundle)
        self.interactor = interactor
        self.parentWireframe = parentWireframe
		self.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func refreshTriggered() {
		
		self.reloadData()
	}
	
    override func viewDidLoad()
    {
		
        super.viewDidLoad()
        
        self.setupBlankState()

        self.tableView!.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 8.0))
        self.tableView!.register(UINib(nibName: "MZWorkerEditableCell", bundle: Bundle.main), forCellReuseIdentifier: "MZWorkerEditableCell")
        self.tableView!.register(UINib(nibName: "MZWorkerUsecaseCell", bundle: Bundle.main), forCellReuseIdentifier: "MZWorkerUsecaseCell")
        
        self.refreshControl = MZRefreshControl(tableView: self.tableView)
        self.refreshControl!.addTarget(self, action: #selector(MZWorkersViewController.reloadData), for: .valueChanged)
        
        self.refresh()
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        
        self.addAgentButton.setImage(UIImage(named: "IconAdd")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.addAgentButton.setTitle(NSLocalizedString("mobile_worker_add", comment: ""), for: .normal)

		self.viewIsLoaded = true
    }
	
    override func viewDidAppear(_ animated: Bool) {
		
        super.viewDidAppear(animated)
        self.isViewPresented = true
        self.tableView?.reloadRows(at: (self.tableView?.indexPathsForVisibleRows)!, with: .automatic)
    }

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
        self.parentWireframe.rootViewController.workersDelegate = self
	}
	
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func reloadData() {
        if self.view == nil {
            return;
        }
		
		var internetReachable = Reachability.forInternetConnection()
		
		if(internetReachable?.currentReachabilityStatus() == NotReachable)
		{
            self.uiBlankState.setState(state: .noInternet)
			return
		}
		
        weak var weakSelf = self
        
        self.isDataUpdated = false
        self.refreshControl?.beginRefreshing()
        
        if self.isFirstTime || self.parsedWorkers.count == 0
		{
            self.uiBlankState.setState(state: .loading)
        }
		else
		{
            self.uiBlankState.hide()
        }
		
        self.interactor!.getWorkers({ (result, error) -> Void in
            if self.isFirstTime {
                self.isFirstTime = false
            }
            
            if error == nil {
			
                if (result as! [MZWorkerViewModel]).count > 0 {
                    self.parsedWorkers = result as! [MZWorkerViewModel]
                    self.refresh()
                    weakSelf?.reloadView()
                } else {
					self.parsedWorkers.removeAll()
					self.refresh()
					weakSelf?.reloadView()
                    
                    self.uiBlankState.setState(state: .blank)
                }
            } else {
                
                self.uiBlankState.setState(state: .error)
            }
            self.refreshControl!.endRefreshing()
            self.isDataUpdated = true
            
            
           
            
		})
    }
    

    
    func reloadView () {
        self.tableView!.beginUpdates()
        self.tableView?.reloadSections(IndexSet(integer: 0), with: .automatic)
        self.tableView!.endUpdates()
        
        if (self.isWorkerChanged)
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                self.showOnboardings()
            })
        }
        
	}
	
    func refresh ()
    {
        if (self.parsedWorkers.count > 0)
		{
            self.uiBlankState.hide()
        }
		else
		{
            self.uiBlankState.setState(state: .blank)
        }
    }
    
    fileprivate func setState (_ aWorker: MZWorkerViewModel, state:WorkerState, action: WorkerAction) {
        if aWorker.currentState != state {
            aWorker.currentState = state
            
            if self.parsedWorkers.index(of: aWorker) != nil
            {
                let indexPath = IndexPath(row: self.parsedWorkers.index(of: aWorker)!, section: 0)
                
                if state == .success && action == .trash {
                    self.parsedWorkers.remove(at: indexPath.row)
                    self.tableView?.deleteRows(at: [indexPath], with: .fade)
                    if self.parsedWorkers.count == 0
                    {
                        self.uiBlankState.setState(state: .blank)
                    }
                    return;
                } else if state == .success || state == .alert {
                    if state == .success && action == .changeState {
                        aWorker.enabled = !aWorker.enabled
                    }
                    
                    if state != .alert
                    {
                        self.perform(#selector(MZWorkersViewController.hideState(_:)), with: aWorker, afterDelay: 2)
                    }
                }
            
                self.tableView?.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    func hideState (_ aWorker: MZWorkerViewModel) {
        self.setState(aWorker, state: .none, action: .none)
    }
    
    //OLD to delete
//    func showSuccessState(aWorker: MZWorkerViewModel)
//    {
//        self.setState(aWorker, state: .Success, action: .Execute)
//    }
    
    func didTapExecute(_ aWorker: MZWorkerViewModel) {
        self.setState(aWorker, state: .testing, action: .execute)

        self.interactor?.executeWorker(aWorker, completion: { (success, error) -> Void in
            if error != nil {
                MZAnalyticsInteractor.workerExecuteEvent((aWorker.model?.identifier)!, errorMessage: nil)
                aWorker.alertViewModel.currentAlert = WorkerAlert.noExecuted
                self.setState(aWorker, state: .alert, action: .execute)
            }else {
                self.setState(aWorker, state: .success, action: .execute)
            }
        })
    }
    
    func deleteWorker (_ viewModel: MZWorkerViewModel) {
        
        self.interactor!.deleteWorker(viewModel, completion: { (result, error) -> Void in
            if error == nil {
                MZAnalyticsInteractor.workerRemoveFinishEvent((viewModel.model?.identifier)!, errorMessage: nil)
                self.setState(viewModel, state: .success, action: .trash)
            } else {
                MZAnalyticsInteractor.workerRemoveFinishEvent((viewModel.model?.identifier)!, errorMessage: error?.localizedDescription)
//                self.setState(aWorker, state: .Error, action: .Trash)
//                TODO no network errors
            }
        })
    }
    
    func didTapTrash(_ aWorker: MZWorkerViewModel) {
        let message = String.init(format: NSLocalizedString("mobile_worker_delete_text", comment: ""), aWorker.label) 
        
        MZAnalyticsInteractor.workerRemoveStartEvent((aWorker.model?.identifier)!)
        
        let alert: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: { (action) in
            MZAnalyticsInteractor.workerRemoveCancelEvent((aWorker.model?.identifier)!)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_delete", comment: ""), style: .destructive, handler: { (action) -> Void in
             self.deleteWorker(aWorker)
            }))
    
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapCancel(_ aWorker: MZWorkerViewModel)
    {
        self.setState(aWorker, state: .none, action: .none)
    }
    
    
    func didTapOnPopupButtonAtIndex(_ btnIndex: Int) {
        self.popupView?.dismiss(true)
    }
    
    func didChangeToggleState(_ aWorker: MZWorkerViewModel, state: MZTriStateToggleState) {
        self.interactor!.enableWorker(aWorker, enabled: state == MZTriStateToggleState.on, completion: { (result, error) -> Void in
            if error != nil {
                MZAnalyticsInteractor.workerEnableEvent((aWorker.model?.identifier)!, errorMessage: error?.localizedDescription, enable: state == .on)
//                self.setState(aWorker, state: .Error, action: .ChangeState)
                // TODO no network errors
            } else {
                MZAnalyticsInteractor.workerEnableEvent((aWorker.model?.identifier)!, errorMessage: nil, enable: state == .on)
            }
        })
    }
    
    func didTapPermission(_ aWorker: MZWorkerViewModel)
    {
        self.showPermissionInfo(aWorker)
    }
    
    func shouldReloadAtIndex(_ aWorker: MZWorkerViewModel) {
        self.tableView?.reloadRows(at: [IndexPath(row: self.parsedWorkers.index(of: aWorker)!, section: 0)], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parsedWorkers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: MZWorkerCell!
        let workerVM: MZWorkerViewModel = self.parsedWorkers[indexPath.row] as MZWorkerViewModel
		if workerVM.isEditable
		{
			cell = self.tableView!.dequeueReusableCell(withIdentifier: "MZWorkerEditableCell", for: indexPath) as! MZWorkerEditableCell
        }
		else
		{
            cell = self.tableView!.dequeueReusableCell(withIdentifier: "MZWorkerUsecaseCell", for: indexPath) as! MZWorkerUsecaseCell
        }
		
        cell.delegate = self
        cell.setViewModel(workerVM)
		
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workerVM: MZWorkerViewModel = self.parsedWorkers[indexPath.row] as MZWorkerViewModel
        

        print(workerVM.needNotificationsPermissions)
        print(!(workerVM.needNotificationsPermissions ? MZDeviceInfoHelper.areNotificationsEnabled() : false))

//        print((MZDeviceInfoHelper.areNotificationsEnabled() ? true : false))
//        print(MZDeviceInfoHelper.areNotificationsEnabled())
        if workerVM.isValid
            && workerVM.hasCapabilities
            && workerVM.needNotificationsPermissions ? MZDeviceInfoHelper.areNotificationsEnabled() :true
            && !(workerVM.needLocationPermissions ? !(CLLocationManager.locationServicesEnabled() ? CLLocationManager.authorizationStatus() == .authorizedAlways : false) : false)
        {
            if workerVM.isEditable
            {
                let editVC: MZCreateWorkerViewController = MZCreateWorkerViewController(withWireframe: self.parentWireframe, andInteractor: self.interactor!)
                editVC.delegate = self
                editVC.isEdit = true
                editVC.workerVM = workerVM
                self.parentWireframe.pushViewController(toEnd: editVC, animated: true)
            } else {
                self.showUsecaseInfo(workerVM)
            }
        }
		else if workerVM.isValid && !workerVM.hasCapabilities
        {
            var cell: MZWorkerCell = tableView.cellForRow(at: indexPath) as! MZWorkerCell
            cell.changeAlertVisibility()
        }
    }
    
    @IBAction func addAgentAction(_ sender: AnyObject) {
		self.addAgent()

    }
	
    func addAgent()
    {
        if(!MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_createWorker))
        {
            MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_createWorker, shownStatus: true)
        }
        
        let createAgentVC: MZCreateWorkerViewController = MZCreateWorkerViewController(withWireframe: self.parentWireframe, andInteractor: self.interactor!)
        createAgentVC.delegate = self
        self.parentWireframe.pushViewController(toEnd: createAgentVC, animated: true)
    }
    
    

    // MARK: - MZChangeWorkerDelegate
    func didChangeWorker() {
        if self.parsedWorkers.count == 0 {
            if !UserDefaults.standard.bool(forKey: "hasCreatedAgent") {
                self.isWorkerChanged = true
            }
        }
        
        if !self.refreshControl!.isRefreshing {
            reloadData()
        }
    }
	
	func workersTabVisibleStatusUpdate(_ isVisible: Bool)
	{
		self.isWorkersViewVisible = isVisible
		if(self.isWorkersViewVisible)
		{
			showOnboardings()
		}
	}

    func workersTabDoubleTapped()
    {
        let indexPath = IndexPath(row: 0, section: 0)
        if(self.tableView != nil && self.tableView?.numberOfSections > 0 && self.tableView?.numberOfRows(inSection: 0) > 0)
        {
            self.tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
	fileprivate func showOnboardings()
	{
		if (self.view == nil) { return }

		if(self.view.window == nil)
		{
			return
		}
		
		if(self.viewIsLoaded && self.isViewPresented)
		{
			if(!MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_createWorker))
			{
				self.definesPresentationContext = true;
				
				var highlitViews = [UIView]()
				highlitViews.append(self.addAgentButton)

				let onboarding = MZWorkersOnboardingViewController(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext, highlightViews: highlitViews)
				self.present(onboarding, animated: false, completion: nil)
				onboarding.show()
				MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_createWorker, shownStatus: true)
			}

			if self.isWorkerChanged && self.isDataUpdated && !MZOnboardingsInteractor.sharedInstance.hasOnboardingBeenShown(MZOnboardingsInteractor.sharedInstance.key_workerCreated)
            {
				if(self.tableView != nil && self.tableView?.numberOfRows(inSection: 0) > 0)
				{
					self.isWorkerChanged = false
					self.definesPresentationContext = true;
					
					
					let indexPath = IndexPath(item: 0, section: 0)
					let cell = self.tableView!.dequeueReusableCell(withIdentifier: "MZWorkerEditableCell", for: indexPath) as! MZWorkerEditableCell
					var highlitViews = [UIView]()
					highlitViews.append(cell.workerToggle!)
					
					let onboarding = MZWorkerCreatedOnboardingViewController(modalPresentationStyle: UIModalPresentationStyle.overCurrentContext, highlightViews: highlitViews)
					self.present(onboarding, animated: false, completion: nil)
					onboarding.show()
					MZOnboardingsInteractor.sharedInstance.updateOnboardingStatus(MZOnboardingsInteractor.sharedInstance.key_workerCreated, shownStatus: true)
				}
				
				return
			}
		}
	}
    
    func showUsecaseInfo(_ workerVM: MZWorkerViewModel)
    {
        self.infoView = Bundle.main.loadNibNamed("MZWorkerUsecaseInfoView", owner: nil, options: nil)![0] as! MZWorkerUsecaseInfoView
		(self.infoView! as! MZWorkerUsecaseInfoView).setViewModel(workerVM)
        self.showInfo()
    }
    
    func showPermissionInfo(_ workerVM: MZWorkerViewModel)
    {
        self.infoView = Bundle.main.loadNibNamed("MZPermissionInfoView", owner: nil, options: nil)![0] as! MZPermissionInfoView
		
		if workerVM.alertViewModel.currentAlert == WorkerAlert.locationPermission
		{
			(self.infoView as! MZPermissionInfoView).setPermissionType(MZPermissionType.location)
		}
		else if workerVM.alertViewModel.currentAlert == WorkerAlert.notificationsPermission
		{
			(self.infoView as! MZPermissionInfoView).setPermissionType(MZPermissionType.notifications)
		}
		
		self.showInfo()
    }
	
	
	func showInfo()
    {
        self.infoView!.delegate = self
		self.infoView!.show()
    }
    
    
    
    /// Blank state
    
    func setupBlankState()
    {
        self.uiBlankState.delegate = self
        self.uiBlankState.setup(blankStateImage: UIImage(named: "BlankStateWorkers")!,
                                blankStateTitle: NSLocalizedString("mobile_workers_blankstate_empty_title", comment: ""),
                                blankStateText: NSLocalizedString("mobile_workers_blankstate_empty_text", comment: ""),
                                blankStatebuttonTitle: NSLocalizedString("mobile_worker_add", comment: ""),
                                loadingStateTitle: NSLocalizedString("mobile_workers_blankstate_empty_title", comment: ""),
                                loadingStateText: NSLocalizedString("mobile_workers_blankstate_loading_text", comment: ""))
        
        self.uiBlankState.setState(state: .blank)
    }
    
    func blankStateRefreshTriggered() {
        self.reloadData()
    }
    
    func blankStateButtonPressed()
    {
        self.addAgent()
    }
    
    

}
