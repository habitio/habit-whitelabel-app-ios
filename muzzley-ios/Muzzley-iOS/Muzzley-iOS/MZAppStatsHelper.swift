//
//  MZAppStatsHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 20/02/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//

import Foundation

class MZAppStatsHelper : NSObject
{
    static let shared = MZAppStatsHelper()
    
    static let DATE_FORMAT = "dd-MM-yyyy"
    
    static let key_old_stats = "key_location_stats"
    
    static let key_user_defaults_app_stats = "app_stats"
    
    static let key_wifi_sent = "wifi_sent"
    static let key_wifi_failed = "wifi_failed"
    static let key_activity_events_sent = "activity_events_sent"
    static let key_activity_events_failed = "activity_events_failed"
    static let key_activity_events_sent_foreground = "activity_events_sent_foreground"
    static let key_activity_events_sent_background = "activity_events_sent_background"
    static let key_activity_events_failed_foreground = "activity_events_failed_foreground"
    static let key_activity_events_failed_background = "activity_events_failed_background"
    static let key_activity_history_sent = "activity_history_sent"
    static let key_activity_history_failed = "activity_history_failed"
    static let key_activity_history_sent_foreground = "activity_history_sent_foreground"
    static let key_activity_history_sent_background = "activity_history_sent_background"
    static let key_activity_history_failed_foreground = "activity_history_failed_foreground"
    static let key_activity_history_failed_background = "activity_history_failed_background"
    static let key_geofences_triggered = "geofences_triggered"
    static let key_total_location_visits_sent = "total_location_visits_sent"
    static let key_total_location_visits_failed = "total_location_visits_failed"
    static let key_location_visits_failed_foreground = "location_visits_failed_foreground"
    static let key_location_visits_failed_background = "location_visits_failed_background"
    static let key_location_visits_sent_foreground = "location_visits_sent_foreground"
    static let key_location_visits_sent_background = "location_visits_sent_background"
    static let key_background_fetch_triggered = "background_fetch_triggered"
    static let key_application_launched_with_location_key = "application_launched_with_location_key"
    static let key_total_locations_failed = "total_locations_failed"
    static let key_locations_failed_background = "locations_failed_background"
    static let key_locations_failed_foreground = "locations_failed_foreground"
    static let key_total_locations_sent = "total_locations_sent"
    static let key_locations_sent_background = "locations_sent_background"
    static let key_locations_sent_foreground = "locations_sent_foreground"
    static let key_permissions_location = "permissions_location"
    static let key_permissions_notifications = "permissions_notifications"
    static let key_application_did_receive_memory_warning = "application_did_receive_memory_warning"
    static let key_application_will_enter_foreground = "application_will_enter_foreground"
    static let key_application_will_terminate = "application_will_terminate"
    static let key_application_did_enter_background = "application_did_enter_background"
    static let key_application_did_become_active = "application_did_become_active"
    
    
    let keysArray = [
        key_wifi_sent,
        key_wifi_failed,
        key_activity_events_sent,
        key_activity_events_failed,
        key_activity_events_sent_foreground,
        key_activity_events_sent_background,
        key_activity_events_failed_foreground,
        key_activity_events_failed_background,
        key_activity_history_sent,
        key_activity_history_failed,
        key_activity_history_sent_foreground,
        key_activity_history_sent_background,
        key_activity_history_failed_foreground,
        key_activity_history_failed_background,
        key_geofences_triggered,
        key_total_location_visits_sent,
        key_total_location_visits_failed,
        key_location_visits_failed_foreground,
        key_location_visits_failed_background,
        key_location_visits_sent_foreground,
        key_location_visits_sent_background,
        key_background_fetch_triggered,
        key_application_launched_with_location_key,
        key_total_locations_failed,
        key_locations_failed_background,
        key_locations_failed_foreground,
        key_total_locations_sent,
        key_locations_sent_background,
        key_locations_sent_foreground,
//        key_permissions_location,
//        key_permissions_notifications,
        key_application_did_receive_memory_warning,
        key_application_will_enter_foreground,
        key_application_will_terminate,
        key_application_did_enter_background,
        key_application_did_become_active
    ]

    
    override init()
    {
        if UserDefaults.standard.object(forKey: MZAppStatsHelper.key_old_stats) != nil
         {
            UserDefaults.standard.removeObject(forKey: MZAppStatsHelper.key_old_stats)
            UserDefaults.standard.synchronize()
        }
    }
    

    
    func dailyEventsOrderedByDateAscending(dailyEvents: [String: [String: Int]]) -> [(key: String, value: [String : Int])]
    {
        return dailyEvents.sorted(by: { (MZDateHelper.stringToDate($0.key, dateFormat: MZAppStatsHelper.DATE_FORMAT) as Date).compare(MZDateHelper.stringToDate($1.key, dateFormat: MZAppStatsHelper.DATE_FORMAT)) == .orderedAscending })
    }
    
    
    func generateRandomEvents() -> [String: [String: Int]]
    {
        var dailyEvents = [String: [String: Int]]()
    
        dailyEvents["7-2-2019"] = [String: Int]()
        dailyEvents["8-2-2019"] = [String: Int]()
        dailyEvents["9-2-2019"] = [String: Int]()
        dailyEvents["10-2-2019"] = [String: Int]()
        dailyEvents["11-2-2019"] = [String: Int]()
        dailyEvents["12-2-2019"] = [String: Int]()
        dailyEvents["13-2-2019"] = [String: Int]()
        dailyEvents["14-2-2019"] = [String: Int]()
        dailyEvents["15-2-2019"] = [String: Int]()
        dailyEvents["16-2-2019"] = [String: Int]()
        dailyEvents["17-2-2019"] = [String: Int]()
        dailyEvents["18-2-2019"] = [String: Int]()
        dailyEvents["19-2-2019"] = [String: Int]()
        
        for day in dailyEvents
        {
            var events = [String: Int]()
            for key in keysArray
            {
                let i =  Int.random(in: 0 ... 100)
                
                if i<50
                {
                    continue
                }
                events[key] = Int.random(in: 0 ... 100)
            }
            
            dailyEvents[day.key] = events
        }
        return dailyEvents

    }
    
