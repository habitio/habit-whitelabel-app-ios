//
//  MZEmitLocationInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 17/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import CocoaLumberjack
import CoreLocation

@objc protocol MZEmitLocationInteractorDelegate : NSObjectProtocol
{
    func locationPermissionsWereProvided(status: CLAuthorizationStatus)
}

class MZEmitLocationInteractor: NSObject, CLLocationManagerDelegate
{
	class var sharedInstance : MZEmitLocationInteractor {
		struct Singleton {
			static let instance = MZEmitLocationInteractor()
		}
		return Singleton.instance
	}
	
	var locationManager : CLLocationManager?
    var latestLocation : CLLocation?
    
//    var mutableData : NSMutableDictionary?
	var geofencesList : NSArray?
	var contextChannelId : String = ""
    var delegate : MZEmitLocationInteractorDelegate?
    
    let DESIRED_ACCURACY = kCLLocationAccuracyNearestTenMeters
    
	override init()
	{
		super.init()
	}
	
	func startMonitoringLocation()
	{
        if(self.locationManager == nil)
        {
            let userId = MZSession.sharedInstance.authInfo?.userId
            
            if(userId != nil && !userId!.isEmpty)
            {
                MZSession.sharedInstance.loadFromCache(completion: { (cachedSessionFound) in
                    Log.context("EmitLocationInteractor: user loaded");
                    
                    self.contextChannelId = MZLocalStorageHelper.loadLocationChannelIdFromNSUserDefaults()
                })
                
                if(self.locationManager == nil)
                {
                    self.locationManager = CLLocationManager()
                    self.locationManager?.delegate = self
                    Log.context("EmitLocationInteractor Initialized", saveInDebugLog: true)
                }
            }
        }
		if(self.locationManager != nil)
		{
			let authorizationStatus = CLLocationManager.authorizationStatus()
            if(authorizationStatus == .notDetermined)
            {
                self.locationManager?.requestAlwaysAuthorization()
                Log.context("EmitLocationInteractor: Request Location Permission")
                print(CLLocationManager.authorizationStatus())
                
                // Wait for permission change to always to initialize
            }
            
            if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
            {
                self.setLocationManagerPropertiesAndStartMonitoring()
                Log.context("EmitLocationInteractor: start monitoring")
            }
            
            if(self.delegate != nil && authorizationStatus != .notDetermined)
            {
                self.delegate?.locationPermissionsWereProvided(status: authorizationStatus)
            }
        }
    }
	
	func stopMonitoringLocation()
	{
		if(self.locationManager != nil)
		{
			self.locationManager?.stopMonitoringSignificantLocationChanges()
            self.locationManager?.stopMonitoringVisits()
			Log.context("EmitLocationInteractor: stop monitoring")
		}
	}
	
