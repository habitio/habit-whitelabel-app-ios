//
//  MZSettingsAddLocationViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 12/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift

class MZSettingsAddLocationViewController : BaseViewController,  GMSMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate
{
	var coordinates: CoordinatesTemp = CoordinatesTemp()
	var previousCoordinates: CoordinatesTemp?
	var interactor : MZSettingsPlacesInteractor?
	var geocoder : GMSGeocoder?
	var searchResults =  Dictionary<String, String>()

	var placeClient : GMSPlacesClient?
	
	let loadingView = MZLoadingView()
	
	var firstLocationUpdate = true
	var addressTextUpdate = true
	
	fileprivate var nameFieldBorder: CALayer!
	let locationManager = CLLocationManager()
	
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var pinView: UIImageView?
	
	@IBOutlet weak var tfName: UITextField?
	@IBOutlet weak var lbWifiName: UILabel?
	@IBOutlet weak var tfAddress: UITextField?
	
	@IBOutlet weak var tvSearchResults: UITableView!
	
	@IBOutlet weak var btSetWifi: UIButton?
	
	@IBOutlet weak var btCurrentUserLocation: UIButton!
	
	@IBOutlet weak var btDone: UIButton?
	
	fileprivate var wireframe: UserProfileWireframe!
	
	convenience init(withWireframe wireframe: UserProfileWireframe)
	{
		self.init(nibName: "MZSettingsAddLocationViewController", bundle: Bundle.main)
		GMSPlacesClient.provideAPIKey(MZThemeManager.sharedInstance.appInfo.googleMapsAPIKey)
		self.placeClient = GMSPlacesClient.shared()

		self.wireframe = wireframe
		self.interactor = MZSettingsPlacesInteractor()
	}
	
	func setup(_ placeVM : MZPlaceViewModel)
	{
		self.interactor = MZSettingsPlacesInteractor(place: placeVM)
		self.coordinates = CoordinatesTemp()
		self.coordinates.latitude = (self.interactor?.latitude)!
		self.coordinates.longitude = (self.interactor?.longitude)!
	}
	
	@IBOutlet weak var btRemoveWifi: UIButton!
	
	@IBAction func btRemoveWifi_Pressed(_ sender: AnyObject) {
		
		if(!(self.lbWifiName?.text?.isEmpty)!)
		{
			self.interactor?.wifiInfo.ssid = ""
			self.interactor?.wifiInfo.bssid = ""
			self.interactor?.wifi = ""
			self.lbWifiName?.text = NSLocalizedString("mobile_settings_location_get_wifi", comment: "")
			self.btSetWifi?.isHidden = false
			self.btRemoveWifi?.isHidden = true
		}
	}
	
