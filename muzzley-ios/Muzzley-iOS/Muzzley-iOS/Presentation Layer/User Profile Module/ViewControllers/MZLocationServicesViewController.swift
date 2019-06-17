//
//  MZLocationServicesViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 12/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

class MZLocationServicesViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let myLocationsCount = 2
    let locationsCount = 3
    
    private enum Items: Int {
        case GPSLocation = 0,
        Count
    }
    
    private var wireframe: UserProfileWireframe!
    private var interactor: MZUserProfileInteractor!

    private var gpsLocationSelected: Bool = true
    
    convenience init(withWireframe wireframe: UserProfileWireframe, andInteractor interactor: MZUserProfileInteractor) {
        self.init(nibName: "MZLocationServicesViewController", bundle: NSBundle.mainBundle())
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
    }
    
    private func setupInterface() {
        self.title = NSLocalizedString("mobile_title_location", comment: "")
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(UINib(nibName: "MZSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "MZSwitchTableViewCell")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - UITableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Items.Count.rawValue + myLocationsCount + locationsCount + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if indexPath.row == Items.GPSLocation.rawValue {
            let aCell: MZSwitchTableViewCell = tableView.dequeueReusableCellWithIdentifier("MZSwitchTableViewCell", forIndexPath: indexPath) as! MZSwitchTableViewCell
            aCell.title.text = NSLocalizedString("mobile_title_gps", comment: "")
			
			// TODO: UNCOMMENT THIS IF THIS CLASS IS EVER USED
			
            //aCell.labelSwitch.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
            cell = aCell
        } else if indexPath.row > 0 && indexPath.row <= myLocationsCount {
            let aCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//            aCell.imageView.image = UIImage(named: "")
            aCell.textLabel?.text = "My Location"
            aCell.textLabel?.font = UIFont.lightFontOfSize(15)
            
            cell = aCell
        } else if indexPath.row > myLocationsCount && indexPath.row <= (locationsCount + myLocationsCount) {
            let aCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            aCell.textLabel?.text = "Custom Location"
            aCell.textLabel?.font = UIFont.lightFontOfSize(15)
            
            cell = aCell
        } else if indexPath.row > myLocationsCount + myLocationsCount && indexPath.row <= (locationsCount + myLocationsCount + 1) {
            let aCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            aCell.textLabel?.text = "+ Add New Location"
            aCell.textLabel?.textColor = UIColor.muzzleyBlueColorWithAlpha(1.0)
            aCell.textLabel?.font = UIFont.regularFontOfSize(15)
            
            cell = aCell
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let coordinates = CoordinatesTemp()
        coordinates.latitude = 41.893056
        coordinates.longitude = 12.4827783
        
        if indexPath.row == Items.GPSLocation.rawValue {
            
        } else if indexPath.row > 0 && indexPath.row <= myLocationsCount {
            let editLocationVC: MZEditLocationViewController = MZEditLocationViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
            editLocationVC.locationToEdit = coordinates
            self.wireframe.parentWireframe?.pushViewControllerToEnd(editLocationVC, animated: true)
        } else if indexPath.row > myLocationsCount && indexPath.row <= (locationsCount + myLocationsCount) {
            let editLocationVC: MZEditLocationViewController = MZEditLocationViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
            editLocationVC.locationToEdit = coordinates
            self.wireframe.parentWireframe?.pushViewControllerToEnd(editLocationVC, animated: true)
        } else if indexPath.row > myLocationsCount + myLocationsCount && indexPath.row <= (locationsCount + myLocationsCount + 1) {
            let addLocationVC: MZAddLocationViewController = MZAddLocationViewController(withWireframe: self.wireframe, andInteractor: self.interactor)
            self.wireframe.parentWireframe?.pushViewControllerToEnd(addLocationVC, animated: true)
        }
    }
    
    @IBAction func switchValueDidChange(sender: AnyObject) {
        self.gpsLocationSelected = (sender as! UISwitch).on
    }
    
}
