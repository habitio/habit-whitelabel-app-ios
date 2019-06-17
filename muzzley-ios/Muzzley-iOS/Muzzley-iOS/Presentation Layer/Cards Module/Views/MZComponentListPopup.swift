//
//  MZComponentListPopup.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 18/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

@objc protocol MZComponentListPopupCellDelegate: NSObjectProtocol {
//    func didTapDismiss(viewModel: MZDeviceChoicePlaceholderViewModel)
    func didTapComponentDone(_ viewModel: MZDeviceChoicePlaceholderViewModel)
}

class MZComponentListPopup : UIView, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: MZComponentListPopupCellDelegate?

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var deviceNameLabel: UILabel?
    @IBOutlet weak var doneBtn: UIButton?

    var viewModel: MZDeviceChoicePlaceholderViewModel?

    override func layoutSubviews() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        
        self.layer.masksToBounds = true
        self.tableView!.layer.masksToBounds = true
        self.tableView!.layer.cornerRadius = 6
        self.clipsToBounds = false
        self.layer.cornerRadius = 6
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.muzzleyGrayColor(withAlpha: 1.0).cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 6).cgPath
        
        self.tableView!.register(UINib(nibName: "MZComponentListPopupCell", bundle: nil), forCellReuseIdentifier: "elementCell")
        self.tableView!.register(UINib(nibName: "MZComponentListPopupHeaderCell", bundle: nil), forCellReuseIdentifier: "headerCell")

        self.imgView!.layer.cornerRadius = (self.imgView?.frame.size.width)! / 2.0
        self.imgView!.layer.masksToBounds = true
        self.imgView!.layer.borderColor = UIColor.muzzleyGrayColor(withAlpha: 1).cgColor
        self.imgView!.layer.borderWidth = 1.0 / UIScreen.main.scale
        
        self.deviceNameLabel?.text = self.viewModel!.deviceTitle
		self.imgView!.setImageWith(self.viewModel!.model!.photoUrlAlt! as URL)
    }
    
    @IBAction func doneButtonTapped () {
        delegate?.didTapComponentDone(self.viewModel!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.viewModel!.availableComponents.count
        }
    }
	

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 38
		} else {
			return 50
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let headerCell: UITableViewCell = self.tableView!.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
			
			return headerCell
		} else {
			let cell: MZComponentListPopupCell = self.tableView!.dequeueReusableCell(withIdentifier: "elementCell", for: indexPath) as! MZComponentListPopupCell
			
			cell.selectionStyle = .none
			cell.setViewModel(self.viewModel!.availableComponents[indexPath.row])
			let result = self.viewModel!.selectedComponents.filter { $0.model!.identifier == self.viewModel!.availableComponents[indexPath.row].model!.identifier}
			cell.checkmark!.isHidden = result.isEmpty
			
			return cell
		}
	}

	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 { return }
		
		let element = self.viewModel!.availableComponents[indexPath.row]
		
		if (self.viewModel!.selectedComponents.contains(element)) {
			let indexOfElement = self.viewModel!.selectedComponents.index(of: element)
			self.viewModel!.selectedComponents.remove(at: indexOfElement!)
		} else {
			self.viewModel!.selectedComponents.append(element)
		}
		
		tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
	}
	
    
}