	@IBAction func btSetWifiPressed(_ sender: AnyObject) {
		
		let ssid = MZDeviceInfoHelper.getWifiSSID()
		let bssid = MZDeviceInfoHelper.getWifiBSSID()
		if(ssid != nil && bssid != nil && !(ssid?.isEmpty)! && !(bssid?.isEmpty)!)
		{
			self.interactor?.wifiInfo.ssid = ssid!
			self.interactor?.wifiInfo.bssid = bssid!
			self.interactor?.wifi = ssid!
			self.lbWifiName?.text = ssid!
			self.btSetWifi?.isHidden = true
			self.btRemoveWifi?.isHidden = false
		}
		else
		{
			self.lbWifiName?.text = NSLocalizedString("mobile_settings_location_get_wifi_not_found", comment: "")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
		view.addGestureRecognizer(tapGestureRecognizer)

		self.tfName?.delegate = self
		self.tfAddress?.delegate = self
		let _ = self.tfAddress?.rx.text.debounce(0.5, scheduler: MainScheduler.instance)
			.subscribe(onNext: { (str) in
				if (self.addressTextUpdate)
				{
					self.updateResults(str!)
				}
				else
				{
					self.addressTextUpdate = true
				}
			}, onError: { (error) in
			}, onCompleted: {
			}, onDisposed: {
			})
//			.subscribeNext
//			{ (str) -> Void in
//				if (self.addressTextUpdate)
//				{
//					self.updateResults(str)
//				}
//				else
//				{
//					self.addressTextUpdate = true
//				}
//			}
//		
		 self.locationManager.requestWhenInUseAuthorization()
		

		self.setupInterface()
		

	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.searchResults.count
	}
	
	func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
	{
		
		let cell = UITableViewCell()
		cell.textLabel?.text = Array(searchResults.keys)[indexPath.row]
		let gesture = UITapGestureRecognizer(target: self, action: #selector(self.setAddressSuggestion(_:)))
		cell.addGestureRecognizer(gesture)

		return cell
	}
	
	fileprivate func setupInterface()
	{
		if(self.interactor == nil)
		{
			self.interactor = MZSettingsPlacesInteractor()
		}
		
		self.nameFieldBorder = CALayer()
		self.nameFieldBorder.borderColor = UIColor.muzzleyGray3Color(withAlpha: 1.0).cgColor
		self.nameFieldBorder.frame = CGRect(x: 0.0, y: self.tfName!.frame.size.height - 1.0 / UIScreen.main.scale, width: UIScreen.main.bounds.size.width - 32.0, height: 1.0 / UIScreen.main.scale)
		self.nameFieldBorder.borderWidth = 1.0 / UIScreen.main.scale
		self.nameFieldBorder.masksToBounds = false
		self.tfName!.layer.masksToBounds = false
		self.tfName!.layer.addSublayer(self.nameFieldBorder)
		

		self.tfName!.layer.masksToBounds = true

		self.coordinates = CoordinatesTemp()
		self.coordinates.latitude = (self.interactor?.latitude)!
		self.coordinates.longitude = (self.interactor?.longitude)!
		
		self.btSetWifi!.backgroundColor = UIColor.muzzleyBlueColor(withAlpha: 1)
		self.btSetWifi!.layer.cornerRadius = self.btSetWifi!.bounds.height / 2
		
		self.title = NSLocalizedString("mobile_location_add", comment: "")
		self.btDone!.setTitle(NSLocalizedString("mobile_done", comment: ""), for: UIControlState())
		self.lbWifiName?.text = NSLocalizedString("mobile_settings_location_get_wifi", comment: "")
		self.tfName?.placeholder = NSLocalizedString("mobile_settings_location_name_placeholder", comment: "")
		self.tfAddress?.placeholder = NSLocalizedString("mobile_settings_location_address_placeholder", comment: "")
		self.btCurrentUserLocation!.layer.masksToBounds = true
		
		self.btCurrentUserLocation!.isHidden = false
		
		self.btCurrentUserLocation!.layer.cornerRadius = self.btCurrentUserLocation!.bounds.height / 2
		self.btCurrentUserLocation!.layer.masksToBounds = true
		
		self.btDone!.layer.cornerRadius = self.btDone!.bounds.height / 2
		self.btDone!.layer.masksToBounds = true
		
		self.locationManager.delegate = self
		self.locationManager.startUpdatingLocation()
		

		let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: MUZZLEY_MAP_ZOOM)
		self.mapView.camera = camera
		self.mapView.delegate = self
		
		self.tvSearchResults.isHidden = true
//		mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
		
		DispatchQueue.main.async(execute: { () -> Void in
			self.mapView.isMyLocationEnabled = true
		})
	
		self.geocoder = GMSGeocoder()
		
	}

	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		let location = locations.last
		
		let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
		mapView.animate(to: camera)
		
		//Finally stop updating location otherwise it will come again and again in this delegate
		self.locationManager.stopUpdatingLocation()
		
	}
	
	// Commented out after swift 3 conversion. Check what broke.
	
//	override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?)
//	{
//		
//		if(firstLocationUpdate && self.interactor!.address.isEmpty)
//		{
//			firstLocationUpdate = false
//			
//		//	let location = (options as! NSDictionary)[NSKeyValueChangeKey.newKey] as! CLLocation
//			mapView.camera = GMSCameraPosition.camera(withTarget: self.mapView!.myLocation!.coordinate, zoom: 14)
//		}
//
//	}
//	override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer)
//	{
//		if(firstLocationUpdate && self.interactor!.address.isEmpty)
//		{
//			firstLocationUpdate = false
//		
//			let location = (change as! NSDictionary)[NSKeyValueChangeKey.newKey] as! CLLocation
//			mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14)
//		}
//	}

	// Update mapview with the current user's location
	@IBAction func toggleShowUserLocation ()
	{

		if(self.mapView!.myLocation != nil)
		{
			self.mapView!.animate(toLocation: self.mapView!.myLocation!.coordinate)
			getCurrentLocationAddress()
		}
	}
	
	
	func updateResults(_ searchText : String)
	{
		searchResults.removeAll()
		
		if(searchText.isEmpty)
		{
			self.tvSearchResults.isHidden = true
			self.tvSearchResults.reloadData()
			return
		}
		placeClient?.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error) in
			if results == nil
			{
				return
			}
			
