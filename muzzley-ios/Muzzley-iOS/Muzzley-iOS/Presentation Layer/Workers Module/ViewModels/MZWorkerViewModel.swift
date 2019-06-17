//
//  MZWorkerViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 03/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//  

import CoreLocation


@objc enum WorkerState: Int {
    case testing = 0, alert, success, none
}

class MZWorkerViewModel : NSObject
{
    var label: String           = ""
    var enabled: Bool           = true
    var lastRun: String         = ""
    var desc: String            = ""
    var category: String        = ""
	var categoryColor: UIColor  = UIColor.muzzleyBlackColor(withAlpha: 1)
	
	var categoryImage			: URL?
	var clientImage				: URL?
	var forceDisabledStatus		= false
	var forceDisabledMessage	= ""
	var deletable				= true
    var allowDisable			= false
	
    var devicesText: String     = ""
    var triggerDeviceVM: MZBaseWorkerDeviceViewModel?
    var actionDeviceVMs: [MZBaseWorkerDeviceViewModel] = []
    var stateDeviceVMs: [MZBaseWorkerDeviceViewModel] = []
    var unsortedDeviceVMs: [MZBaseWorkerDeviceViewModel] = []
    var inWatch: Bool           = false
    var hasCapabilities: Bool   = true
	
    var needLocationPermissions: Bool = false {
         didSet {
            self.setLocationPermissionAlert()
        }
    }

	var needNotificationsPermissions: Bool = false {
		didSet {
			self.setNotificationsPermissionAlert()
		}
	}
	
    var isValid: Bool = true {
        didSet {
           self.setInvalidAlert()
        }
    }
    
    var isEditable: Bool = true
    
    var requiredCapabilities: [String] = [] {
        didSet {
            if self.alertViewModel.currentAlert == WorkerAlert.none
            {
                self.setCapacityAlert()
                self.checkIfNeedLocationPermissions()
				self.checkIfNeedNotificationsPermissions()
            }
        }
    }
    
    var progressViewModel: MZWorkerProgressViewModel = MZWorkerProgressViewModel()
    var doneViewModel: MZWorkerDoneViewModel = MZWorkerDoneViewModel()
    var alertViewModel: MZWorkerAlertViewModel = MZWorkerAlertViewModel()
    
    var model : MZWorker?
    
    var currentState: WorkerState = WorkerState.none {
        didSet {
            if (currentState == WorkerState.testing) {
                self.progressViewModel.animating = true;
            } else if (currentState == WorkerState.alert) {
                self.progressViewModel.animating = false;
            } else if (currentState == WorkerState.success) {
                self.progressViewModel.animating = false;
            } else if (currentState == WorkerState.none) {
                self.progressViewModel.animating = false;
            }
        }
    }


