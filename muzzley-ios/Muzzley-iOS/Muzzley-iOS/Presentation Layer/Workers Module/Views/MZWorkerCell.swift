//
//  MZWorkerCell.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 12/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

@objc protocol MZWorkerCellDelegate
{
    func didTapTrash(_ aWorker: MZWorkerViewModel)
    func didTapExecute(_ aWorker: MZWorkerViewModel)
    func didTapCancel(_ aWorker: MZWorkerViewModel)
    func didTapPermission(_ aWorker: MZWorkerViewModel)
    func didChangeToggleState(_ aWorker: MZWorkerViewModel, state: MZTriStateToggleState)
    func shouldReloadAtIndex(_ aWorker: MZWorkerViewModel)
}

class MZWorkerCell : UITableViewCell, MZTriStateToggleDelegate, MZWorkerAlertViewDelegate
{
    
    @IBOutlet weak var bgView: UIView?
    @IBOutlet weak var trashButton: UIButton?
    @IBOutlet weak var lastRunLabel: UILabel?
    @IBOutlet weak var workerLabel: UILabel?
    @IBOutlet weak var workerToggle: MZTriStateToggle?
    @IBOutlet weak var disabledOverlay: UIView?
    @IBOutlet weak var imgContraint: UIImageView!
    
    @IBOutlet weak var workerProgressView: MZWorkerProgressView?
    @IBOutlet weak var workerAlertView: MZWorkerAlertView?
    @IBOutlet weak var workerDoneView: MZWorkerDoneView?

    var delegate: MZWorkerCellDelegate?
    
    var workerVM: MZWorkerViewModel?
    
    
    @IBAction func trashWorker(_ sender: AnyObject) {
        delegate!.didTapTrash(self.workerVM!)
    }
    
    @IBAction func executeWorker(_ sender: AnyObject) {
        delegate!.didTapExecute(self.workerVM!)
    }
    
    func didTapLeftButton ()
    {
        if self.workerVM!.alertViewModel.currentAlert == WorkerAlert.noExecuted {
            delegate!.didTapCancel(self.workerVM!)
        }
    }
    
    func didTapRightButton ()
    {
        if (self.workerVM!.alertViewModel.currentAlert == WorkerAlert.noExecuted) {
            delegate!.didTapExecute(self.workerVM!)
        }
    }
    
    func didTapCenterButton()
    {
        if self.workerVM!.alertViewModel.currentAlert == WorkerAlert.invalid
        {
            delegate!.didTapTrash(self.workerVM!)
        }  else if self.workerVM!.alertViewModel.currentAlert == WorkerAlert.locationPermission
        {
            delegate!.didTapPermission(self.workerVM!)
		}
		else if self.workerVM!.alertViewModel.currentAlert == WorkerAlert.notificationsPermission
		{
			delegate!.didTapPermission(self.workerVM!)
        } else if self.workerVM!.alertViewModel.currentAlert == WorkerAlert.hardwareCapabilities
        {
            self.changeAlertVisibility()
        }
    }
    
    func toggle(_ toggle: MZTriStateToggle!, didChangetoState state: MZTriStateToggleState)
    {
        if (state == MZTriStateToggleState.on) {
            self.disabledOverlay!.isHidden = true
        } else if (state == MZTriStateToggleState.off) {
            self.disabledOverlay!.isHidden = false
        }
        self.delegate?.didChangeToggleState(self.workerVM!, state: state)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.bgView?.layer.cornerRadius = CORNER_RADIUS
		self.bgView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.bgView?.layer.shadowOpacity = 0.2
        self.bgView?.layer.shadowColor = UIColor.black.cgColor
        self.bgView?.layer.shadowRadius = 1
        self.bgView?.layer.shadowPath = UIBezierPath(roundedRect: self.bgView!.bounds, cornerRadius: self.bgView!.layer.cornerRadius).cgPath
        
        self.workerLabel?.font = UIFont.mediumFontOfSize(17)
        self.workerLabel?.textColor = UIColor.muzzleyBlackColor(withAlpha: 1)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        if self.workerProgressView != nil
        {
            self.workerProgressView!.isHidden = true
        }
        
        if workerDoneView != nil
        {
            self.workerDoneView!.isHidden = true
        }
        
        if workerAlertView != nil
        {
            self.workerAlertView!.isHidden = true
        }
        
        self.imgContraint.isHidden = true
    }
    
