//
//  MZAddDevicePopupViewControllerDelegate.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 19/12/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

@objc protocol MZAddDevicePopupViewControllerDelegate: NSObjectProtocol {
    func didDeviceChooseDone(_ card:MZCardViewModel)
}

class MZAddDevicePopupViewController: UIViewController, MZDeviceSelectionTableViewControllerDelegate, MZComponentListPopupCellDelegate {
    
    var delegate: MZAddDevicePopupViewControllerDelegate?
    var indexPath: NSIndexPath?
    var card: MZCardViewModel?
    var filter : [AnyObject]?

    
    fileprivate var fieldViewModel: MZFieldViewModel?
    
    fileprivate var deviceListViewController: MZDeviceSelectionTableViewController?
    fileprivate var overlayView: UIView?
    fileprivate var componentListPopup: MZComponentListPopup?
    fileprivate var interactor: MZCardsInteractor?
    fileprivate var selectedDevicesAndComponents: [MZDeviceChoicePlaceholderViewModel]?
    
    convenience init(interactor: MZCardsInteractor?, fieldVM: MZFieldViewModel?, filter: [AnyObject]?, card: MZCardViewModel)
    {
        self.init()
        self.card = card
        self.filter = filter
        
        self.fieldViewModel = fieldVM
        let theValue = self.fieldViewModel?.getValue()
        if (theValue != nil) {
            self.selectedDevicesAndComponents = theValue as? [MZDeviceChoicePlaceholderViewModel]
        } else {
            self.selectedDevicesAndComponents = []
        }
        self.interactor = interactor
        
        //TODO Fix deviceListViewController frame
        self.deviceListViewController = MZDeviceSelectionTableViewController()
        self.deviceListViewController!.interactor = interactor!
        self.deviceListViewController!.delegate = self
        self.deviceListViewController!.filter = filter as AnyObject
        self.deviceListViewController!.objectToUpdate = fieldVM
        self.deviceListViewController!.multiSelection = true
        self.deviceListViewController!.selectedDevices = self.interactor!.convertDevicesChoicePlaceholderViewModel(self.selectedDevicesAndComponents!)
        self.deviceListViewController!.emptyTextMessage =  NSLocalizedString("mobile_no_devices_text", comment: "")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("mobile_device_add", comment: "")
        
        addChildViewController(self.deviceListViewController!)
        self.deviceListViewController!.view.frame = self.view.frame
        view.addSubview(self.deviceListViewController!.view)
        self.deviceListViewController!.didMove(toParentViewController: self)
        
        let bbiImage = UIImage(named: "IconDone")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        let button = UIButton(type: UIButtonType.custom)
        button.tintColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
		button.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.setImage(bbiImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(MZAddDevicePopupViewController.didTapDone), for: UIControlEvents.touchUpInside)
        
        let bbi = UIBarButtonItem(customView: button)
        bbi.isEnabled = false
        self.navigationItem.rightBarButtonItem = bbi
    }
    
    func didTapComponentDone(_ viewModel: MZDeviceChoicePlaceholderViewModel)
    {
        if viewModel.selectedComponents.count == 0
        {
            let index = selectedDevicesAndComponents!.index(of: viewModel)
            selectedDevicesAndComponents!.remove(at: index!)
            
            let filteredDevices = self.deviceListViewController!.selectedDevices.filter() { $0.model!.identifier != viewModel.deviceId }
            self.deviceListViewController!.selectedDevices = filteredDevices
            self.deviceListViewController!.reloadView(false)
            
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            for component in viewModel.selectedComponents
            {
                let devicePH : MZDeviceChoicePlaceholderViewModel = MZDeviceChoicePlaceholderViewModel(model:viewModel.model!)
                devicePH.profileId = viewModel.model!.profileId
                devicePH.remoteId = viewModel.model!.remoteId
                devicePH.deviceTitle = viewModel.model!.label
                devicePH.componentId = component.model!.identifier
                devicePH.classes = component.model!.classes
                devicePH.componentTitle = component.model!.label
                selectedDevicesAndComponents!.append(devicePH)
            }
        }
        
        self.componentListPopup?.removeFromSuperview()
        self.overlayView?.removeFromSuperview()
    }
    
    // MARK MZDeviceSelectionTableViewControllerDelegate
    
    func didTapDone()
    {
        var filteredDevicePHs:[MZDeviceChoicePlaceholderViewModel] = []
        
        for device in (self.deviceListViewController?.selectedDevices)!
        {
            filteredDevicePHs.append(contentsOf: selectedDevicesAndComponents!.filter() {($0.model!.identifier == device.model!.identifier)
                && !$0.componentId.isEmpty})
        }
        
        self.navigationController!.popViewController(animated: true)
        
        self.fieldViewModel!.setValue(filteredDevicePHs as AnyObject)
        self.delegate?.didDeviceChooseDone(self.card!)//(filteredDevicePHs, objectToUpdate: self.fieldViewModel!, indexPath:self.indexPath)
    }
    
    
    func didUnselectDevice(_ device: MZDeviceViewModel) {
        for devicePH in selectedDevicesAndComponents! {
            if devicePH.deviceId == device.id {
                let index = selectedDevicesAndComponents!.index(of: devicePH)
                selectedDevicesAndComponents!.remove(at: index!)
            }
        }
        
        if self.selectedDevicesAndComponents!.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func didSelectDevice(_ device: MZDeviceViewModel) {
        
        let devicePH : MZDeviceChoicePlaceholderViewModel = MZDeviceChoicePlaceholderViewModel(model:device.model!)
        devicePH.profileId = device.model!.profileId
        devicePH.remoteId = device.model!.remoteId
        devicePH.deviceTitle = device.model!.label
        devicePH.availableComponents = self.interactor!.getComponentsWithFilter(device, filterClasses: self.filter)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if devicePH.availableComponents.count == 1
        {
            devicePH.selectedComponents = devicePH.availableComponents
            selectedDevicesAndComponents!.append(devicePH)
            didTapComponentDone(devicePH)
            return
        }
        
        selectedDevicesAndComponents!.append(devicePH)
        
        self.overlayView = UIView(frame: self.deviceListViewController!.view.bounds)
        self.overlayView!.backgroundColor = UIColor.muzzleyGrayColor(withAlpha: 0.5)
        self.deviceListViewController!.view.addSubview(self.overlayView!)
        
        self.componentListPopup = Bundle.main.loadNibNamed("MZComponentListPopup", owner: nil, options: nil)![0] as? MZComponentListPopup
        self.componentListPopup!.delegate = self
        self.componentListPopup!.viewModel = devicePH
        self.componentListPopup!.viewModel!.selectedComponents = devicePH.selectedComponents
        self.componentListPopup!.center = (self.deviceListViewController?.tableView!.center)!
        self.deviceListViewController!.view.addSubview(self.componentListPopup!)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func onDevicesSelected(_ devices: [MZDeviceViewModel], objectToUpdate: AnyObject?)
    {
        var filteredDevicePHs:[MZDeviceChoicePlaceholderViewModel] = []
        
        for device in devices
        {
            filteredDevicePHs.append(contentsOf: selectedDevicesAndComponents!.filter() {($0.model!.identifier == device.model!.identifier)
                && !$0.componentId.isEmpty})
        }
        
        self.fieldViewModel!.setValue(filteredDevicePHs as AnyObject)
        self.delegate?.didDeviceChooseDone(self.card!)//filteredDevicePHs, objectToUpdate: self.fieldViewModel!, indexPath:self.indexPath)
    }
}