			if(results?.count == 0)
			{
				self.tvSearchResults.isHidden = true
				self.tvSearchResults.reloadData()
				return
			}
			
			for result in results!
			{
				self.searchResults[result.attributedFullText.string] = result.placeID
			}
			self.tvSearchResults.isHidden = false
			self.tvSearchResults.reloadData()
			
		}
	}
	
	func setAddressSuggestion(_ sender:UITapGestureRecognizer)
	{
		let placeId = searchResults[((sender.view as! UITableViewCell).textLabel?.text)!]
	
		self.placeClient?.lookUpPlaceID(placeId!, callback: { (gmsplace, error) in
			if(error == nil)
			{
				self.addressTextUpdate = false
				self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: (gmsplace?.coordinate.latitude)!, longitude: (gmsplace?.coordinate.longitude)!))
			
				self.tvSearchResults.isHidden = true
				self.searchResults.removeAll()
				self.view.endEditing(true)
			}
			else
			{
				// Show error?
			}
		})
	}
	
	func getCurrentLocationAddress()
	{
		self.geocoder!.reverseGeocodeCoordinate(self.mapView!.camera.target) { response, error in
			if error != nil
			{
//				dLog(message: "Reverse geocoder failed with error" + error!.localizedDescription)
				self.tfAddress?.text = NSLocalizedString("mobile_location_unknown_address", comment: "")
				return
			}
			
			if (response != nil && response!.results()!.count > 0)
			{
				let result = response!.firstResult()
				
				if (result!.lines != nil && result!.lines!.count > 0)
				{
					var address = ""
					if(!result!.lines!.first!.isEmpty)
					{
						self.tfAddress?.text = result!.lines!.first!
					}
					else
					{
						for line in result!.lines!
						{
							if(!line.isEmpty)
							{
								address = address + " " + line
							}
						}
						if(!address.trim().isEmpty)
						{
							self.tfAddress?.text = address.trim()
						}
						else
						{
							self.tfAddress?.text = NSLocalizedString("mobile_location_unknown_address", comment: "")
						}
					}
				}
				else
				{
					self.tfAddress?.text = NSLocalizedString("mobile_location_unknown_address", comment: "")
				}
			}
			else
			{
					self.tfAddress?.text = NSLocalizedString("mobile_location_unknown_address", comment: "")
			}
		}
	}

	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		if (self.previousCoordinates != nil) {
			self.btCurrentUserLocation!.alpha = 1.0
		}
		
		UIView.animate(withDuration: 0.2, animations: { [weak self] in
			self!.pinView!.center = CGPoint(x: self!.pinView!.center.x, y: self!.pinView!.center.y - 10)
			})
		
		let coord = CoordinatesTemp()
		coord.latitude = position.target.latitude
		coord.longitude = position.target.longitude
		self.previousCoordinates = coord
		
		UIView.animate(withDuration: 0.2, animations: { [weak self] in
			self!.pinView!.center = CGPoint(x: self!.pinView!.center.x, y: self!.pinView!.center.y + 10)
			})
		
		dismissKeyboard()
		getCurrentLocationAddress()
	}
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	
	@IBAction func setLocationBtnTapped () {
		
        if(self.tfName!.text!.isEmpty)
        {
            self.tfName!.becomeFirstResponder()
            return
        }
        
		self.loadingView.updateLoadingStatus(true, container: self.view)
		
		interactor?.latitude = Double(self.mapView!.camera.target.latitude)
		interactor?.longitude = Double(self.mapView!.camera.target.longitude)
		interactor?.name = self.tfName!.text!
		interactor?.address = self.tfAddress!.text!
		
		if(interactor!.placeIsValid())
		{
			interactor!.addLocation()
			{
				(success : Bool) in
				if(success)
				{
					self.loadingView.updateLoadingStatus(false, container: self.view)
					self.navigationController?.popViewController(animated: true)
				}
				else
				{
					self.loadingView.updateLoadingStatus(false, container: self.view)
					let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
						error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
						
					self.navigationController!.present(error, animated: true, completion: nil)
				}
			}
		}
		else
		{
			self.loadingView.updateLoadingStatus(false, container: self.view)
			// Show message to fill the required fields
		}
	}
	
}
