//
//  MZCardLocationPickerViewController.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
import GoogleMaps

@objc protocol MZCardLocationPickerViewControllerDelegate: NSObjectProtocol {
    func didMapChooseSetLocation(_ result: MZLocationPlaceholderViewModel, objectToUpdate:AnyObject, indexPath:IndexPath?)
}

@objc class MZCardLocationPickerViewController : UIViewController, GMSMapViewDelegate {
    
    var indexPath: IndexPath?
    var coordinates: CoordinatesTemp?
    var previousCoordinates: CoordinatesTemp?
    var titleView: UIView?
    var fieldViewModel : MZFieldViewModel?
    var value : MZLocationPlaceholderViewModel?
    var geocoder : GMSGeocoder?
    var delegate : MZCardLocationPickerViewControllerDelegate?

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var mapView : GMSMapView?
    @IBOutlet weak var pinView: UIImageView?
    @IBOutlet weak var setUserLocationBtn: UIButton?
    @IBOutlet weak var setNewLocationBtn: UIButton?

    func setup(_ viewModel : MZFieldViewModel)
    {
        self.fieldViewModel = viewModel
        
        let theValue = self.fieldViewModel?.getValue()
        if let placeholder : [MZLocationPlaceholderViewModel] = theValue as? [MZLocationPlaceholderViewModel] {
            self.value = placeholder[0]
        } else {
            self.value = viewModel.placeholders.first as? MZLocationPlaceholderViewModel
        }
        
        self.coordinates!.latitude = (self.value?.latitude)!
        self.coordinates!.longitude = (self.value?.longitude)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("mobile_cards_location", comment: "")

        self.setUserLocationBtn!.layer.cornerRadius = self.setUserLocationBtn!.bounds.height / 2
        self.setUserLocationBtn!.layer.masksToBounds = true
        
        self.setNewLocationBtn!.layer.cornerRadius = self.setNewLocationBtn!.bounds.height / 2
        self.setNewLocationBtn!.layer.masksToBounds = true
        
        let camera = GMSCameraPosition.camera(withLatitude: self.coordinates!.latitude, longitude: self.coordinates!.longitude, zoom: MUZZLEY_MAP_ZOOM)
        self.mapView!.camera = camera
        self.mapView!.delegate = self
        self.mapView!.isMyLocationEnabled = true

        self.geocoder = GMSGeocoder()
        
        updateTitle()
    }
    
    @IBAction func toggleShowUserLocation () {
        self.mapView!.animate(toLocation: self.mapView!.myLocation!.coordinate)
    }
    
    func updateTitle() {
        self.geocoder!.reverseGeocodeCoordinate(self.mapView!.camera.target) { response, error in
            if error != nil {
                return
            }
            
            if (response != nil && response!.results()!.count > 0) {
                let result = response!.firstResult()
                
                if (result!.lines != nil && result!.lines!.count > 0) {
                    self.titleLabel!.text = result!.lines!.first!
                    if (result!.lines!.count > 1) {
                        self.subtitleLabel!.text = result!.lines!.last!
                    } else {
                        self.subtitleLabel!.text = ""
                    }
                } else {
                    self.titleLabel!.text = NSLocalizedString("mobile_location_not_valid", comment: "")
                    self.subtitleLabel!.text = ""
                    
                    let coords = CLLocationCoordinate2D(latitude: self.previousCoordinates!.latitude, longitude: self.previousCoordinates!.longitude)
                    self.mapView?.animate(toLocation: coords)
                }
            } else {
                self.titleLabel!.text = NSLocalizedString("mobile_location_not_valid", comment: "")
                self.subtitleLabel!.text = ""
                
                let coords = CLLocationCoordinate2D(latitude: self.previousCoordinates!.latitude, longitude: self.previousCoordinates!.longitude)
                self.mapView?.animate(toLocation: coords)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if (self.previousCoordinates != nil) {
            self.setNewLocationBtn!.alpha = 1.0
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
        
        updateTitle()
    }
    
    @IBAction func setLocationBtnTapped () {
        self.value!.latitude = Double(self.mapView!.camera.target.latitude)
        self.value!.longitude = Double(self.mapView!.camera.target.longitude)
        
        self.delegate!.didMapChooseSetLocation(self.value!, objectToUpdate: self.fieldViewModel!, indexPath:self.indexPath)
        
        self.navigationController?.popViewController(animated: true)
    }
}
