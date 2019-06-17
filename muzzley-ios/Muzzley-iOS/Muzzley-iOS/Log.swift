//
//  Log.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 28/08/2018.
//  Copyright © 2018 Habit Analytics. All rights reserved.
//

import Foundation
import CocoaLumberjack

extension Date {
    func toHabitString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}

enum LogEvent: String
{
    case error = "‼️" // error
    case info = ":information_source:" // info
    case statusCode = ":speech_balloon:" // Habit status code description
}


/// Wrapping Swift.print() within DEBUG flag
func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

class Log
{
    private static let ARE_LOGS_ENABLED = true
    private static let ERROR_LOGS_ENABLED = true
    private static let INFO_LOGS_ENABLED = true
    private static let MQTT_LOGS_ENABLED = true
    private static let HTTP_LOGS_ENABLED = true
    private static let CONTEXT_LOGS_ENABLED = true
    private static let STATUS_CODES_LOGS_ENABLED = true
    
    private static var dateFormat = "dd-MM-yyyy hh:mm:ssSSS"
    
    internal static var dateFormatter : DateFormatter
    {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return ARE_LOGS_ENABLED
        #else
        return false
        #endif
    }
    
    class func http( _ object: Any, saveInDebugLog : Bool = false, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if saveInDebugLog && object is String
        {
            DDLogDebug(object as! String)
        }

        if isLoggingEnabled {
            if HTTP_LOGS_ENABLED
            {
                print("[HTTP][\(Date().toString())] => \(object)")
            }
        }
    }
    
    class func mqtt( _ object: Any, saveInDebugLog : Bool = false, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if saveInDebugLog && object is String
        {
            DDLogDebug(object as! String)
        }
        if isLoggingEnabled {
            if MQTT_LOGS_ENABLED
            {
                print("[MQTT][\(Date().toString())] => \(object)")
            }
        }
    }
    
    class func context( _ object: Any, saveInDebugLog : Bool = false, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if saveInDebugLog && object is String
        {
            DDLogDebug(object as! String)
        }
        
        if isLoggingEnabled {
            if CONTEXT_LOGS_ENABLED
            {
                print("[Context][\(Date().toString())] => \(object)")
            }
        }
    }
    
    class func error( _ object: Any, saveInDebugLog : Bool = false, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let commonStr = commonLogStringFormat(event: LogEvent.error, filename: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
        if saveInDebugLog && object is Error
        {
            DDLogDebug("\(commonStr) => \((object as? Error)?.localizedDescription)")
        }
        if isLoggingEnabled {
            if ERROR_LOGS_ENABLED
            {
                let commonStr = commonLogStringFormat(event: LogEvent.error, filename: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
                print("[Error]\(commonStr) => \(object)")
            }
        }
    }
    
    class func info( _ object: Any, saveInDebugLog : Bool = false, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if saveInDebugLog && object is String
        {
            DDLogDebug(object as! String)
        }
        if isLoggingEnabled {
            if INFO_LOGS_ENABLED
            {
                print("[\(Date().toString())] => \(object)")
            }
        }
    }
    
    class func detailedInfo( _ object: Any, saveInDebugLog : Bool = false, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if saveInDebugLog && object is String
        {
            DDLogDebug(object as! String)
        }
        if isLoggingEnabled {
            if INFO_LOGS_ENABLED
            {
                let commonStr = commonLogStringFormat(event: LogEvent.info, filename: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
                print("\(commonStr) => \(object)")
            }
        }
    }
    
//    class func statusCode( _ statusCode: HabitStatusCode, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
//        if isLoggingEnabled {
//            if STATUS_CODES_LOGS_ENABLED
//            {
//                let commonStr = commonLogStringFormat(event: LogEvent.statusCode, filename: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
//                print("\(commonStr) => HabitStatusCode: \(statusCode) - \(HabitStatusCodes.getDescription(code: statusCode))")
//            }
//        }
//    }
    
    private class func commonLogStringFormat(event: LogEvent, filename:String, line: Int, column : Int, funcName: String) -> String
    {
        return "\(event.rawValue) [\(Date().toString())] \(sourceFileName(filePath: filename)): \(line) \(column) [\(funcName)]"
    }
    
    private class func sourceFileName(filePath: String) -> String
    {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}
