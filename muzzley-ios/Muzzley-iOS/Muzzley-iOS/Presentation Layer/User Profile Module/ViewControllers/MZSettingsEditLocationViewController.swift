//
//  MZSettingsEditLocationViewController.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 12/07/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RxSwift
import GooglePlaces

class MZSettingsEditLocationViewController : BaseViewController,  GMSMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate
{
	
	var coordinates: CoordinatesTemp = CoordinatesTemp()
	var previousCoordinates: CoordinatesTemp?
	var interactor : MZSettingsPlacesInteractor?
	var geocoder : GMSGeocoder?
	var searchResults =  Dictionary<String, String>()
	var placeClient : GMSPlacesClient?
	
	var firstLocationUpdate = true
	
	var addressTextUpdate = true
	let locationManager = CLLocationManager()


	let loadingView = MZLoadingView()
	
	@IBOutlet weak var tvSearchResults: UITableView!
	
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var pinView: UIImageView?
	
	@IBOutlet weak var nameView: UIView!
	@IBOutlet weak var tfName: UITextField?
	@IBOutlet weak var iconEdit: UIImageView!
	
	@IBOutlet weak var lbWifiName: UILabel?
	@IBOutlet weak var tfAddress: UITextField?
	
	@IBOutlet weak var btSetWifi: UIButton?
	
	@IBOutlet weak var btCurrentUserLocation: UIButton!
	
	@IBOutlet weak var btDone: UIButton?
	
	fileprivate var wireframe: UserProfileWireframe!
	
	@IBOutlet weak var btRemoveWifi: UIButton!
	
	convenience init(withWireframe wireframe: UserProfileWireframe, placeVM : MZPlaceViewModel)
	{
		self.init(nibName: "MZSettingsEditLocationViewController", bundle: Bundle.main)
		self.wireframe = wireframe
		self.interactor = MZSettingsPlacesInteractor(place: placeVM)
		GMSPlacesClient.provideAPIKey(MZThemeManager.sharedInstance.appInfo.googleMapsAPIKey)
		self.placeClient = GMSPlacesClient.shared()
	}
	
	func setup(_ placeVM : MZPlaceViewModel)
	{
		self.interactor = MZSettingsPlacesInteractor(place: placeVM)
		self.coordinates = CoordinatesTemp()
		self.coordinates.latitude = (self.interactor?.latitude)!
		self.coordinates.longitude = (self.interactor?.longitude)!
		
	}
	
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
		
		let barButton: UIBarButtonItem = UIBarButtonItem()
		barButton.title = ""
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
		let button = UIButton(type: .custom)
		button.tintColor = UIColor.muzzleyWhiteColor(withAlpha: 1)
		button.bounds = CGRect(x: 0, y: 0, width: 14, height: 18)
		button.setImage(UIImage(named: "icon_delete_agent")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
		button.addTarget(self, action: #selector(self.deletePlaceAction(_:)), for: .touchUpInside)
        
        if #available(iOS 11, *) {
            button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        }

        
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
		self.navigationItem.rightBarButtonItem?.isEnabled = true
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
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
//				
//				if (self.addressTextUpdate)
//				{
//					self.updateResults(str)
//				}
//				else
//				{
//					self.addressTextUpdate = true
//				}
//				
//			}
		
		self.coordinates = CoordinatesTemp()
		self.coordinates.latitude = (self.interactor?.latitude)!
		self.coordinates.longitude = (self.interactor?.longitude)!
		
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
		self.coordinates = CoordinatesTemp()
		self.coordinates.latitude = (self.interactor?.latitude)!
		self.coordinates.longitude = (self.interactor?.longitude)!
		
		self.btSetWifi!.backgroundColor = UIColor.muzzleyBlueColor(withAlpha: 1)
		self.btSetWifi!.layer.cornerRadius = self.btSetWifi!.bounds.height / 2
		
		
		self.title = NSLocalizedString("mobile_location_edit", comment: "")
		self.btDone!.setTitle(NSLocalizedString("mobile_done", comment: ""), for: UIControlState())
		
		switch(interactor?.placeVM.id)
		{
			case "home"?, "work"?, "gym"?, "school"?:
				self.tfName!.isEnabled = false
				self.iconEdit.isHidden = true
				break
			
			default:
				self.iconEdit.isHidden = false
		
			break
		}
		
		self.tfName?.text = !interactor!.name.isEmpty ? interactor?.name : ""
		
		
		self.lbWifiName?.text = !interactor!.wifi.isEmpty ? interactor?.wifi : NSLocalizedString("mobile_settings_location_get_wifi", comment: "")
		if(interactor!.wifi.isEmpty)
		{
			self.btSetWifi?.isHidden = false
			self.btRemoveWifi.isHidden = true
		}
		else
		{
			self.btSetWifi?.isHidden = true
			self.btRemoveWifi.isHidden = false
		}
		
		self.tfAddress?.text = !interactor!.address.isEmpty ? interactor?.address : ""
		

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

		
		let camera = GMSCameraPosition.camera(withLatitude: self.coordinates.latitude, longitude: self.coordinates.longitude, zoom: MUZZLEY_MAP_ZOOM)
		self.mapView.camera = camera
		self.mapView.delegate = self
		self.tvSearchResults.isHidden = true
		
		
		DispatchQueue.main.async(execute: { () -> Void in
			self.mapView.isMyLocationEnabled = true
		})
		
		self.geocoder = GMSGeocoder()
		
	}
	
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
	{
		
		if(firstLocationUpdate && self.interactor!.address.isEmpty)
		{
			firstLocationUpdate = false
		
			let location = locations.last
		
			let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
			mapView.animate(to: camera)
		}
		
		//Finally stop updating location otherwise it will come again and again in this delegate
		self.locationManager.stopUpdatingLocation()
		
	}

	
	
