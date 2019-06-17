//
//  MZTimeFormatViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 07/06/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//


enum HourFormat : Int
{
	case Twelve = 12
	case TwentyFour = 24
}

class MZHourFormatViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate
{
	
	@IBOutlet weak var tableView: UITableView!
	
	private enum tableRows: Int {
		case Twelve = 0,
		TwentyFour,
		Count
	}

	private var wireframe: UserProfileWireframe!
	private var selectedFormat = HourFormat.Twelve
	let loadingView = MZLoadingView()
	
	convenience init(withWireframe wireframe:UserProfileWireframe)
	{
		self.init(nibName: "MZHourFormatViewController", bundle: NSBundle.mainBundle())
		self.wireframe = wireframe
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupInterface()
	}
	
	private func setupInterface()
	{
		let hourFormat = MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat
		
		switch hourFormat
		{
			case HourFormat.Twelve.rawValue:
				selectedFormat = HourFormat.Twelve
			
			case HourFormat.TwentyFour.rawValue:
				selectedFormat = HourFormat.TwentyFour
			default:
				selectedFormat = HourFormat.Twelve
		}
		
		self.title = NSLocalizedString("mobile_title_hour_format", comment: "")
		self.tableView.tableFooterView = UIView()
		self.tableView.registerNib(UINib(nibName: "MZRadioTableViewCell", bundle: nil), forCellReuseIdentifier: "MZRadioTableViewCell")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableRows.Count.rawValue
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section
		{
			case 0:
				return NSLocalizedString("mobile_title_hour_format", comment: "")
			
			default:
				return ""
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
			
			switch indexPath.row
			{
				case tableRows.Twelve.rawValue:
					aCell.radioItem.text = NSLocalizedString("mobile_title_12h_format", comment: "")
					aCell.radioItem.subtitle = NSLocalizedString("mobile_title_12h_example", comment: "")
					aCell.radioItem.isSelected = self.selectedFormat == HourFormat.Twelve
				case tableRows.TwentyFour.rawValue:
					aCell.radioItem.text = NSLocalizedString("mobile_title_24h_format", comment: "")
					aCell.radioItem.subtitle = NSLocalizedString("mobile_title_24h_example", comment: "")
					aCell.radioItem.isSelected = self.selectedFormat == HourFormat.TwentyFour
				
				default:
					break
			}
			
			cell = aCell
			
		default: break
		}
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		switch indexPath.row {
		case tableRows.Twelve.rawValue:
			if selectedFormat != HourFormat.Twelve
			{
				self.loadingView.updateLoadingStatus(true, container: self.view)
				
				MZSessionDataManager.sharedInstance.updateTimeFormat(HourFormat.Twelve.rawValue, completion: { (success, error) -> Void in
					if(error == nil)
					{
						if(success as Bool)
						{
							self.selectedFormat = HourFormat.Twelve
							tableView.reloadData()
							MZNotifications.send(MZNotificationKeys.UserProfile.HourFormatUpdated, obj: nil)
						}
					}
					else
					{
						// Show error
					}
					
					self.loadingView.updateLoadingStatus(false, container: self.view)
				})
				self.selectedFormat = HourFormat.Twelve
				tableView.reloadData()
			}
			
		case tableRows.TwentyFour.rawValue:
			if selectedFormat != HourFormat.TwentyFour
			{
				self.loadingView.updateLoadingStatus(true, container: self.view)
				
				MZSessionDataManager.sharedInstance.updateTimeFormat(HourFormat.TwentyFour.rawValue, completion: { (success, error) -> Void in
					if(error == nil)
					{
						if(success as Bool)
						{
							self.selectedFormat = HourFormat.TwentyFour
							tableView.reloadData()
							MZNotifications.send(MZNotificationKeys.UserProfile.HourFormatUpdated, obj: nil)
							
						}
					}
					else
					{
						
						// Show error
					}
					
					self.loadingView.updateLoadingStatus(false, container: self.view)
				})
				
				self.selectedFormat = HourFormat.TwentyFour
				tableView.reloadData()
			}
			
		default: break
		}
		
		tableView.reloadData()
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
