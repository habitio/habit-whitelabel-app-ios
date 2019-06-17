//
//  MZCardLocationPicker.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 20/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
import GoogleMaps

@objc protocol MZCardLocationPickerDelegate: NSObjectProtocol {
    func mapTapped(_ coordinates: CoordinatesTemp?, field: MZFieldViewModel)
}

class MZCardLocationPicker: UIViewController, GMSMapViewDelegate
{
    var value : NSObject?
    var card: MZCardViewModel?
    var field: MZFieldViewModel?
    
    var coordinates: CoordinatesTemp?
    var delegate: MZCardLocationPickerDelegate?

    var mapView : GMSMapView?
    @IBOutlet weak var placeHolderMapView : UIView?
    @IBOutlet weak var pinView : UIImageView?
    
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setViewModel(_ cardViewModel: MZCardViewModel, fieldViewModel: MZFieldViewModel)
    {
        self.card = cardViewModel
        self.field = fieldViewModel
    }
    
    func setupUI()
    {
        if (self.mapView != nil) {
            self.mapView?.removeFromSuperview()
        }
        
        let theValue = self.field?.getValue()
        if let placeholder : [MZLocationPlaceholderViewModel] = theValue as? [MZLocationPlaceholderViewModel] {
            self.value = placeholder[0]
        } else {
            self.value = self.field!.placeholders.first as? MZLocationPlaceholderViewModel
        }
        self.field?.setValue(self.value!)

        
        self.coordinates = CoordinatesTemp()
        self.coordinates!.latitude = (self.value! as! MZLocationPlaceholderViewModel).latitude
        self.coordinates!.longitude = (self.value! as! MZLocationPlaceholderViewModel).longitude
    
        
        let camera = GMSCameraPosition.camera(withLatitude: self.coordinates!.latitude, longitude: self.coordinates!.longitude, zoom: MUZZLEY_MAP_ZOOM)
        self.mapView = GMSMapView.map(withFrame: self.placeHolderMapView!.bounds, camera: camera)
        self.mapView!.settings.setAllGesturesEnabled(false)
        self.mapView!.isMyLocationEnabled = false
        self.mapView!.delegate = self
        self.mapView!.translatesAutoresizingMaskIntoConstraints = false
        self.placeHolderMapView!.insertSubview(self.mapView!, belowSubview: self.pinView!)

        NSLayoutConstraint(item: self.mapView!, attribute: .centerY, relatedBy: .equal, toItem: self.placeHolderMapView, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true

        NSLayoutConstraint(item: self.mapView!, attribute: .height, relatedBy: .equal, toItem: self.placeHolderMapView, attribute: .height, multiplier: 1.0, constant:0.0).isActive = true

        let views = ["myView" : self.mapView!]
        let formatString = "|[myView]|"
        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: formatString, options: .alignAllTop, metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
        
        //self.layoutIfNeeded()
    }
    
    // - MZCardLocationPickerDelegate
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        delegate!.mapTapped(self.coordinates!, field: self.field!)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.coordinates!.cameraAltitude = self.mapView!.camera.zoom
    }

}
