//
//  MZContextManager.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 19/12/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

typealias ActivitySegment = (activity: CMMotionActivity, endDate: Date)


class MZContextManager : NSObject
{
    static let shared = MZContextManager()
    
    var locationsToSend = [NSMutableDictionary]()
    var contextChannelID : String = ""
    
    func sendProperty(channelId : String, componentId: String, propertyId: String, data: NSMutableDictionary, completion: @escaping (_ error: NSError?) -> Void)
    {
        let params = NSMutableDictionary()
        params[MZCoreWebService.key_channel] = channelId
        params[MZCoreWebService.key_component] = componentId
        params[MZCoreWebService.key_property] = propertyId
        params["params"] = data
        
        MZCoreDataManager.sharedInstance.publish(params as! [String : AnyObject]) { (result, error) in
            if(error != nil)
            {
                Log.error("MZContextManager: HTTP publish failed. Error: \(error?.code) : \(error?.localizedDescription)")
                completion(error)
            }
            else
            {
                completion(nil)
            }
        }
    }
    
    func sendLocation(contextChannelId : String, locationJSON: NSMutableDictionary, completion: @escaping (_ error: NSError?) -> Void)
    {
        self.contextChannelID = contextChannelId
        Log.context("Sending Location property (new): \(MZJsonHelper.stringify(locationJSON))")
        sendProperty(channelId: contextChannelId, componentId: "location", propertyId: "location", data: locationJSON) { (error) in
            
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
            
            completion(error)
            
        }
    }
    
    func sendLatlon(contextChannelId : String, locationJSON: NSMutableDictionary, completion: @escaping (_ error: NSError?) -> Void)
    {
        Log.context("Sending LatLon property: \(MZJsonHelper.stringify(locationJSON))")
        self.contextChannelID = contextChannelId
        sendProperty(channelId: contextChannelId, componentId: "location", propertyId: "latlon", data: locationJSON) { (error) in
            
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
            
            
            completion(error)
        }
    }
    