    func valuesToString(values: [String:[String]]) -> String
    {
        var finalString = ""
        let separator = ";"
        
        //    create date first
        finalString = "dates"
        for v in values["dates"]!
        {
            finalString += separator + v
        }
        
        finalString += "\n"
        
        for val in values
        {
            if val.key == "dates"
            {
                continue
            }
            var line = val.key
            for element in val.value
            {
                line += separator + element
            }
            finalString += line + "\n"
        }
        return finalString
    }

    
    func getDailyInfoStringCSV() -> String
    {
        if UserDefaults.standard.object(forKey: MZAppStatsHelper.key_user_defaults_app_stats) != nil
        {
            let dailyInfoDict = UserDefaults.standard.object(forKey: MZAppStatsHelper.key_user_defaults_app_stats) as! [String: [String: Int]]
            
            return createExcelFileString(dailyInfoDict: dailyInfoDict)
        }
        
        return "No stats were found"
        
    }
    
    func createExcelFileString(dailyInfoDict : [String: [String: Int]]) -> String
    {
        var valuesForExcel = [String : [String]]()
        valuesForExcel["dates"] = [String]()
        
        for day in dailyInfoDict
        {
            if !valuesForExcel["dates"]!.contains(day.key)
            {
                valuesForExcel["dates"]!.append(day.key)
            }
            
            for key in keysArray
            {
                if !valuesForExcel.keys.contains(key)
                {
                    valuesForExcel[key] = [String]()
                }
                
                if day.value.keys.contains(key)
                {
                    valuesForExcel[key]!.append(String(day.value[key]!))
                }
                else
                {
                    valuesForExcel[key]!.append(String(0))
                }
            }
        }
        
        return valuesToString(values: valuesForExcel)
    }
    
    func updateCounter(_ key: String)
    {
        let todaysDate = Date()
        let todaysDateStr = MZDateHelper.dateToString(todaysDate, dateFormat: MZAppStatsHelper.DATE_FORMAT)
        
        var dailyInfoDict = [String: [String: Int]]()
        
        if UserDefaults.standard.object(forKey: MZAppStatsHelper.key_user_defaults_app_stats) != nil
        {
            dailyInfoDict = UserDefaults.standard.object(forKey: MZAppStatsHelper.key_user_defaults_app_stats) as! [String: [String: Int]]
        }
        
        // If there already 10, keep the last 9 days only
        if dailyInfoDict.count > 9
        {
            let orderedDailyEvents = dailyInfoDict.sorted(by: { (MZDateHelper.stringToDate($0.key, dateFormat: MZAppStatsHelper.DATE_FORMAT) as Date).compare(MZDateHelper.stringToDate($1.key, dateFormat: MZAppStatsHelper.DATE_FORMAT)) == .orderedAscending })
            
            let datesToDelete = Array(orderedDailyEvents.prefix(dailyInfoDict.count - 9))
            if(datesToDelete.count > 0)
            {
                for date in datesToDelete
                {
                    dailyInfoDict.removeValue(forKey: date.key)
                }
            }
        }
        
        if !dailyInfoDict.keys.contains(todaysDateStr)
        {
            dailyInfoDict[todaysDateStr] = [String: Int]()
        }
        
        if !dailyInfoDict[todaysDateStr]!.keys.contains(key)
        {
            dailyInfoDict[todaysDateStr]![key] = 1
        }
        else
        {
            dailyInfoDict[todaysDateStr]![key] = dailyInfoDict[todaysDateStr]![key]! + 1
        }
        
        
        UserDefaults.standard.set(dailyInfoDict, forKey: MZAppStatsHelper.key_user_defaults_app_stats)
        UserDefaults.standard.synchronize()
    }
    
    
    
//     User defaults storage
    
    
    static func loadStatsForDay(date: Date) -> [String:Int]?
    {
        
        let userDefaults = UserDefaults.standard
        
        let dateKey = MZDateHelper.dateToString(date, dateFormat: DATE_FORMAT)
        
        if((userDefaults.object(forKey: key_user_defaults_app_stats)) != nil)
        {
            var  appStatsDict = userDefaults.object(forKey: key_user_defaults_app_stats) as? [String : [String : Int]]
            if appStatsDict == nil
            {
                return nil
            }
            
            if appStatsDict![dateKey] != nil
            {
                return appStatsDict![dateKey]
            }
        }
        return nil
    }

    
}
