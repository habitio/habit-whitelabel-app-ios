//
//  MZCreateWorkerViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 17/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
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


@objc protocol MZChangeWorkerDelegate {
    func didChangeWorker()
}

class MZCreateWorkerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var iconWorkers: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var agentNameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var finishButton: MZColorButton!

    fileprivate var loadingView: UIView!
    internal var workerVM: MZWorkerViewModel?
    internal var isEdit: Bool = false
    internal var isShortcut: Bool = false
    internal var delegate: MZChangeWorkerDelegate?
    internal var shortcutInteractor: MZShortcutsInteractor?
    
    fileprivate enum Section: Int {
        case trigger = 0,
        action,
        state,
        count
    }
    
    fileprivate var wireframe: MZRootWireframe!
    fileprivate var interactor: MZWorkersInteractor!
    fileprivate var hasMoreStates: Bool = true
    fileprivate var hasActionableDevices: Bool = true

    fileprivate var submittedChanges: Bool = false
    
    convenience init(withWireframe wireframe: MZRootWireframe, andInteractor interactor: MZWorkersInteractor) {
        self.init(nibName: "MZCreateWorkerViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.interactor = interactor
        
           }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactor.getUnGroupedDevicesFilterByType(["type":"actionable", "include" : "context,capabilities"], completion: { (results, error) in
            self.hasActionableDevices = false
            
            if let resultsArray = results as? NSArray
            {
                if(resultsArray.count > 0)
                {
                    for res in (results as! NSArray)
                    {
                        if(((res as! MZAreaViewModel).devicesViewModel as! NSArray).count > 0)
                        {
                            self.hasActionableDevices = true
                            break
                        }
                    }
                }
            }
        })

        
        if self.workerVM == nil {
            self.workerVM = MZWorkerViewModel(model: MZWorker())
        }
        
        self.setupInterface()
        
        if !self.isShortcut {
            if !self.isEdit {
                MZAnalyticsInteractor.workerCreateStartEvent()
            } else {
                MZAnalyticsInteractor.workerEditStartEvent((self.workerVM?.model?.identifier)!)
            }
        }
        else
        {
            if !self.isEdit
            {
                MZAnalyticsInteractor.shortcutCreateStartEvent()
                //self.addActionAction(self)
            }
            else
            {
                MZAnalyticsInteractor.shortcutEditStartEvent((self.workerVM?.model?.identifier)!)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateStatesFlag()
        self.updateTableFooter()
        self.finishButton.isEnabled =  (!self.isShortcut ? self.workerVM?.triggerDeviceVM != nil && self.workerVM?.actionDeviceVMs.count > 0 : self.workerVM?.actionDeviceVMs.count > 0)
        
        self.tableView.reloadData()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent == nil && !self.submittedChanges {
            if !self.isShortcut {
                if !self.isEdit {
                    MZAnalyticsInteractor.workerCreateCancelEvent()
                } else {
                    MZAnalyticsInteractor.workerEditCancelEvent((self.workerVM?.model?.identifier)!)
                }
            } else {
                if !self.isEdit {
                    MZAnalyticsInteractor.shortcutCreateCancelEvent()
                } else {
                    MZAnalyticsInteractor.shortcutEditCancelEvent((self.workerVM?.model?.identifier)!)
                }
            }
        }
    }
    
    fileprivate func setupInterface() {
        self.title = !self.isShortcut ? self.isEdit ? NSLocalizedString("mobile_worker_edit", comment: "") : NSLocalizedString("mobile_worker_add", comment: "") : self.isEdit ? NSLocalizedString("mobile_shortcut_edit", comment: "") : NSLocalizedString("mobile_shortcut_add", comment: "")
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        barButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        
        self.iconWorkers.image = UIImage(named: !self.isShortcut ? "IconWorkers" : "iconArrow")?.withRenderingMode(.alwaysTemplate)
        self.iconWorkers.tintColor = UIColor.muzzleyGrayColor(withAlpha: 1)
        
        self.view.bringSubview(toFront: self.headerView)
        self.headerView.layer.shadowColor = UIColor.muzzleyGrayColor(withAlpha: 0.5).cgColor
        self.headerView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.headerView.layer.shadowOpacity = 0.7
        self.headerView.layer.shadowRadius = 3.0
        
        self.agentNameField.tintColor = UIColor.muzzleyBlueColor(withAlpha: 1)
        self.agentNameField.placeholder = !self.isShortcut ? NSLocalizedString("mobile_worker_add_name", comment: "") : NSLocalizedString("mobile_shortcut_add_name", comment: "")
        self.agentNameField.text = self.workerVM?.label
        self.agentNameField.delegate = self
        self.agentNameField.addTarget(self, action: #selector(MZCreateWorkerViewController.textFieldValueChanged(_:)), for: .editingChanged)
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        self.tableView.separatorColor = UIColor.muzzleyGray4Color(withAlpha: 1.0)
        
        self.tableView.register(UINib(nibName: "MZAddButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "MZAddButtonTableViewCell")
        self.tableView.register(UINib(nibName: "MZWorkerRuleTableViewCell", bundle: nil), forCellReuseIdentifier: "MZWorkerRuleTableViewCell")
        
        self.finishButton.setTitle(NSLocalizedString("mobile_finish", comment: ""), for: .normal)
        self.finishButton.isEnabled = false
        
        self.view.bringSubview(toFront: self.footerView)
        self.footerView.layer.shadowColor = UIColor.muzzleyWhiteColor(withAlpha: 1).cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 0, height: -20.0)
        self.footerView.layer.shadowOpacity = 1.0
        self.footerView.layer.shadowRadius = 10.0
    }
    
    //TODO should it go to baseviewcontroller?
    internal func showLoadingView()
    {
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
    
    //TODO should it go to baseviewcontroller?
    internal func hideLoadingView()
    {
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
    
    fileprivate func updateStatesFlag() {
        var hasTime: Bool = self.workerVM?.triggerDeviceVM?.componentIds?.filter{ $0 == "time" }.count > 0
        var hasLocation: Bool = self.workerVM?.triggerDeviceVM?.componentIds?.filter{ $0 == "location" }.count > 0
        
        if !hasTime {
            var found = false
            for device: MZBaseWorkerDeviceViewModel in (self.workerVM?.stateDeviceVMs)! {
                found = device.componentIds?.filter{ $0 == "time" }.count > 0
                if found {
                    hasTime = found
                    break
                }
            }
        }
        
        if !hasLocation {
            var found = false
            for device: MZBaseWorkerDeviceViewModel in (self.workerVM?.stateDeviceVMs)! {
                found = device.componentIds?.filter{ $0 == "location" }.count > 0
                if found {
                    hasLocation = found
                    break
                }
            }
        }
        
        self.hasMoreStates = !hasTime || !hasLocation
    }
    
    fileprivate func updateTableFooter() {
        self.tableView.tableFooterView?.layer.sublayers?.forEach{ $0.removeFromSuperlayer() }
        if self.isShortcut || self.workerVM?.actionDeviceVMs.count > 0 || self.workerVM?.stateDeviceVMs.count > 0 {
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 10.0))
        } else {
            let footer: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 50.0))
            let stripeLayer: CAShapeLayer = CAShapeLayer()
            stripeLayer.path = UIBezierPath(rect: CGRect(x: 50.0, y: 0.0, width: 10.0, height: 1000.0)).cgPath
            stripeLayer.fillColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
            footer.layer.insertSublayer(stripeLayer, at: 0)
            self.tableView.tableFooterView = footer
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.isShortcut {
            if self.workerVM?.stateDeviceVMs.count > 0 {
                return Section.count.rawValue
            } else if self.workerVM?.actionDeviceVMs.count > 0 {
                return Section.count.rawValue - 1
            } else {
                return Section.count.rawValue - 2
            }
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isShortcut {
            switch section {
            case Section.trigger.rawValue: return self.workerVM?.triggerDeviceVM != nil ? (self.workerVM?.actionDeviceVMs.count > 0 ? 1 : (self.workerVM?.stateDeviceVMs.count > 0 ? 1 : 2)) : 1
            case Section.action.rawValue: return (self.workerVM?.actionDeviceVMs.count)! + (self.workerVM?.stateDeviceVMs.count > 0 ? 1 : 2)
            case Section.state.rawValue: return (self.workerVM?.stateDeviceVMs.count)! + (self.hasMoreStates ? 1 : 0)
                
            default: return 0
            }
        } else {
            switch section {
            case 0: return (self.workerVM?.actionDeviceVMs.count)! + 1
            case 1: return 0 //1 <- FIXME: replace to enable add to wath field
                
            default: return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !self.isShortcut {
            let backView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40.0))
            backView.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
            
            let hView = UIView(frame: CGRect(x: 16.0, y: 0.0, width: backView.frame.size.width - 32.0, height: backView.frame.size.height))
            hView.backgroundColor = UIColor.muzzleyGray4Color(withAlpha: 1.0)
            hView.layer.masksToBounds = true
            hView.layer.cornerRadius = 3
            backView.addSubview(hView)
            
            let hLabel = UILabel(frame: CGRect(x: 34.0, y: 0.0, width: hView.frame.size.width - 42.0, height: hView.frame.size.height))
            hLabel.font = UIFont.semiboldItalicFontOfSize(16)
            hLabel.textColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
            
            switch section {
            case Section.trigger.rawValue:
                hLabel.text = NSLocalizedString("mobile_choose_device_vc_first_step", comment: "")
            case Section.action.rawValue:
                hLabel.text = NSLocalizedString("mobile_choose_device_vc_second_step", comment: "")
            case Section.state.rawValue:
                hLabel.text = NSLocalizedString("mobile_choose_device_vc_third_step", comment: "")
                
            default:
                hLabel.text = ""
            }
            
            hView.addSubview(hLabel)
            
            return backView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return !self.isShortcut ? 40.0 : 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if !self.isShortcut {
            switch indexPath.section {
            case Section.trigger.rawValue:
                switch indexPath.row {
                case 0:
                    if self.workerVM?.triggerDeviceVM != nil {
                        let aCell: MZWorkerRuleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZWorkerRuleTableViewCell", for: indexPath) as! MZWorkerRuleTableViewCell
                        aCell.setViewModel(self.workerVM!.triggerDeviceVM!, indexPath: indexPath)
                        aCell.deleteButton.addTarget(self, action: #selector(MZCreateWorkerViewController.deleteTriggerAction(_:)), for: .touchUpInside)
                        cell = aCell
                    } else {
                        let aCell: MZAddButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZAddButtonTableViewCell", for: indexPath) as! MZAddButtonTableViewCell
                        aCell.addLabel.text = ""
                        aCell.isHalfHeight = false
                        aCell.isSmall = false
                        cell = aCell
                    }
                case 1:
                    let aCell: MZAddButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZAddButtonTableViewCell", for: indexPath) as! MZAddButtonTableViewCell
                    aCell.isHalfHeight = false
                    aCell.isSmall = false
                    aCell.addLabel.text = NSLocalizedString("mobile_choose_device_vc_second_step", comment: "")
                    
                    if(!self.hasActionableDevices)
                    {
                        aCell.isButtonEnabled = false
                    }
                   
                 
                    cell = aCell
                   
                default: break
                }
            case Section.action.rawValue:
                if indexPath.row < self.workerVM?.actionDeviceVMs.count {
                    let aCell: MZWorkerRuleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZWorkerRuleTableViewCell", for: indexPath) as! MZWorkerRuleTableViewCell
                    aCell.setViewModel(self.workerVM!.actionDeviceVMs[indexPath.row], indexPath: indexPath)
                    aCell.deleteButton.removeTarget(self, action:nil, for: .touchUpInside)
                    aCell.deleteButton.addTarget(self, action: #selector(MZCreateWorkerViewController.deleteActionAction(_:)), for: .touchUpInside)
                    if aCell.actionParameters.count > 0 {
                        aCell.actionParameters.forEach{ $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZCreateWorkerViewController.deleteActionParameterAction(_:)))) }
                    }
                    cell = aCell
                } else if indexPath.row == self.workerVM?.actionDeviceVMs.count {
                    let aCell: MZAddButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZAddButtonTableViewCell", for: indexPath) as! MZAddButtonTableViewCell
                    aCell.isSmall = true
                    aCell.addLabel.text = NSLocalizedString("mobile_choose_device_vc_fourth_step", comment: "")
                    cell = aCell
                } else {
                    let aCell: MZAddButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZAddButtonTableViewCell", for: indexPath) as! MZAddButtonTableViewCell
                    aCell.isHalfHeight = true
                    aCell.isSmall = false
                    aCell.addLabel.text = NSLocalizedString("mobile_choose_device_vc_third_step", comment: "")
                    cell = aCell
                }
            case Section.state.rawValue:
                if indexPath.row < self.workerVM?.stateDeviceVMs.count {
                    let aCell: MZWorkerRuleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZWorkerRuleTableViewCell", for: indexPath) as! MZWorkerRuleTableViewCell
                    aCell.setViewModel(self.workerVM!.stateDeviceVMs[indexPath.row], indexPath: indexPath)
                    aCell.deleteButton.removeTarget(self, action:nil, for: .touchUpInside)
                    aCell.deleteButton.addTarget(self, action: #selector(MZCreateWorkerViewController.deleteStateAction(_:)), for: .touchUpInside)
                    aCell.isHalfHeight = indexPath.row == (self.workerVM?.stateDeviceVMs.count)! - 1 && !self.hasMoreStates
                    cell = aCell
                } else {
                    let aCell: MZAddButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZAddButtonTableViewCell", for: indexPath) as! MZAddButtonTableViewCell
                    aCell.isSmall = true
                    aCell.isHalfHeight = true
                    aCell.addLabel.text = NSLocalizedString("mobile_choose_device_vc_fourth_step", comment: "")
                    cell = aCell
                }
                
            default: break
            }
        } else {
            switch indexPath.section {
            case 0:
                if indexPath.row < self.workerVM?.actionDeviceVMs.count {
                    let aCell: MZWorkerRuleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZWorkerRuleTableViewCell", for: indexPath) as! MZWorkerRuleTableViewCell
                    aCell.isBottomHalfHeight = indexPath.row == 0
                    aCell.setViewModel(self.workerVM!.actionDeviceVMs[indexPath.row], indexPath: indexPath)
                    aCell.deleteButton.removeTarget(self, action:nil, for: .touchUpInside)
                    aCell.deleteButton.addTarget(self, action: #selector(MZCreateWorkerViewController.deleteActionAction(_:)), for: .touchUpInside)
                    if aCell.actionParameters.count > 0 {
                        aCell.actionParameters.forEach{ $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZCreateWorkerViewController.deleteActionParameterAction(_:)))) }
                    }
                    cell = aCell
                } else if indexPath.row == self.workerVM?.actionDeviceVMs.count {
                    let aCell: MZAddButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZAddButtonTableViewCell", for: indexPath) as! MZAddButtonTableViewCell
                    aCell.isSmall = true
                    aCell.hasStripe = self.workerVM?.actionDeviceVMs.count > 0
                    aCell.isHalfHeight = self.workerVM?.actionDeviceVMs.count > 0
                    aCell.addLabel.text = NSLocalizedString("mobile_device_add", comment: "")
                    cell = aCell
                }
            case 1:
                // TODO: available on watch cell
                break
                
            default: break
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !self.isShortcut {
            switch indexPath.section {
            case Section.trigger.rawValue:
                switch indexPath.row {
                case 0:
                    if self.workerVM?.triggerDeviceVM != nil {
                        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                        style.lineBreakMode = .byWordWrapping
                        let contentHeight: CGFloat = self.workerVM!.triggerDeviceVM!.items[0].stateDescription.string.boundingRect(with: CGSize(width: MZWorkerRuleTableViewCell.contentWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil).size.height
                        return MZWorkerRuleTableViewCell.minHeight + (contentHeight > MZWorkerRuleTableViewCell.contentMinHeight ? contentHeight - MZWorkerRuleTableViewCell.contentMinHeight : 0.0)
                    } else {
                        return MZAddButtonTableViewCell.height
                    }
                
                case 1:
                    if(self.hasActionableDevices)
                    {
                        return MZAddButtonTableViewCell.height
                    }
                    else
                    {
                        return MZAddButtonTableViewCell.height + 60
                    }
                default: return 0.0
                }
            case Section.action.rawValue:
                if indexPath.row < self.workerVM?.actionDeviceVMs.count {
                    return MZWorkerRuleTableViewCell.minHeight + (self.workerVM!.actionDeviceVMs[indexPath.row].items.count > 1 ? CGFloat(self.workerVM!.actionDeviceVMs[indexPath.row].items.count - 1) * MZWorkerRuleTableViewCell.contentMinHeight + CGFloat(self.workerVM!.actionDeviceVMs[indexPath.row].items.count - 2) / UIScreen.main.scale : 0.0)
                }
                else
                {
                    return MZAddButtonTableViewCell.height
                }
            case Section.state.rawValue:
                if indexPath.row < self.workerVM?.stateDeviceVMs.count {
                    let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    style.lineBreakMode = .byWordWrapping
                    let contentHeight: CGFloat = self.workerVM!.stateDeviceVMs[indexPath.row].items[0].stateDescription.string.boundingRect(with: CGSize(width: MZWorkerRuleTableViewCell.contentWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil).size.height
                    return MZWorkerRuleTableViewCell.minHeight + (contentHeight > MZWorkerRuleTableViewCell.contentMinHeight ? contentHeight - MZWorkerRuleTableViewCell.contentMinHeight : 0.0)
                } else {
                    return MZAddButtonTableViewCell.height
                }
                
            default: return 0.0
            }
        } else {
            switch indexPath.section {
            case 0:
                if indexPath.row < self.workerVM?.actionDeviceVMs.count {
                    return MZWorkerRuleTableViewCell.minHeight + (self.workerVM!.actionDeviceVMs[indexPath.row].items.count > 1 ? CGFloat(self.workerVM!.actionDeviceVMs[indexPath.row].items.count - 1) * MZWorkerRuleTableViewCell.contentMinHeight + CGFloat(self.workerVM!.actionDeviceVMs[indexPath.row].items.count - 2) / UIScreen.main.scale : 0.0)
                } else {
                    return MZAddButtonTableViewCell.height
                }
            case 1: return 50.0
                
            default: return 0.0
            }
        }
    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isShortcut {
            switch indexPath.section {
            case Section.trigger.rawValue:
                switch indexPath.row {
                case 0:
                    if self.workerVM?.triggerDeviceVM != nil {
                        // TODO: we cannot edit
                        // self.editTriggerAction(self)
                    } else {
                        self.addTriggerAction(self)
                    }
                case 1:
                    self.addActionAction(self)
                    
                default: break
                }
            case Section.action.rawValue:
                if indexPath.row < self.workerVM?.actionDeviceVMs.count {
                    // TODO: we cannot edit
                    // self.editActionAction(self)
                } else if indexPath.row == self.workerVM?.actionDeviceVMs.count {
                    self.addActionAction(self)
                } else {
                    self.addStateAction(self)
                }
            case Section.state.rawValue:
                if indexPath.row < self.workerVM?.stateDeviceVMs.count {
                    // TODO: we cannot edit
                    // self.editStateAction(self)
                } else {
                    self.addStateAction(self)
                }
                
            default: break
            }
        } else {
            switch indexPath.section {
            case 0:
                if indexPath.row < self.workerVM?.actionDeviceVMs.count {
                    // TODO: we cannot edit
                } else if indexPath.row == self.workerVM?.actionDeviceVMs.count {
                    self.addActionAction(self)
                }
            case 1:
                // TODO: change checkmark for watch availability
                break
                
            default: break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - UITextField Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.workerVM?.label = textField.text!
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textFieldValueChanged(_ textField: UITextField) {
        self.workerVM?.label = textField.text!
        self.finishButton.isEnabled =  (!self.isShortcut ? self.workerVM?.triggerDeviceVM != nil && self.workerVM?.actionDeviceVMs.count > 0 : self.workerVM?.actionDeviceVMs.count > 0)
    }
    
    
    // MARK: - UIButtons Actions
    
    @IBAction func finishAction(_ sender: AnyObject)
	{
		if(self.agentNameField.text!.isEmpty)
		{
			self.agentNameField.becomeFirstResponder()
			return
		}
		
		self.showLoadingView()

        if !self.isShortcut {
            if self.isEdit {
                self.interactor!.editWorker(self.workerVM!, completion: { (result, error) -> Void in
                    // FIXME:  channel is nil so we cannot get profile name
                    var actionArray: [String] = []
                    self.workerVM?.actionDeviceVMs.forEach{ actionArray.append($0.model?.tile?.channel != nil ? ($0.model?.tile?.channel?.profileName)! : "") }
                    if error == nil {
                        MZAnalyticsInteractor.workerEditFinishEvent((self.workerVM?.model?.identifier)!, errorMessage: nil)
                        
                        self.submittedChanges = true
                        self.delegate?.didChangeWorker()
                        self.wireframe.popViewController(animated: true)
                    } else {
                        MZAnalyticsInteractor.workerEditFinishEvent((self.workerVM?.model?.identifier)!, errorMessage: error?.localizedDescription)
                        
                        let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""),
                            message: NSLocalizedString("mobile_worker_edit_text", comment: ""), preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                        self.present(error, animated: true, completion: nil)
                    }
                    self.hideLoadingView()
                })
            } else {
                self.interactor!.createWorker(self.workerVM!, completion: { (result, error) -> Void in
                    var actionArray: [String] = []
                    
                    if(result is NSDictionary)
                    {
                        let result = result as! NSDictionary?
                        self.workerVM?.actionDeviceVMs.forEach{ actionArray.append(($0.model?.tile?.channel?.profileName)!) }
                        if error == nil
                        {
                            MZAnalyticsInteractor.workerCreateFinishEvent(result!["id"] as! String, errorMessage: nil)
                        
                            self.submittedChanges = true
                            self.delegate?.didChangeWorker()
                            self.wireframe.popViewController(animated: true)
                        } else {
                            MZAnalyticsInteractor.workerCreateFinishEvent(result == nil ? "" : result!["id"] as! String, errorMessage: error?.localizedDescription)
                        
                            let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""),
                            message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                    }
                    else
                    {                        
                        let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""),
                                                                         message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
                        error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                        self.present(error, animated: true, completion: nil)
                    }
                
                    self.hideLoadingView()
                })
            }
        } else {
            if self.shortcutInteractor != nil {
                if self.isEdit {
                    self.shortcutInteractor?.editShortcut((self.workerVM!.model?.identifier)!, shortcutVM: self.workerVM!, inWatch: (self.workerVM?.inWatch)!, completion: { (result, error) -> Void in
                        if error == nil {
                            MZAnalyticsInteractor.shortcutEditFinishEvent((self.workerVM?.model?.identifier)!, errorMessage: nil)
                            
                            self.submittedChanges = true
                            self.delegate?.didChangeWorker()
                            self.wireframe.popViewController(animated: true)
                        } else {
                            MZAnalyticsInteractor.shortcutEditFinishEvent((self.workerVM?.model?.identifier)!, errorMessage: error?.localizedDescription)
                            
                            let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""),
                                message: NSLocalizedString("mobile_shortcut_edit_text", comment: ""), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                        self.hideLoadingView()
                    })
                } else {
                    self.shortcutInteractor?.createShortcut(self.workerVM!, inWatch: (self.workerVM?.inWatch)!, completion: { (result, error) -> Void in
                        if error == nil {
                            let shortcutId: String = (result!["id"] as? String) == nil ? "" : result!["id"] as! String
                            MZAnalyticsInteractor.shortcutCreateFinishEvent(shortcutId, errorMessage: nil)
                            
                            self.submittedChanges = true
                            self.delegate?.didChangeWorker()
                            self.wireframe.popViewController(animated: true)
                        } else {
							//  let shortcutId: String = (result == nil ? "" : result!["id"] as? String) == nil ? "" : result!["id"] as! String
                            MZAnalyticsInteractor.shortcutCreateFinishEvent("", errorMessage: error?.localizedDescription)
                            
                            let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""),
                                message: NSLocalizedString("mobile_shortcut_edit_text", comment: ""), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                        self.hideLoadingView()
                    })
                }
            }
        }
    }
    
    // MARK: Trigger
    
    @IBAction func addTriggerAction(_ sender: AnyObject) {
        if self.isEdit {
            MZAnalyticsInteractor.workerEditAddTriggerStartEvent((self.workerVM?.model?.identifier)!)
        } else {
            MZAnalyticsInteractor.workerCreateAddTriggerStartEvent()
        }
        let deviceChooser: MZChooseDeviceViewController = MZChooseDeviceViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
        deviceChooser.type = MZWorker.key_trigger
		deviceChooser.workerVM = self.workerVM
        deviceChooser.isUpdate = self.isEdit
        deviceChooser.isShortcut = self.isShortcut
        self.wireframe.pushViewController(toEnd: deviceChooser, animated: true)
    }
    
    @IBAction func editTriggerAction(_ sender: AnyObject) {
//        if self.isEdit {
//            MZAnalyticsInteractor.routineEditEditTriggerStartEvent((self.workerVM?.model?.identifier)!, triggerName: (self.workerVM?.triggerDeviceVM?.model?.tile?.channel?.profileName)!)
//        } else {
//            MZAnalyticsInteractor.routineCreateEditTriggerStartEvent ((self.workerVM?.triggerDeviceVM?.model?.tile?.channel?.profileName)!)
//        }
        // TODO: to be implemented
//        let deviceChooser: MZChooseDeviceViewController = MZChooseDeviceViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
//        deviceChooser.type = MZWorker.key_trigger
//        deviceChooser.workerVM = self.workerVM
//        deviceChooser.isUpdate = self.isEdit
//        deviceChooser.isShortcut = self.isShortcut
//        deviceChooser.isEdit = true
//        self.wireframe.pushViewControllerToEnd(deviceChooser, animated: true)
    }
    
    @IBAction func deleteTriggerAction(_ sender: AnyObject)
    {
        let triggerProfileId: String = self.workerVM!.triggerDeviceVM!.model!.tile!.profileId
        let triggerName: String = self.workerVM!.triggerDeviceVM!.title!

        self.workerVM?.triggerDeviceVM = nil
        self.tableView.reloadSections(IndexSet(integer: Section.trigger.rawValue), with: .automatic)
        self.workerVM?.stateDeviceVMs.removeAll()
        self.updateStatesFlag()
        self.tableView.reloadData()
        self.finishButton.isEnabled = self.workerVM?.triggerDeviceVM != nil && self.workerVM?.actionDeviceVMs.count > 0
        self.updateTableFooter()
        
        if self.isEdit
        {
            MZAnalyticsInteractor.workerEditDeleteTriggerDoneEvent(self.workerVM!.model!.identifier,
                                                                   profileID: triggerProfileId,
                                                                   deviceName: triggerName)
        } else {
            MZAnalyticsInteractor.workerCreateDeleteTriggerDoneEvent(triggerProfileId,
                                                                     deviceName: triggerName)
        }
    }
    
    // MARK: Action
    
    @IBAction func addActionAction(_ sender: AnyObject) {
        if self.isShortcut {
            if self.isEdit {
                MZAnalyticsInteractor.shortcutEditAddActionStartEvent((self.workerVM?.model?.identifier)!)
            } else {
                MZAnalyticsInteractor.shortcutCreateAddActionStartEvent()
            }
        } else {
            if self.isEdit {
                MZAnalyticsInteractor.workerEditAddActionStartEvent((self.workerVM?.model?.identifier)!)
            } else {
                MZAnalyticsInteractor.workerCreateAddActionStartEvent()
            }
        }
        let deviceChooser: MZChooseDeviceViewController = MZChooseDeviceViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
        deviceChooser.type = MZWorker.key_action
        deviceChooser.isShortcuts = self.isShortcut
        deviceChooser.workerVM = self.workerVM
        deviceChooser.isUpdate = self.isEdit
        deviceChooser.isShortcut = self.isShortcut
        self.wireframe.pushViewController(toEnd: deviceChooser, animated: true)
    }
    
    @IBAction func editActionAction(_ sender: AnyObject) {
//        let action: MZBaseWorkerDeviceViewModel = (self.workerVM?.actionDeviceVMs[((sender as! MZWorkerDeleteButton).indexPath?.row)!])!
//        if self.isShortcut {
//            if self.isEdit {
//                MZAnalyticsInteractor.shortcutEditEditActionStartEvent((self.workerVM?.model?.identifier)!, actionName: (action.model?.tile?.channel?.profileName)!)
//            } else {
//                MZAnalyticsInteractor.shortcutCreateEditActionStartEvent((action.model?.tile?.channel?.profileName)!)
//            }
//        } else {
//            if self.isEdit {
//                MZAnalyticsInteractor.routineEditEditActionStartEvent((self.workerVM?.model?.identifier)!, actionName: (action.model?.tile?.channel?.profileName)!)
//            } else {
//                MZAnalyticsInteractor.routineCreateEditActionStartEvent((action.model?.tile?.channel?.profileName)!)
//            }
//        }
        // TODO: to be implemented
//        let deviceChooser: MZChooseDeviceViewController = MZChooseDeviceViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
//        deviceChooser.type = MZWorker.key_action
//        deviceChooser.workerVM = self.workerVM
//        deviceChooser.isUpdate = self.isEdit
//        deviceChooser.isEdit = true
//        deviceChooser.isShortcut = self.isShortcut
//        self.wireframe.pushViewControllerToEnd(deviceChooser, animated: true)
    }
    
    @IBAction func deleteActionAction(_ sender: AnyObject) {
        let action: MZBaseWorkerDeviceViewModel = (self.workerVM?.actionDeviceVMs[((sender as! MZWorkerDeleteButton).indexPath?.row)!])!
        let actionProfileId: String = action.model!.tile!.profileId
        self.workerVM?.actionDeviceVMs.remove(at: ((sender as! MZWorkerDeleteButton).indexPath?.row)!)
        self.updateStatesFlag()
        if self.workerVM?.actionDeviceVMs.count > 0 {
            self.tableView.reloadSections(IndexSet(integer: !self.isShortcut ? Section.action.rawValue : 0), with: .automatic)
        } else {
            self.tableView.reloadData()
        }
        self.finishButton.isEnabled = (!self.isShortcut ? self.workerVM?.triggerDeviceVM != nil && self.workerVM?.actionDeviceVMs.count > 0 : self.workerVM?.actionDeviceVMs.count > 0)
        self.updateTableFooter()
        if self.isShortcut {
            if self.isEdit {
                MZAnalyticsInteractor.shortcutEditDeleteActionDoneEvent((self.workerVM?.model?.identifier)!, profileID: actionProfileId, deviceName: action.title!)
            } else {
                MZAnalyticsInteractor.shortcutCreateDeleteActionDoneEvent(actionProfileId, deviceName: action.title!)
            }
        } else {
            if self.isEdit {
                MZAnalyticsInteractor.workerEditDeleteActionDoneEvent((self.workerVM?.model?.identifier)!, profileID: actionProfileId, deviceName: action.title!)
            } else {
                MZAnalyticsInteractor.workerCreateDeleteActionDoneEvent(actionProfileId, deviceName: (self.workerVM?.triggerDeviceVM?.title)!)
            }
        }
    }
    
    @IBAction func deleteActionParameterAction(_ sender: UITapGestureRecognizer) {
        let action: MZBaseWorkerDeviceViewModel = (self.workerVM?.actionDeviceVMs[((sender.view as! MZWorkerDeleteLabel).indexPath?.row)!])!
        let actionProfileId: String = action.model!.tile!.profileId
        self.workerVM?.actionDeviceVMs[((sender.view as! MZWorkerDeleteLabel).indexPath?.row)!].items.remove(at: (sender.view as! MZWorkerDeleteLabel).position!)
        self.updateStatesFlag()
        if self.workerVM?.actionDeviceVMs[((sender.view as! MZWorkerDeleteLabel).indexPath?.row)!].items.count > 0 {
            self.tableView.reloadRows(at: [IndexPath(row: ((sender.view as! MZWorkerDeleteLabel).indexPath?.row)!, section: !self.isShortcut ? Section.action.rawValue : 0)], with: .automatic)
        } else {
            self.workerVM?.actionDeviceVMs.remove(at: ((sender.view as! MZWorkerDeleteLabel).indexPath?.row)!)
            self.updateStatesFlag()
            if self.workerVM?.actionDeviceVMs.count > 0 {
                self.tableView.reloadSections(IndexSet(integer: !self.isShortcut ? Section.action.rawValue : 0), with: .automatic)
            } else {
                self.tableView.reloadData()
            }
        }
        
        if self.isShortcut {
            if self.isEdit {
                MZAnalyticsInteractor.shortcutEditDeleteRuleActionDoneEvent(self.workerVM!.model!.identifier,
                                                                            profileID: actionProfileId,
                                                                            deviceName: action.title!)
            } else {
                MZAnalyticsInteractor.shortcutCreateDeleteRuleActionDoneEvent(actionProfileId,
                                                                              deviceName: action.title!)
            }
        } else {
            if self.isEdit {
                MZAnalyticsInteractor.workerEditDeleteRuleActionDoneEvent(self.workerVM!.model!.identifier,
                                                                          profileID: actionProfileId,
                                                                          deviceName: action.title!)
            } else {
                MZAnalyticsInteractor.workerCreateDeleteRuleActionDoneEvent(actionProfileId,
                                                                            deviceName: action.title!)
            }
        }
    }
    
    // MARK: State
    @IBAction func addStateAction(_ sender: AnyObject) {
        if self.isEdit {
            MZAnalyticsInteractor.workerEditAddStateStartEvent((self.workerVM?.model?.identifier)!)
        } else {
            MZAnalyticsInteractor.workerCreateAddStateStartEvent()
        }
        let deviceChooser: MZChooseDeviceViewController = MZChooseDeviceViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
        deviceChooser.type = MZWorker.key_state
        deviceChooser.workerVM = self.workerVM
        deviceChooser.isUpdate = self.isEdit
        self.wireframe.pushViewController(toEnd: deviceChooser, animated: true)
    }
    
    @IBAction func editStateAction(_ sender: AnyObject) {
//        let state: MZBaseWorkerDeviceViewModel = (self.workerVM?.stateDeviceVMs[((sender as! MZWorkerDeleteButton).indexPath?.row)!])!
//        let profileId: String = state.model!.tile!.profileId

//        if self.isEdit {
//            MZAnalyticsInteractor.routineEditEditStateStartEvent((self.workerVM?.model?.identifier)!, stateName: stateName)
//        } else {
//            MZAnalyticsInteractor.routineCreateEditStateStartEvent(stateName)
//        }
        // TODO: to be implemented
//        let deviceChooser: MZChooseDeviceViewController = MZChooseDeviceViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
//        deviceChooser.type = MZWorker.key_state
//        deviceChooser.workerVM = self.workerVM
//        deviceChooser.isUpdate = self.isEdit
//        deviceChooser.isEdit = true
//        self.wireframe.pushViewControllerToEnd(deviceChooser, animated: true)
    }
    
    @IBAction func deleteStateAction(_ sender: AnyObject) {
        let state: MZBaseWorkerDeviceViewModel = (self.workerVM?.stateDeviceVMs[((sender as! MZWorkerDeleteButton).indexPath?.row)!])!
        let stateProfileId: String = state.model!.tile!.profileId
        
        self.workerVM?.stateDeviceVMs.remove(at: ((sender as! MZWorkerDeleteButton).indexPath?.row)!)
        self.updateStatesFlag()
        if self.workerVM?.stateDeviceVMs.count > 0 {
            self.tableView.reloadSections(IndexSet(integer: Section.state.rawValue), with: .automatic)
        } else {
            self.tableView.reloadData()
        }
        self.finishButton.isEnabled = self.workerVM?.triggerDeviceVM != nil && self.workerVM?.actionDeviceVMs.count > 0
        self.updateTableFooter()
        if self.isEdit {
            MZAnalyticsInteractor.workerEditDeleteStateDoneEvent(self.workerVM!.model!.identifier, profileID: stateProfileId, deviceName: state.title!)
        } else {
            MZAnalyticsInteractor.workerCreateDeleteStateDoneEvent(stateProfileId, deviceName: state.title!)
        }
    }
    
}
