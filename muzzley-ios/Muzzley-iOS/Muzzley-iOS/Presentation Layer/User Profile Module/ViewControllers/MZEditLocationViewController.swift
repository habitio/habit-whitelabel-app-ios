//
//  MZEditLocationViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 13/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import GoogleMaps

class MZEditLocationViewController : BaseViewController, GMSMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var deleteLocationBtn: UIButton?
    @IBOutlet weak var setUserLocationBtn: UIButton?
    @IBOutlet weak var pinView: UIView?
    @IBOutlet weak var mapView: GMSMapView?
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var tvHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationNameTxtField: UITextField!
    @IBOutlet weak var searchTxtField: UITextField!

    var locationToEdit: CoordinatesTemp!

    private var wireframe: UserProfileWireframe!
    private var interactor: MZUserProfileInteractor!

    private var placesClient: GMSPlacesClient!
    private var googlePlacesFound: NSArray!

    convenience init(withWireframe wireframe: UserProfileWireframe, andInteractor interactor: MZUserProfileInteractor) {
        self.init(nibName: "MZEditLocationViewController", bundle: NSBundle.mainBundle())
        
        self.wireframe = wireframe
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.googlePlacesFound = NSArray()
        
        let camera = GMSCameraPosition.cameraWithLatitude(self.locationToEdit.latitude, longitude: self.locationToEdit.longitude, zoom: MUZZLEY_MAP_ZOOM)
        self.mapView!.camera = camera
        self.mapView!.myLocationEnabled = true
        self.mapView!.delegate = self
        self.view.sendSubviewToBack(self.mapView!)
        
        self.placesClient = GMSPlacesClient()
        
        self.setupInterface()
    }
    
    func setupInterface () {
        self.title = NSLocalizedString("mobile_title_edit_location", comment: "")
        
        self.placesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let bbiImage = UIImage(named: "IconDone")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        let button = UIButton(type: UIButtonType.Custom)
        button.tintColor = UIColor.muzzleyWhiteColorWithAlpha(1.0)
        button.bounds = CGRectMake(0, 0, 20, 20)
        button.setImage(bbiImage, forState: UIControlState.Normal)
        button.addTarget(self, action: "didTapSaveLocationEdits", forControlEvents: UIControlEvents.TouchUpInside)
        
        let bbi = UIBarButtonItem(customView: button)
        bbi.enabled = false
        self.navigationItem.rightBarButtonItem = bbi
        
        self.headerView!.layer.shadowColor = UIColor.muzzleyGray4ColorWithAlpha(0.5).CGColor
        self.headerView!.layer.shadowOffset = CGSizeMake(0, 3.0)
        self.headerView!.layer.shadowOpacity = 0.7
        self.headerView!.layer.shadowRadius = 3.0
        
        self.placesTableView!.layer.shadowColor = UIColor.muzzleyGray4ColorWithAlpha(0.5).CGColor
        self.placesTableView!.layer.shadowOffset = CGSizeMake(0, 3.0)
        self.placesTableView!.layer.shadowOpacity = 0.7
        self.placesTableView!.layer.shadowRadius = 3.0
        
        self.updateInterface()
        
//        self.interactor.configureSearchFilter(self.searchTxtField) { (searchString) -> Void in
//            self.searchPlaces(searchString!)
//        }
    }
    
    func searchPlaces (searchString: String) {
        if (searchString.characters.count == 0) {
            self.googlePlacesFound = NSArray()
            self.updateInterface()
        }
        
        let visibleRegion = self.mapView?.projection.visibleRegion()
        let filter = GMSAutocompleteFilter()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion!.farLeft, coordinate: visibleRegion!.nearRight)
        filter.type = GMSPlacesAutocompleteTypeFilter.Address
        placesClient?.autocompleteQuery(searchString, bounds: bounds, filter: filter, callback: { (results, error: NSError?) -> Void in
            if error != nil {
                return
            }
            
            self.googlePlacesFound = results
            
            self.placesTableView.reloadData()
            
            self.updateInterface()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.googlePlacesFound.count, 10)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let googlePlace = self.googlePlacesFound[indexPath.row] as! GMSAutocompletePrediction
        cell.textLabel?.text = googlePlace.attributedFullText.string
        cell.textLabel?.textColor = UIColor.muzzleyGrayColorWithAlpha(1.0)
        cell.textLabel?.font = UIFont.lightFontOfSize(17)
        cell.imageView?.opaque = false
        cell.imageView?.image = UIImage(named: "Location_Pin")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.imageView?.tintColor = UIColor.muzzleyGray4ColorWithAlpha(1.0)
        cell.imageView?.transform = CGAffineTransformMakeScale(0.2, 0.2);

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let googlePlace = self.googlePlacesFound[indexPath.row] as! GMSAutocompletePrediction
        
        placesClient!.lookUpPlaceID(googlePlace.placeID!, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.mapView?.animateToLocation(place.coordinate)
                self.searchTxtField.text = googlePlace.attributedFullText.string
                self.placesTableView.hidden = true
            } else {
                print("No place details for \(googlePlace.placeID)")
            }
        })
    }
    
    func updateInterface () {
        if (self.searchTxtField.text?.characters.count > 0 && self.locationNameTxtField.text?.characters.count > 0) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        if (self.googlePlacesFound != nil && self.googlePlacesFound.count > 0 && self.searchTxtField.editing == true) {
            self.placesTableView.hidden = false

            self.tvHeightConstraint.constant = CGFloat(self.googlePlacesFound.count) * 40.0
            
            self.headerView!.layer.shadowOpacity = 0.0
            self.placesTableView!.layer.shadowOpacity = 0.7
        } else {
            self.placesTableView.hidden = true

            self.headerView!.layer.shadowOpacity = 0.7
            self.placesTableView!.layer.shadowOpacity = 0.0
        }
        
        self.setUserLocationBtn!.layer.cornerRadius = self.setUserLocationBtn!.bounds.height / 2
        self.setUserLocationBtn!.layer.masksToBounds = true
        
        self.deleteLocationBtn!.layer.cornerRadius = self.deleteLocationBtn!.bounds.height / 2
        self.deleteLocationBtn!.layer.masksToBounds = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.placesTableView.hidden = true
    }

    @IBAction func locationNameDidChange () {
        self.updateInterface()
    }
    
    func didTapSaveLocationEdits () {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func toggleShowUserLocation () {
        self.mapView!.animateToLocation(self.mapView!.myLocation!.coordinate)
    }
    
    @IBAction func deleteLocation () {
        
    }
}