	func stopUpdatingLocation(manager: CLLocationManager)
	{
		manager.stopUpdatingLocation()
		if(self.locationManager != nil)
		{
			if #available(iOS 9.0, *) {
				self.locationManager?.allowsBackgroundLocationUpdates = true
                self.locationManager?.pausesLocationUpdatesAutomatically = false
			} else {
				// Fallback on earlier versions
			}
		}
	}
    

	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
	{
    
        let lastLocation = locations.last as! CLLocation

		let howRecent = lastLocation.timestamp.timeIntervalSinceNow
		if(fabs(howRecent) < 60*60*24) // is less than a day old
		{
			if((lastLocation.horizontalAccuracy as! Double) > 0 && (lastLocation.horizontalAccuracy as! Double) < 200)
			{
                
                self.latestLocation = lastLocation
                let locationJSON = createLocationJSONObject(location: lastLocation)
                self.sendLocationLatLon(location: self.latestLocation!)
                self.sendLocation(location: self.latestLocation!)
			}
            else
            {
                Log.error("Location is not ACCURRATE")
            }
		}
        else
        {
            Log.error("Location is more than a day old")
//            MZNotificationBanner.showDebugBanner(title: "", subtitle: "Location IS NOT recent enough!")
        }
	}
	
    
    func createLocationJSONObject(location: CLLocation) -> NSMutableDictionary?
    {
        
        let mutable = NSMutableDictionary()
        if location.horizontalAccuracy < 0
        {
            return nil // The values for latitude and longitude are considered invalid if horizontal accuracy is negative (According to Apple documentation)
        }
        
        mutable["horizontal_accuracy"] = location.horizontalAccuracy
        mutable["latitude"] = Double((location.coordinate.latitude))
        mutable["longitude"] = Double((location.coordinate.longitude))
        mutable["timestamp"] = MZDateHelper.dateInHabitUTC(date: location.timestamp)
        mutable["unknown_start"] = false

        if location.verticalAccuracy >= 0 // The value for altitude is considered invalid if value is negative (According to Apple documentation)
        {
            mutable["vertical_accuracy"] = location.verticalAccuracy
            mutable["altitude"] = location.altitude
        }
        
        if location.course >= 0 // The value is considered invalid if it is negative (According to Apple documentation)
        {
            mutable["bearing"] = location.course
        }
        
        if location.speed >= 0 // The value is considered invalid if it is negative (According to Apple documentation)
        {
            mutable["speed"] = location.speed
        }
        
        if location.floor != nil
        {
            mutable["floor"] = location.floor?.level
        }

        let vendorId = MZDeviceInfoHelper.getVendorId()
        
        if vendorId != nil
        {
            mutable["device_id"] = vendorId
        }
        
        return mutable
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
    {
        MZContextManager.shared.sendLocationVisit(contextChannelId: self.contextChannelId, visit: visit) { (error) in
            
            
        }
    }
    
    
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
	{
        Log.context("EmitLocationInteractor didFailWithError" + (error as? NSError)!.description, saveInDebugLog: true)
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
	{
        Log.context("Location Authorization Permission changed")

		let authorizationStatus = CLLocationManager.authorizationStatus()
		
		switch authorizationStatus {
		case .notDetermined:
			Log.context("Permission: User hasn’t yet been asked to authorize location updates (notDetermined)")
			break
			
		case .restricted:
			Log.context("Permission: User has location services turned off in Settings (Parental Restrictions)(restricted)")
			break
			
		case .denied:
			Log.context("Permission: User has been asked for authorization and tapped “No” (or turned off location in Settings) (denied)")
			break
		
		case .authorizedAlways:
			Log.context("Permission: User authorized background use. (authorizedAlways)")
            self.setLocationManagerPropertiesAndStartMonitoring()
        
			break
		
		case .authorizedWhenInUse:
			Log.context("Permission: User authorized when in use.(authorizedWhenInUse")
            self.setLocationManagerPropertiesAndStartMonitoring()
			break
			
		
		default:
			break
		}
        
        if(self.delegate != nil && authorizationStatus != .notDetermined)
        {
            self.delegate?.locationPermissionsWereProvided(status: authorizationStatus)
        }

		NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshAllTabs"), object: nil)
	}
    
    func setLocationManagerPropertiesAndStartMonitoring()
    {
        if self.locationManager != nil
        {
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager?.allowsBackgroundLocationUpdates = true
            self.locationManager?.pausesLocationUpdatesAutomatically = false
            self.locationManager?.startMonitoringSignificantLocationChanges()
            self.locationManager?.pausesLocationUpdatesAutomatically = false
            self.locationManager?.startMonitoringVisits()
            self.locationManager?.requestLocation()
        }
    }
    
	func requestLocation()
    {
        startMonitoringLocation()
    }
	func setGeofences(_ geofences: NSArray?)
	{
        self.geofencesList = geofences;
		
		if(self.locationManager != nil)
		{
			for region in self.locationManager!.monitoredRegions
			{
				self.locationManager?.stopMonitoring(for: region)
			}
			
//            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
//            {
//                return
//            }
			
			if CLLocationManager .authorizationStatus() != .authorizedAlways
			{
				return
			}
			
			if(self.geofencesList != nil)
			{
                Log.context("EmitLocationInteractor: Updating geofences", saveInDebugLog: true)
				for r in self.geofencesList!
				{
					let region = CLCircularRegion(center: CLLocationCoordinate2DMake((r as! NSDictionary).value(forKey: "latitude") as! Double, (r as! NSDictionary).value(forKey: "longitude") as! Double), radius: (r as! NSDictionary).value(forKey: "radius") as! Double, identifier: (r as! NSDictionary).value(forKey: "id") as! String)
					self.locationManager?.startMonitoring(for: region)
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
	{
		manager.requestState(for: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		if(state == CLRegionState.inside)
		{
            Log.context("EmitLocationInteractor: Geofence with position inside a valid region", saveInDebugLog: true)
//            self.handleRegionEvent(region: region, typeEnter: true, manager: manager)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if(region.isKind(of: CLCircularRegion.self))
		{
            Log.context("EmitLocationInteractor: Did enter on a geofence", saveInDebugLog: true)
			self.handleRegionEvent(region: region, typeEnter: true, manager: manager)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if(region.isKind(of: CLCircularRegion.self))
		{
            Log.context("EmitLocationInteractor: Did exit from a geofence", saveInDebugLog: true)
			self.handleRegionEvent(region: region, typeEnter: false, manager: manager)
		}
	}
	
	func handleRegionEvent(region: CLRegion, typeEnter: Bool, manager: CLLocationManager)
	{
        MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_geofences_triggered)

		self.locationManager = manager
		if(locationManager != nil)
		{
            self.locationManager?.allowsBackgroundLocationUpdates = true
            self.locationManager?.pausesLocationUpdatesAutomatically = false
            
			self.locationManager?.startUpdatingLocation()
			Log.context("EmitLocationInteractor startUpdatingLocation")
			
			self.perform(#selector(stopUpdatingLocation(manager:)), with: self.locationManager, afterDelay: 60*5)
			
		}
	}
	
    func sendLocation(location: CLLocation)
    {
        if(MZSession.sharedInstance.authInfo != nil)
        {
            let userId = MZSession.sharedInstance.authInfo!.userId
            if(userId == nil || userId.isEmpty)
            {
                Log.context("EmitLocationInteractor: No user!", saveInDebugLog: true)
                return
            }
            
            let locationJSON = self.createLocationJSONObject(location: location)
            if locationJSON == nil
            {
                Log.context("EmitLocationInteractor: Invalid location")
                return
            }
            
            MZContextManager.shared.sendLocation(contextChannelId: self.contextChannelId, locationJSON: locationJSON!) { (error) in
                
            }
        }
    }

    func sendLocationLatLon(location : CLLocation)
	{
        if(MZSession.sharedInstance.authInfo != nil)
        {
            let userId = MZSession.sharedInstance.authInfo!.userId
            if(userId == nil || userId.isEmpty)
            {
                Log.context("EmitLocationInteractor: No user!")
                return
            }
            
            let locationJSON = self.createLocationJSONObject(location: location)
            if locationJSON == nil
            {
                Log.context("EmitLocationInteractor: Invalid location")
                return
            }
            
            MZContextManager.shared.sendLatlon(contextChannelId: self.contextChannelId, locationJSON: locationJSON!) { (error) in
                if error == nil
                {
                    //                    self.stopUpdatingLocation(manager: self.locationManager!)
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_total_locations_sent)
                    
                    if UIApplication.shared.applicationState == .active
                    {
                        MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_locations_sent_foreground)
                    }
                    else
                    {
                        MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_locations_sent_background)
                    }
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_total_locations_failed)
                    
                    if UIApplication.shared.applicationState == .active
                    {
                        MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_locations_failed_foreground)
                    }
                    else
                    {
                        MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_locations_failed_background)
                    }
                }
            }
        }
	}
    

}