    init(model : MZWorker)
    {
        super.init()

        self.model = model
        self.label = model.label
        self.desc = model.desc
        self.category = model.category
        self.categoryColor = model.categoryColor
        self.devicesText = model.devicesText
        self.enabled = model.enabled
        self.isEditable = model.isEditable
        self.isValid = model.isValid
		
		self.categoryImage = model.categoryImage
		self.clientImage = model.clientImage
		self.forceDisabledStatus = model.forceDisabledStatus
		self.forceDisabledMessage = model.forceDisabledMessage
		self.deletable = model.deletable
        self.allowDisable = model.allowdisable
		
		self.alertViewModel.textForceDisabled = self.forceDisabledMessage
		
        self.alertViewModel.workerLabel = model.label
		
		MZNotifications.register(self, selector: #selector(self.updateHourFormat), notificationKey: MZNotificationKeys.UserProfile.HourFormatUpdated)
		
		if (!model.lastRun.isEmpty)
        {
            if model.lastRun == "1900-01-01T00:00:00.000Z"
            {
                self.lastRun = ""
            } else {
                let dateFormatter = DateFormatter()
                let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
                dateFormatter.locale = enUSPosixLocale
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZ"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
				
                let iso8601Date = dateFormatter.date(from: model.lastRun)
                dateFormatter.timeZone = TimeZone.autoupdatingCurrent
				dateFormatter.dateStyle = .long
                let dateString = dateFormatter.string(from: iso8601Date!)
				
                var lastExecutedLocalizedString = NSLocalizedString("mobile_worker_executed", comment: "")
				var lastRunString = String(format: lastExecutedLocalizedString, dateString, TimeFormatHelper.formatTime(MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat, date: iso8601Date!))

				self.lastRun = lastRunString
			}
			
        }
        else if (model.lastRun.isEmpty)
        {
            self.lastRun = ""
        }
		
        if !model.triggerDevices.isEmpty
        {
            let triggerDeviceVM = MZBaseWorkerDeviceViewModel(model: model.triggerDevices[0])
            self.triggerDeviceVM = triggerDeviceVM
        }
        
        for actionDeviceModel in model.actionDevices
        {
            let actionDeviceVM = MZBaseWorkerDeviceViewModel(model: actionDeviceModel)
            self.actionDeviceVMs.append(actionDeviceVM)
        }
        
        for stateDeviceModel in model.stateDevices
        {
            let stateDeviceVM = MZBaseWorkerDeviceViewModel(model: stateDeviceModel)
            self.stateDeviceVMs.append(stateDeviceVM)
        }
        
        for unsortedDeviceModel in model.unsortedDevices
        {
            let unsortedDeviceVM = MZBaseWorkerDeviceViewModel(model: unsortedDeviceModel)
            self.unsortedDeviceVMs.append(unsortedDeviceVM)
        }
		
		if self.forceDisabledStatus
		{
			self.currentState = WorkerState.alert
			self.alertViewModel.currentAlert = WorkerAlert.forceDisabled
		}
		else
		{
			self.setInvalidAlert()
		}
    }
    
	func updateHourFormat()
	{
		if (!model!.lastRun.isEmpty)
		{
			if model!.lastRun == "1900-01-01T00:00:00.000Z"
			{
				
				self.lastRun = ""
			} else {
				let dateFormatter = DateFormatter()
				let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
				dateFormatter.locale = enUSPosixLocale
				
				dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZ"
				dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
				
				let iso8601Date = dateFormatter.date(from: model!.lastRun)
				
				dateFormatter.timeZone = TimeZone.autoupdatingCurrent
				//dateFormatter.locale = NSLocale.currentLocale()
				
				dateFormatter.dateStyle = .long
				//dateFormatter.timeStyle = . ShortStyle
				let dateString = dateFormatter.string(from: iso8601Date!)
				
				var lastRunString = String(format: "mobile_worker_executed", dateString)
				
				lastRunString = lastRunString + TimeFormatHelper.formatTime(MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat, date: iso8601Date!)
				self.lastRun = lastRunString
			}
		} else if (model!.lastRun.isEmpty) {
			self.lastRun = ""
		}
	}
	
	
    func updateModel()
    {
        self.model?.label = self.label
        self.model?.enabled = self.enabled
		
        if let triggerDeviceM = self.triggerDeviceVM?.model
        {
            triggerDeviceM.items = []
            for itemVM in self.triggerDeviceVM!.items
            {
                triggerDeviceM.items.append(itemVM.model!)
            }
            
            self.model?.triggerDevices = [triggerDeviceM]
        }
        
        self.model?.actionDevices = []
        for actionDeviceVM in self.actionDeviceVMs
        {
            let actionDeviceM = actionDeviceVM.model
            actionDeviceM!.items = []
            for itemVM in actionDeviceVM.items
            {
                actionDeviceM!.items.append(itemVM.model!)
            }
            self.model?.actionDevices.append(actionDeviceM!)
        }
        
        self.model?.stateDevices = []
        //TODO too similar with previous!
        for stateDeviceVM in self.stateDeviceVMs
        {
            let stateDeviceM = stateDeviceVM.model
            stateDeviceM!.items = []
            for itemVM in stateDeviceVM.items
            {
                stateDeviceM!.items.append(itemVM.model!)
            }
            self.model?.stateDevices.append(stateDeviceM!)
        }
    }
    
    fileprivate func setCapacityAlert()
    {
        for capability: String in self.requiredCapabilities
        {
            if !MZHardwareCapabilities.supportedCapabilities.contains(capability)
            {
                self.hasCapabilities = false
                if self.alertViewModel.currentAlert != WorkerAlert.invalid
                {
                    self.alertViewModel.currentAlert = WorkerAlert.hardwareCapabilities
                }
                break
            }
        }
    }
    
    fileprivate func checkIfNeedLocationPermissions()
    {
        self.needLocationPermissions = false
        
        var triggersVM : [MZBaseWorkerDeviceViewModel] = []
        
        if let triggerVM = self.triggerDeviceVM
        {
            triggersVM.append(triggerVM)
        }
        
        let deviceVMs = triggersVM + self.actionDeviceVMs + self.stateDeviceVMs + self.unsortedDeviceVMs
        
        for item in deviceVMs
        {
            if item.model!.componentIds.contains("location")
            {
                self.needLocationPermissions = true
				
                return
            }
        }
    }
	
	fileprivate func checkIfNeedNotificationsPermissions()
	{
		self.needNotificationsPermissions = false
		
		var triggersVM : [MZBaseWorkerDeviceViewModel] = []
		
		if let triggerVM = self.triggerDeviceVM
		{
			triggersVM.append(triggerVM)
		}
		
		let deviceVMs = triggersVM + self.actionDeviceVMs + self.stateDeviceVMs + self.unsortedDeviceVMs
		
		for item in deviceVMs
		{
			if item.model!.componentIds.contains("push")
			{
				self.needNotificationsPermissions = true
				return
			}
		}
	}
	
    func setLocationPermissionAlert ()
    {
        if self.needLocationPermissions
        && self.alertViewModel.currentAlert == WorkerAlert.none
        {
            if (!CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .authorizedAlways)
            {
                self.currentState = WorkerState.alert
                self.alertViewModel.currentAlert = WorkerAlert.locationPermission
            }
		}
    }
	
	func setNotificationsPermissionAlert ()
	{
		if self.needNotificationsPermissions
			&& self.alertViewModel.currentAlert == WorkerAlert.none
		{
			if (!MZDeviceInfoHelper.areNotificationsEnabled())
			{
				self.currentState = WorkerState.alert
				self.alertViewModel.currentAlert = WorkerAlert.notificationsPermission
			}
		}
	}
	
    func setInvalidAlert()
    {
        if !self.isValid
        {
            self.currentState = WorkerState.alert
            self.alertViewModel.currentAlert = WorkerAlert.invalid
        }
    }
}