    func setViewModel (_ viewModel: MZWorkerViewModel)
    {
        self.workerVM = viewModel
		
        self.workerProgressView = (Bundle.main.loadNibNamed("MZWorkerProgressView", owner: self, options: nil)![0] as? MZWorkerProgressView)!
        self.workerDoneView = (Bundle.main.loadNibNamed("MZWorkerDoneView", owner: self, options: nil)![0] as? MZWorkerDoneView)!
        self.workerAlertView = (Bundle.main.loadNibNamed("MZWorkerAlertView", owner: self, options: nil)![0] as? MZWorkerAlertView)!
        self.workerAlertView?.delegate = self
        
        self.workerAlertView?.setViewModel(workerVM!.alertViewModel)
        
        self.setupView(self.workerAlertView!)
        self.setupView(self.workerProgressView!)
        self.setupView(self.workerDoneView!)
        
        self.workerProgressView!.isHidden = !(workerVM!.currentState == WorkerState.testing)
        self.workerDoneView!.isHidden = !(workerVM!.currentState == WorkerState.success)
        self.workerAlertView!.isHidden = !(workerVM!.currentState == WorkerState.alert)
        
        self.imgContraint.isHidden = workerVM!.hasCapabilities
        
        if workerVM?.currentState == WorkerState.success
        {
            self.workerDoneView!.titleLabel.text = workerVM?.doneViewModel.content
        } else if workerVM?.currentState == WorkerState.testing {
            self.workerProgressView!.activityIndicator.startAnimating()
        } else {
            self.workerProgressView!.activityIndicator.stopAnimating()
        }
        
        var visibleCellsCount = 0
        if UIScreen.main.bounds.size.width == 320.0 && viewModel.actionDeviceVMs.count > 3 {
            visibleCellsCount = 3
        } else if (viewModel.actionDeviceVMs.count > 4) {
            visibleCellsCount = 4
        } else {
            visibleCellsCount = viewModel.actionDeviceVMs.count
        }
        
        
        if viewModel.allowDisable
        {
            self.workerToggle?.isHidden = false
            self.workerToggle?.thumbImage = UIImage(named: "IconToggleOnOff")
            var state: MZTriStateToggleState = .on
            if !viewModel.enabled
            {
                state = .off
            }
            self.workerToggle?.setState(state, animated: false)
            self.workerToggle?.delegate = self
        } else {
            self.workerToggle?.isHidden = true
        }

        
        self.disabledOverlay!.isHidden = viewModel.enabled
        var state: MZTriStateToggleState = .on
        if !viewModel.enabled
        {
            state = .off
        }
        self.workerToggle?.setState(state, animated: false)
        self.workerToggle?.delegate = self
        self.workerLabel?.text = viewModel.label
        self.lastRunLabel?.font = UIFont.lightItalicFontOfSize(10)
        self.lastRunLabel?.text = viewModel.lastRun
		
		if(viewModel.deletable)
		{
			self.trashButton!.isHidden = false
		}
		else
		{
			self.trashButton!.isHidden = true
		}
    }
    
    func setupView (_ view: UIView)
    {
        view.isHidden = true
        
        view.frame = self.bgView!.bounds
        self.bgView!.addSubview(view)
        
        let constraintWidth = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.bgView, attribute: .width, multiplier: 1, constant: 0)
        constraintWidth.priority = 1000;
        
        let constraintHeight = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: self.bgView, attribute: .height, multiplier: 1, constant: 0)
        constraintHeight.priority = 1000;
        
        self.bgView!.addConstraint(constraintWidth)
        self.bgView!.addConstraint(constraintHeight)
    }
    
    func changeAlertVisibility()
    {
        self.workerAlertView!.isHidden = !self.workerAlertView!.isHidden
    }
}
