//
//  MZShortcutsViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 25/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


@objc protocol MZShortcutsDelegate {
    func updatedShortcuts(_ shortcuts: [MZShortcutViewModel])
}

class MZShortcutsViewController: BaseViewController, MZChangeWorkerDelegate, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var lessButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    internal var delegate: MZShortcutsDelegate?
    internal var shortScreen: UIImage?
    internal var shortPositions: [CGPoint]?
    internal var myShortcuts: [MZShortcutViewModel]?
    internal var sugestedShortcuts: [MZShortcutViewModel]?
    
    fileprivate enum Section: Int {
        case myShortCuts = 0,
        suggested,
        count
    }
    
    fileprivate var wireframe: MZRootWireframe!
    fileprivate var interactor: MZCardsInteractor!
    fileprivate var shortcutsInteractor: MZShortcutsInteractor!
    fileprivate var tabBarOverlay: UIView!
    fileprivate var loadingView: UIView!
	fileprivate var inEditMode: Bool = false
    fileprivate var orderChanged: Bool = false
    fileprivate var isLoadingSuggestions: Bool = false
    
    convenience init(withWireframe wireframe: MZRootWireframe, andInteractor interactor: MZShortcutsInteractor) {
        self.init(nibName: "MZShortcutsViewController", bundle: Bundle.main)
        
        self.wireframe = wireframe
        self.shortcutsInteractor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupInterface()
//        self.doInitialAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
       self.overlayTabBar()
    }
    
    fileprivate func setupInterface() {
        self.view.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 0.95)
        
        self.lessButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("mobile_show_less", comment: ""), attributes: [NSFontAttributeName: UIFont.regularFontOfSize(14), NSForegroundColorAttributeName: UIColor.muzzleyBlueColor(withAlpha: 1.0)]), for: UIControlState())
        self.lessButton.sizeToFit()
        self.lessButton.addTarget(self, action: #selector(MZShortcutsViewController.showLessAction(_:)), for: .touchUpInside)

        self.tableView.backgroundColor = UIColor.clear
        self.tableView.register(UINib(nibName: "MZShortcutsTableViewCell", bundle: nil), forCellReuseIdentifier: "MZShortcutsTableViewCell")
        self.tableView.tableFooterView = UIView()

        self.isLoadingSuggestions = true

        self.shortcutsInteractor.getSuggestedShortcuts { (result, error) -> Void in
            self.isLoadingSuggestions = false
            if error == nil {
                self.sugestedShortcuts = result
            }
            self.tableView.reloadData()
        }
    }
    
    fileprivate func overlayTabBar()
    {
        if self.tabBarOverlay == nil
        {
            if self.parent?.view.superview?.superview?.superview?.superview != nil
            {
                var tabBar: MZTabBar? = nil
                
                for (_, view) in (self.parent?.view.superview?.superview?.superview?.superview?.subviews.enumerated())!
                {
                    if view is UICollectionView
                    {
                        (view as! UICollectionView).isScrollEnabled = false
                    }
                    else if view is MZTabBar
                    {
                        tabBar = view as? MZTabBar
                    }
                }
                
                self.tabBarOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: tabBar!.frame.size.height))
                self.tabBarOverlay.tag = 9999
                self.tabBarOverlay.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.5)
                self.tabBarOverlay.alpha = 0.0
                tabBar?.addSubview(self.tabBarOverlay)
                tabBar?.bringSubview(toFront: self.tabBarOverlay)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.tabBarOverlay.alpha = 1.0
                })
            }
        }
    }
    
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
    
    fileprivate func doInitialAnimation()
    {
        // TODO
        // Put screenshot on place
        // Recreate shortcuts on place
        // calculate final positions
        // define animation path
        // animate
        // hide screenshot and show tableview and button
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return Section.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case Section.myShortCuts.rawValue:
                return self.myShortcuts?.count < 6 ? 6 : (self.myShortcuts?.count)! + 1
            case
                Section.suggested.rawValue: return self.sugestedShortcuts?.count > 0 ? (self.sugestedShortcuts?.count)! : 1

            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 24.0))
        backView.backgroundColor = UIColor.clear

        let hView = UIView(frame: CGRect(x: 14.0, y: 0.0, width: backView.frame.size.width - 28.0, height: backView.frame.size.height))
        hView.backgroundColor = UIColor.muzzleyDarkWhiteColor(withAlpha: 1.0)
        hView.layer.masksToBounds = true
        hView.layer.cornerRadius = 3.0
        backView.addSubview(hView)

        let hLabel = UILabel(frame: CGRect(x: 8.0, y: 0.0, width: hView.frame.size.width - 16.0, height: hView.frame.size.height))
        hLabel.font = UIFont.semiboldFontOfSize(14)
        hLabel.textColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)

        switch section
        {
            case Section.myShortCuts.rawValue: hLabel.text = NSLocalizedString("mobile_shortcut_my", comment: "")
            case Section.suggested.rawValue: hLabel.text = NSLocalizedString("mobile_shortcut_suggestion", comment: "")
            default: hLabel.text = ""
        }
        hView.addSubview(hLabel)

        return backView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell? = UITableViewCell()

        switch indexPath.section
        {
        case Section.myShortCuts.rawValue:
            let aCell: MZShortcutsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZShortcutsTableViewCell", for: indexPath) as! MZShortcutsTableViewCell

            if self.myShortcuts?.count > indexPath.row {

//                aCell.isEditting = self.inEditMode
//                aCell.setViewModel(self.myShortcuts![indexPath.row], forIndexPath: indexPath)
//                aCell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(MZShortcutsViewController.cellsLongPressAction(_:))))
//                aCell.deleteIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MZShortcutsViewController.deleteShortcutAction(_:))))
//                aCell.selectionStyle = self.myShortcuts![indexPath.row].isValid ? .default : .none
            }
            cell = aCell

            break
            
        case Section.suggested.rawValue:
            if self.sugestedShortcuts?.count > indexPath.row {
                let aCell: MZShortcutsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MZShortcutsTableViewCell", for: indexPath) as! MZShortcutsTableViewCell
                aCell.setViewModel(self.sugestedShortcuts![indexPath.row], forIndexPath: indexPath)
                cell = aCell
            } else {
                if self.isLoadingSuggestions
                {
                    var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
                    if aCell == nil {
                        aCell = UITableViewCell(style: .default, reuseIdentifier: "loadingCell")
                    }

                    aCell?.subviews.forEach{ $0.removeFromSuperview() }
                    let loading: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2.0 - 20.0, y: 0.0, width: 40.0, height: 40.0))
                    loading.activityIndicatorViewStyle = .gray
                    aCell?.addSubview(loading)
                    loading.startAnimating()
                    aCell?.selectionStyle = .none
                    cell = aCell
                }
                else
                {
                    var aCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "infoCell")
                    if aCell == nil
                    {
                        aCell = UITableViewCell(style: .default, reuseIdentifier: "infoCell")
                    }

                    aCell?.textLabel?.numberOfLines = 1
                    aCell?.textLabel?.text = NSLocalizedString("mobile_shortcut_no_suggestion", comment: "")
                    aCell?.textLabel?.font = UIFont.regularFontOfSize(18)
                    aCell?.textLabel?.textColor = UIColor.muzzleyGray3Color(withAlpha: 1.0)
                    aCell?.selectionStyle = .none
                    cell = aCell
                }
            }
            break

        default: break
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == Section.suggested.rawValue && self.sugestedShortcuts?.count <= indexPath.row ? 44.0 : 76.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Section.myShortCuts.rawValue:
            if self.myShortcuts?.count > indexPath.row {
                if self.myShortcuts![indexPath.row].isValid {
                    if self.inEditMode {
                        switch(MZThemeManager.sharedInstance.appInfo.namespace)
                        {
                        case "allianz.smarthome":
                            let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_no_actionable_devices_text", comment: ""), message: "", preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                            self.wireframe.present(error, animated: true, completion: nil)

                            break
                        default:
                            self.showLoadingView()
                            let createShortcutVC: MZCreateWorkerViewController = MZCreateWorkerViewController(withWireframe: self.wireframe, andInteractor: MZWorkersInteractor())
                            createShortcutVC.delegate = self
                            createShortcutVC.isShortcut = true
                            createShortcutVC.isEdit = true
                            createShortcutVC.shortcutInteractor = self.shortcutsInteractor
                            createShortcutVC.workerVM = self.myShortcuts![indexPath.row]
                            createShortcutVC.workerVM?.inWatch = self.myShortcuts![indexPath.row].shortcutModel!.showInWatch
                            self.hideLoadingView()
                            self.wireframe.pushViewController(toEnd: createShortcutVC, animated: true)
                            break
                        }

                    } else if !self.myShortcuts![indexPath.row].isRunning {
                        self.myShortcuts![indexPath.row].isRunning = true
                        (tableView.cellForRow(at: indexPath) as! MZShortcutsTableViewCell).startrunningAnimation()
                        var counter: Int = self.myShortcuts![indexPath.row].shortcutModel!.executeParams.count
                        MZAnalyticsInteractor.shortcutExecuteEvent(self.myShortcuts![indexPath.row].shortcutModel!.identifier,
                                                                   fromWhere: MIXPANEL_VALUE_APP,
                                                                   source: self.myShortcuts![indexPath.row].origin)
                        self.shortcutsInteractor.executeShortcut(self.myShortcuts![indexPath.row], completion: { (result, error) -> Void in
                            counter -= 1
                            if counter == 0 {
                                (tableView.cellForRow(at: indexPath) as! MZShortcutsTableViewCell).stopRunningAnimation()
                                self.myShortcuts![indexPath.row].isRunning = false
                            }
                        })
                    }
                }
            }
            else
            {
                switch(MZThemeManager.sharedInstance.appInfo.namespace)
                {
                case "allianz.smarthome":

                    let error: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_no_actionable_devices_text", comment: ""), message: "", preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
                    self.wireframe.present(error, animated: true, completion: nil)

                    break

                default:
                    let createShortcutVC: MZCreateWorkerViewController = MZCreateWorkerViewController(withWireframe: self.wireframe, andInteractor: MZWorkersInteractor())
                    createShortcutVC.delegate = self
                    createShortcutVC.isShortcut = true
                    createShortcutVC.isEdit = false
                    createShortcutVC.shortcutInteractor = self.shortcutsInteractor
                    self.wireframe.pushViewController(toEnd: createShortcutVC, animated: true)
                }
            }
        case Section.suggested.rawValue:
            if self.sugestedShortcuts?.count > indexPath.row  {
                if !self.sugestedShortcuts![indexPath.row].isRunning {
                    self.sugestedShortcuts![indexPath.row].isRunning = true
                    (tableView.cellForRow(at: indexPath) as! MZShortcutsTableViewCell).startrunningAnimation()
                    var counter: Int = self.sugestedShortcuts![indexPath.row].shortcutModel!.executeParams.count
                    MZAnalyticsInteractor.shortcutExecuteEvent(self.sugestedShortcuts![indexPath.row].shortcutModel!.identifier, fromWhere: MIXPANEL_VALUE_APP, source: "contextual")
                    self.shortcutsInteractor.executeShortcut(self.sugestedShortcuts![indexPath.row], completion: { (result, error) -> Void in
                        counter -= 1
                        if counter == 0 {
                            (tableView.cellForRow(at: indexPath) as! MZShortcutsTableViewCell).stopRunningAnimation()
                            self.sugestedShortcuts![indexPath.row].isRunning = false
                        }
                    })
                }
            }
            break

        default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return indexPath.section == Section.myShortCuts.rawValue && self.myShortcuts?.count > indexPath.row
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath.section == sourceIndexPath.section && self.myShortcuts?.count > proposedDestinationIndexPath.row ? proposedDestinationIndexPath : sourceIndexPath
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if sourceIndexPath != destinationIndexPath {
            if destinationIndexPath.section == sourceIndexPath.section && self.myShortcuts?.count > destinationIndexPath.row {
                self.myShortcuts?.insert((self.myShortcuts?.remove(at: sourceIndexPath.row))!, at: destinationIndexPath.row)
                self.orderChanged = true
            }
        }
    }

    
    // MARK: - Buttons Actions
    
    @IBAction func showLessAction(_ sender: AnyObject) {
        if self.inEditMode {
            self.inEditMode = !self.inEditMode
            self.tableView.setEditing(self.inEditMode, animated: true)
            self.tableView.reloadData()
            if self.orderChanged {
                var order: [String] = []
                self.myShortcuts?.forEach{ order.append($0.shortcutModel!.identifier) }
                self.shortcutsInteractor.setShortcutOrder(order, completion: { (result, error) -> Void in
                    self.delegate?.updatedShortcuts(self.myShortcuts!)
                })
            }
            self.orderChanged = false
            self.lessButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("mobile_show_less", comment: ""), attributes: [NSFontAttributeName: UIFont.regularFontOfSize(14), NSForegroundColorAttributeName: UIColor.muzzleyBlueColor(withAlpha: 1.0)]), for: UIControlState())
        } else {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.view.alpha = 0.0
                if self.tabBarOverlay != nil {
                    self.tabBarOverlay.alpha = 0.0
                }
            }, completion: { (success) -> Void in
                if self.tabBarOverlay != nil {
                    self.tabBarOverlay.removeFromSuperview()
                    self.tabBarOverlay = nil
                }
                
                if self.parent != nil {
                    for (_, view) in (self.parent?.view.superview?.superview?.superview?.superview?.subviews.enumerated())! {
                        if view is UICollectionView {
                            (view as! UICollectionView).isScrollEnabled = true
                        }
                    }
                }
                
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }) 
        }
    }
    
    @IBAction func cellsLongPressAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.inEditMode = !self.inEditMode
            self.tableView.setEditing(self.inEditMode, animated: true)
            self.tableView.reloadData()
            if self.orderChanged {
                var order: [String] = []
                self.myShortcuts?.forEach{ order.append($0.shortcutModel!.identifier) }
                self.shortcutsInteractor.setShortcutOrder(order, completion: { (result, error) -> Void in
                    self.delegate?.updatedShortcuts(self.myShortcuts!)
                })
            }
            self.orderChanged = false
            self.lessButton.setAttributedTitle(NSAttributedString(string: self.inEditMode ? NSLocalizedString("mobile_done", comment: "") : NSLocalizedString("mobile_show_less", comment: ""), attributes: [NSFontAttributeName: UIFont.regularFontOfSize(14), NSForegroundColorAttributeName: UIColor.muzzleyBlueColor(withAlpha: 1.0)]), for: UIControlState())
        }
    }
    
    @IBAction func deleteShortcutAction(_ sender: UITapGestureRecognizer) {
        let shortcutId: String = self.myShortcuts![(((sender.view as! UIImageView).superview?.superview as! MZShortcutsTableViewCell).indexPath?.row)!].shortcutModel!.identifier
        MZAnalyticsInteractor.shortcutRemoveStartEvent(shortcutId)
        let alert: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_shortcut_delete_text", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: { (action) in
            MZAnalyticsInteractor.shortcutRemoveCancelEvent(shortcutId)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_delete", comment: ""), style: .destructive, handler: { (action) -> Void in
            self.shortcutsInteractor.deleteShortcut(self.myShortcuts![(((sender.view as! UIImageView).superview?.superview as! MZShortcutsTableViewCell).indexPath?.row)!].shortcutModel!.identifier) { (result, error) -> Void in
                if error == nil {
                    MZAnalyticsInteractor.shortcutRemoveFinishEvent(shortcutId, errorMessage: nil)
                } else {
                    MZAnalyticsInteractor.shortcutRemoveFinishEvent(shortcutId, errorMessage: error?.localizedDescription)
                }
                self.reloadShortcuts()
            }
            self.myShortcuts?.remove(at: (((sender.view as! UIImageView).superview?.superview as! MZShortcutsTableViewCell).indexPath?.row)!)
            self.tableView.reloadData()
        }))
        self.wireframe.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - MZChangeWorkerDelegate
    
    func didChangeWorker() {
        self.reloadShortcuts()
    }
    
    
    // MARK: - Private stuff
    
    fileprivate func reloadShortcuts()
    {
        self.shortcutsInteractor.getShortcuts { (result, error) -> Void in
            if error == nil {
                self.myShortcuts = result as? [MZShortcutViewModel]
                self.delegate?.updatedShortcuts(self.myShortcuts!)
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            } else {
                // TODO: show error or something (check with UI)
            }
        }
    }
    
}
