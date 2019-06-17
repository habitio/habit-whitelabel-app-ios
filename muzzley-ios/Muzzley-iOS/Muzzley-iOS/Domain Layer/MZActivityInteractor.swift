//
//  MZActivityInteractor.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/02/2019.
//  Copyright © 2019 Muzzley. All rights reserved.
//

import Foundation
import CoreMotion


class MZActivityInteractor : NSObject
{
    let activityManager = CMMotionActivityManager()
    
    static let shared = MZActivityInteractor()
    
    override init()
    {
        super.init()
        startTracking()
    }
    
    func startTracking()
    {
        activityManager.startActivityUpdates(to: .main) { (activity) in
            guard let activity = activity else {
                return
            }
            
            if !activity.hasActivitySignature || activity.confidence.rawValue < 1
            {
                return
            }
            
            let mainQueue = DispatchQueue.main
            let deadline = DispatchTime.now() + .seconds(1)
            mainQueue.asyncAfter(deadline: deadline) {
                MZContextManager.shared.sendActivity(activityInfo: activity, unknownStart: true, completion: { (error) in
                    if error != nil
                    {
                        Log.error("Error sending activity value.", saveInDebugLog: true)
                    }
                })
            }
        }
    }
    
    func stopTracking()
    {
        activityManager.stopActivityUpdates()
    }
    
    func queryForRecentActivityData()
    {
        let MAX_EVENTS_TO_SEND = 100
        let MAX_HISTORY_CHUNKS_SIZE = 50
        var startDate = MZLocalStorageHelper.loadActivityHistoryLastDateSent()
        if startDate == nil
        {
            var dateComponents = DateComponents()
            dateComponents.setValue(-1, for: .day)
            startDate =  NSCalendar.current.date(byAdding: dateComponents, to: Date())
        }

        self.activityManager.queryActivityStarting(from: startDate!, to: Date(), to: .main) { activities, error in
            if var activities = activities
            {
                if activities.count > 0
                {
                    activities = activities.filter{$0.hasActivitySignature && $0.confidence.rawValue > 0}
                    let segments = self.filter(activities: activities)

                    if segments.count > 0
                    {
                        let segmentsInChunks = segments.chunked(into: MAX_HISTORY_CHUNKS_SIZE)
                        for seg in segmentsInChunks
                        {
                            MZContextManager.shared.sendActivityHistory(segments: seg, completion: { (error) in
                                if error != nil
                                {
                                    Log.error(error)
                                }
                                else
                                {
                                    MZLocalStorageHelper.saveActivityHistoryLastDateSent((seg.last?.endDate)!)
                                }
                            })
                        }

                        var lastActivities = Array(segments.suffix(MAX_EVENTS_TO_SEND))
                        for act in lastActivities
                        {
                            let mainQueue = DispatchQueue.main
                            let deadline = DispatchTime.now() + .seconds(1)
                            mainQueue.asyncAfter(deadline: deadline) {
                                MZContextManager.shared.sendActivity(activityInfo: act.activity, unknownStart: false, completion: { (error) in
                                    if error != nil
                                    {
                                        Log.error(error)
                                    }
                                })
                            }
                        }
                    }
                }
            }
            else if let error = error {
            }
        }
        
    }
    
    func filter(activities: [CMMotionActivity]) -> [ActivitySegment]
    {
        var segments = [ActivitySegment]()
        var i = 0
        var j = 1
        while i < activities.count
        {
            while j < activities.count
            {
                if !activities[i].isSameActivity(activity: activities[j])
                {
                    segments.append(ActivitySegment(activities[i], activities[j].startDate))
                    i = j
                    j += 1
                    break
                }
                j += 1
            }
            i += 1
        }
        return segments
    }
    
    class func getConfidenceNormalized(confidence: CMMotionActivityConfidence) -> Double
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




extension CMMotionActivity {
    
    func isSameActivity(activity: CMMotionActivity) -> Bool {
        // If we have multiple states set in an activity this will indicate a match on the first one.
        return walking == activity.walking &&
            running == activity.running &&
            automotive == activity.automotive &&
            cycling == activity.cycling &&
            stationary == activity.stationary &&
            unknown == activity.unknown
    }
    
    var hasActivitySignature: Bool {
        return walking || running || automotive || cycling || stationary || unknown
    }
}
