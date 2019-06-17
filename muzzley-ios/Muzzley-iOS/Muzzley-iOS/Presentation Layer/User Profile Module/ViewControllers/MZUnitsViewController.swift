//
//  MZUnitsViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 27/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZUnitsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	
	private enum tableRows: Int {
		case Metric = 0,
		Imperial,
		Count
	}
	
	
	private var wireframe: UserProfileWireframe!
	private var selectedUnit: UnitsSystem = UnitsSystem.Unknown
	
	
	convenience init(withWireframe wireframe: UserProfileWireframe) {
		self.init(nibName: "MZUnitsViewController", bundle: NSBundle.mainBundle())
		self.wireframe = wireframe
			}
	
	let loadingView = MZLoadingView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupInterface()
		
	}
	
	private func setupInterface()
	{
		let userUnits = MZSessionDataManager.sharedInstance.session.userProfile.preferences.units
		
		switch(userUnits)
		{
		case "metric":
			selectedUnit = UnitsSystem.Metric
			break
		case "imperial":
			selectedUnit = UnitsSystem.Imperial
			break
			
		default:
			selectedUnit = UnitsSystem.Unknown
			break
		}
		
		self.title = NSLocalizedString("mobile_title_units", comment: "")
		self.tableView.tableFooterView = UIView()
		self.tableView.registerNib(UINib(nibName: "MZRadioTableViewCell", bundle: nil), forCellReuseIdentifier: "MZRadioTableViewCell")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - UITableView DataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableRows.Count.rawValue
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return NSLocalizedString("mobile_title_unit_system", comment: "")
			
		default: return ""
		}
	}
	
	func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = UIColor.clearColor()
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		var cell: UITableViewCell? = nil
		
		switch indexPath.section {
		case 0:
			let aCell: MZRadioTableViewCell = tableView.dequeueReusableCellWithIdentifier("MZRadioTableViewCell", forIndexPath: indexPath) as! MZRadioTableViewCell
			
			switch indexPath.row {
			case tableRows.Metric.rawValue:
				aCell.radioItem.text = NSLocalizedString("mobile_title_metric", comment: "")
				aCell.radioItem.subtitle = NSLocalizedString("mobile_title_metric_example", comment: "")
				aCell.radioItem.isSelected = self.selectedUnit == UnitsSystem.Metric
			case tableRows.Imperial.rawValue:
				aCell.radioItem.text = NSLocalizedString("mobile_title_imperial", comment: "")
				aCell.radioItem.subtitle = NSLocalizedString("mobile_title_imperial_example", comment: "")
				aCell.radioItem.isSelected = self.selectedUnit == UnitsSystem.Imperial
				
			default: break
			}
			
			cell = aCell
			
		default: break
		}
		
		return cell!
	}
	
	
	// MARK: - UITableView Delegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		switch indexPath.row {
		case tableRows.Metric.rawValue:
			if selectedUnit != UnitsSystem.Metric
			{
				self.loadingView.updateLoadingStatus(true, container: self.view)
				
				MZSessionDataManager.sharedInstance.updateUnitsSystem(UnitsSystem.Metric, completion: { (success, error) -> Void in
					if(error == nil)
					{
						if(success as Bool)
						{
							self.selectedUnit = UnitsSystem.Metric
							tableView.reloadData()
							MZNotifications.send(MZNotificationKeys.UserProfile.UnitsSystemUpdated, obj: nil)
						}
					}
					else
					{
						// Show error
					}
					
					self.loadingView.updateLoadingStatus(false, container: self.view)
				})
			}
			
		case tableRows.Imperial.rawValue:
			if selectedUnit != UnitsSystem.Imperial
			{
				self.loadingView.updateLoadingStatus(true, container: self.view)
				
				MZSessionDataManager.sharedInstance.updateUnitsSystem(UnitsSystem.Imperial, completion: { (success, error) -> Void in
					if(error == nil)
					{
						if(success as Bool)
						{
							self.selectedUnit = UnitsSystem.Imperial
							tableView.reloadData()
							MZNotifications.send(MZNotificationKeys.UserProfile.UnitsSystemUpdated, obj: nil)
							
						}
					}
					else
					{
						
						// Show error
					}
			
					self.loadingView.updateLoadingStatus(false, container: self.view)
				})
			}
			
		default: break
		}
		
		tableView.reloadData()
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	
//	func updateLoadingStatus(isLoading : Bool)
//	{
//		loadingView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//		if(isLoading)
//		{
//			self.view.addSubview(loadingView)
//			self.loadingView.showLoadingView()
//		}
//		else
//		{
//			self.loadingView.hideLoadingView()
//			self.loadingView.removeFromSuperview()
//
//		}
//	}


}
