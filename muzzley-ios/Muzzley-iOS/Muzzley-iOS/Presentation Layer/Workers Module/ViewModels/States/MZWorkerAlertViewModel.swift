//
//  MZWorkerAlertViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 14/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

@objc enum WorkerAlert: Int {
    case none = 0,
	invalid,
	noExecuted,
	hardwareCapabilities,
	locationPermission,
	notificationsPermission,
	forceDisabled
}

import UIKit

class MZWorkerAlertViewModel: NSObject {

    let iconName: String = ""

    var workerLabel: String = "" {
        didSet {
            let length = 30
            if workerLabel.characters.count > length
            {
                workerLabel = workerLabel.substring(to: workerLabel.characters.index(workerLabel.startIndex, offsetBy: length))
            }
        }
    }
    var title: String = ""
    var text: String = ""
    var leftButtonTitle: String = ""
    var rightButtonTitle: String = ""
    var centerButtonTitle: String = ""

    
    let titleInvalid : String = NSLocalizedString("mobile_worker_invalid_title",comment: "")
    let textInvalid : String = NSLocalizedString("mobile_worker_invalid_text",comment: "")
    var centerButtonTitleInvalid : String = NSLocalizedString("mobile_worker_invalid_delete",comment: "")
    
    let titleNoExecuted : String = ""
    let textNoExecuted : String = NSLocalizedString("mobile_worker_noexecuted_error_text",comment: "")
    let leftButtonTitleNoExecuted : String = NSLocalizedString("mobile_cancel",comment: "")
    let rightButtonTitleNoExecuted : String = NSLocalizedString("mobile_retry",comment: "")
    
    let titleHardwareCapabilities: String =  NSLocalizedString("mobile_worker_hardwareCapabilities_title",comment: "")
    let textHardwareCapabilities: String = NSLocalizedString("mobile_worker_hardwareCapabilities_text",comment: "")
    let centerButtonTitleHardwareCapabilities: String = NSLocalizedString("mobile_got_it",comment: "")
	
	
    let titleLocationPermission : String = NSLocalizedString("mobile_permission_title",comment: "")
    let textLocationPermission : String = NSLocalizedString("mobile_worker_locationpermission_text",comment: "")
    let centerButtonLocationPermission: String = NSLocalizedString("mobile_lets_do_it",comment: "")
	
	let titleNotificationsPermission : String = NSLocalizedString("mobile_permission_title",comment: "")
	let textNotificationsPermission : String = NSLocalizedString("mobile_worker_notifications_permissions_text",comment: "")
	let centerButtonNotificationsPermission: String = NSLocalizedString("mobile_lets_do_it",comment: "")
	
	
	let titleForceDisabled : String = NSLocalizedString("mobile_worker_force_disabled_title",comment: "")
	var textForceDisabled : String = "" // It is dynamic. Comes with the worker model
	//let centerButtonForceDisabled: String = NSLocalizedString("mobile_worker_force_disabled_button",comment: "")
	
	func setForceDisabledText(_ text : String)
	{
		self.textForceDisabled = text
	}
	
	
	
    var currentAlert: WorkerAlert = WorkerAlert.none {
        didSet {
            self.title = ""
            self.text = ""
            self.centerButtonTitle = ""
            self.leftButtonTitle = ""
            self.rightButtonTitle = ""
			
            if (currentAlert == WorkerAlert.invalid) {
                self.title = self.titleInvalid
                self.text = String(format: self.textInvalid, workerLabel)
                self.centerButtonTitle = self.centerButtonTitleInvalid
            }
			else if (currentAlert == WorkerAlert.noExecuted) {
                self.title = self.titleNoExecuted
                self.text = self.textNoExecuted
                self.leftButtonTitle = self.leftButtonTitleNoExecuted
                self.rightButtonTitle = self.rightButtonTitleNoExecuted
            }
			else if (currentAlert == WorkerAlert.hardwareCapabilities) {
                self.title = self.titleHardwareCapabilities
                self.text = String(format: self.textHardwareCapabilities, workerLabel)
                self.centerButtonTitle = self.centerButtonTitleHardwareCapabilities;
            }
			else if (currentAlert == WorkerAlert.locationPermission) {
                self.title = self.titleLocationPermission
                self.text = String(format: self.textLocationPermission, workerLabel)
                self.centerButtonTitle = self.centerButtonLocationPermission
			}
			else if (currentAlert == WorkerAlert.notificationsPermission) {
				self.title = self.titleNotificationsPermission
				self.text = String(format: self.textNotificationsPermission, workerLabel)
				self.centerButtonTitle = self.centerButtonNotificationsPermission
			}
			else if (currentAlert == WorkerAlert.forceDisabled) {
				self.title = self.titleForceDisabled
				self.text =  self.textForceDisabled
			//	self.centerButtonTitle = self.centerButtonForceDisabled
			}
        }
    }
}