    func sendLocationVisit(contextChannelId : String, visit: CLVisit, completion: @escaping (_ error: NSError?) -> Void)
    {
        self.contextChannelID = contextChannelId
        var visitJson = NSMutableDictionary()
        visitJson["latitude"] = visit.coordinate.latitude
        visitJson["longitude"] = visit.coordinate.longitude
        visitJson["horizontal_accuracy"] = visit.horizontalAccuracy
        visitJson["arrival_date"] = MZDateHelper.dateInHabitUTC(date: visit.arrivalDate)
        visitJson["departure_date"] = MZDateHelper.dateInHabitUTC(date: visit.departureDate)
        visitJson["timestamp"] = MZDateHelper.dateInHabitUTC(date: Date())
        visitJson["unknown_start"] = true

        
        let vendorId = MZDeviceInfoHelper.getVendorId()
        if vendorId != nil
        {
            visitJson["device_id"] = vendorId
        }
        
        sendProperty(channelId: self.contextChannelID, componentId: "location", propertyId: "visit", data: visitJson) { (error) in
            if error == nil
            {
                //                    self.stopUpdatingLocation(manager: self.locationManager!)
                MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_total_location_visits_sent)
                
                if UIApplication.shared.applicationState == .active
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_location_visits_sent_foreground)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_location_visits_sent_background)
                }
            }
            else
            {
                MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_total_location_visits_failed)
                
                if UIApplication.shared.applicationState == .active
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_location_visits_failed_foreground)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_location_visits_failed_background)
                }
            }
            
            completion(error)
        }
    }
    
    func sendActivity(activityInfo: CMMotionActivity, unknownStart: Bool = true, completion: @escaping (_ error: NSError?) -> Void)
    {
        var activityJson = NSMutableDictionary()
        
        let confidence = self.getConfidenceNormalized(confidence: activityInfo.confidence)
        
        activityJson["automotive"] = [ "status" : activityInfo.automotive, "confidence" : confidence]
        activityJson["cycling"] = [ "status" : activityInfo.cycling, "confidence" : confidence]
        activityJson["walking"] =  [ "status" : activityInfo.walking, "confidence" : confidence]
        activityJson["stationary"] = [ "status" : activityInfo.stationary, "confidence" : confidence]
        activityJson["running"] = [ "status" : activityInfo.running, "confidence" : confidence]
        activityJson["unknown"] = [ "status" : activityInfo.unknown, "confidence" : confidence]
        activityJson["timestamp"] = MZDateHelper.dateInHabitUTC(date: activityInfo.startDate)
        activityJson["unknown_start"] = unknownStart
        
        let vendorId = MZDeviceInfoHelper.getVendorId()
        if vendorId != nil
        {
            activityJson["device_id"] = vendorId
        }
        sendProperty(channelId: self.contextChannelID, componentId: "movement", propertyId: "activity", data: activityJson) { (error) in
            
            if error == nil
            {
                //                    self.stopUpdatingLocation(manager: self.locationManager!)
                MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_events_sent)
                
                if UIApplication.shared.applicationState == .active
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_events_sent_foreground)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_events_sent_background)
                }
            }
            else
            {
                MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_events_failed)
                
                if UIApplication.shared.applicationState == .active
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_events_failed_foreground)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_events_failed_background)
                }
            }
            
            
            completion(error)
        }
    }
    
    func sendActivityHistory(segments: [ActivitySegment], completion: @escaping (_ error: NSError?) -> Void)
    {
        var historyArray = NSMutableArray()
        var payload = NSMutableDictionary()
        for seg in segments
        {
            var activityJson = NSMutableDictionary()
            activityJson["automotive"] = seg.activity.automotive
            activityJson["cycling"] = seg.activity.cycling
            activityJson["walking"] = seg.activity.walking
            activityJson["stationary"] = seg.activity.stationary
            activityJson["running"] = seg.activity.running
            activityJson["unknown"] = seg.activity.unknown
            activityJson["confidence"] = self.getConfidenceNormalized(confidence: seg.activity.confidence)
            activityJson["start_date"] = MZDateHelper.dateInHabitUTC(date: seg.activity.startDate)
            activityJson["end_date"] = MZDateHelper.dateInHabitUTC(date: seg.endDate)
            
            historyArray.add(activityJson)
        }
        
        payload["history"] = historyArray
        
        let vendorId = MZDeviceInfoHelper.getVendorId()
        if vendorId != nil
        {
            payload["device_id"] = vendorId
        }
        
        sendProperty(channelId: self.contextChannelID, componentId: "movement", propertyId: "activity_history", data: payload) { (error) in
            
            if error == nil
            {
                //                    self.stopUpdatingLocation(manager: self.locationManager!)
                MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_history_sent)
                
                if UIApplication.shared.applicationState == .active
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_history_sent_foreground)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_history_sent_background)
                }
            }
            else
            {
                MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_history_failed)
                
                if UIApplication.shared.applicationState == .active
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_history_failed_foreground)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_activity_history_failed_background)
                }
            }
            
            completion(error)
        }
    }
    
    func sendWifiInfo(unknownStart: Bool = false, completion: @escaping (_ error: NSError?) -> Void)
    {
        if self.contextChannelID != nil && !self.contextChannelID.isEmpty
        {
            var ssid = MZDeviceInfoHelper.getWifiSSID()
            var bssid = MZDeviceInfoHelper.getWifiBSSID()
            if ssid == nil { ssid = "" }
            if bssid == nil { bssid = "" }
            
            var wifiJSON = NSMutableDictionary()
            
            wifiJSON["ssid"] = ssid
            wifiJSON["bssid"] = bssid
            wifiJSON["timestamp"] = Date.nowDateInHabitUTC
            wifiJSON["unknown_start"] = unknownStart
            
            let vendorId = MZDeviceInfoHelper.getVendorId()
            
            if vendorId != nil
            {
                wifiJSON["device_id"] = vendorId
            }
            
            sendProperty(channelId: self.contextChannelID, componentId: "network", propertyId: "current_wifi", data: wifiJSON) { (error) in
                if error == nil
                {
                    //                    self.stopUpdatingLocation(manager: self.locationManager!)
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_wifi_sent)
                }
                else
                {
                    MZAppStatsHelper.shared.updateCounter(MZAppStatsHelper.key_wifi_failed)
                }
                completion(error)
            }
        }
    }
    
    
    func getConfidenceNormalized(confidence: CMMotionActivityConfidence) -> Double
    {
        switch confidence {
        case .low:
            return 0.0
        case .medium:
            return 0.5
        case .high:
            return 1.0
        default:
            return 0.0
        }
    }
}