	// Update mapview with the current user's location
	@IBAction func toggleShowUserLocation ()
	{
		
		if(self.mapView!.myLocation != nil)
		{
			self.mapView!.animate(toLocation: self.mapView!.myLocation!.coordinate)
			getCurrentLocationAddress()
		}
	}
	
	@IBAction func deletePlaceAction(_ sender: AnyObject) {
		
		self.loadingView.updateLoadingStatus(true, container: self.view)
		
			let alert: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_settings_delete_location_dialog_text", comment: ""), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_cancel", comment: ""), style: .cancel, handler: { (action) in
				
				self.loadingView.updateLoadingStatus(false, container: self.view)
			}))
			alert.addAction(UIAlertAction(title: NSLocalizedString("mobile_delete", comment: ""), style: .destructive, handler: { (action) -> Void in
				self.interactor!.deleteLocation()
					{
						
						(success : Bool) in
						if(success)
						{
							self.navigationController!.popViewController(animated: true)
						}
						else
						{
							let error: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("mobile_error_text", comment: ""), preferredStyle: .alert)
							error.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: nil))
							self.navigationController!.present(error, animated: true, completion: nil)
						}
						
                        self.loadingView.updateLoadingStatus(false, container: self.view)
				}
				
			}))
			self.navigationController!.present(alert, animated: true, completion: nil)
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
			
		
		//.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error: NSError?) -> Void in
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
				if let result = result as? GMSAutocompletePrediction
				{
					self.searchResults[result.attributedFullText.string] = result.placeID
				}
			}
			
			self.tvSearchResults.isHidden = false
			self.tvSearchResults.reloadData()
			
		}
	}
	
	
	
	
	func setAddressSuggestion(_ sender:UITapGestureRecognizer)
	{
		let placeId = searchResults[((sender.view as! UITableViewCell).textLabel?.text)!]
		if(placeId != nil)
		{
			self.placeClient?.lookUpPlaceID(placeId!, callback: { (gmsplace, error) in
				if(error == nil && gmsplace != nil)
				{
					self.addressTextUpdate = false
					self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: (gmsplace?.coordinate.latitude)!, longitude: (gmsplace?.coordinate.longitude)!))
				
					self.tvSearchResults.isHidden = true
					self.searchResults.removeAll()
					self.view.endEditing(true)
					return
				}
				else
				{
					// Show error?
				}
			})
		}
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
		
		getCurrentLocationAddress()
		dismissKeyboard()
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
        
		interactor?.latitude = Double(self.mapView!.camera.target.latitude)
		interactor?.longitude = Double(self.mapView!.camera.target.longitude)
		interactor?.name = self.tfName!.text!
		interactor?.address = self.tfAddress!.text!
		self.loadingView.updateLoadingStatus(true, container: self.view)
		if(interactor!.placeIsValid())
		{
			interactor!.updateLocation()
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
	
//	func updateLoadingStatus(isLoading : Bool)
//	{
//		loadingView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//		
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
