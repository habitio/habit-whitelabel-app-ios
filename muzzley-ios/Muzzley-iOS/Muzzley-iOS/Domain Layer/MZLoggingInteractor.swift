//
//  MZLoggingInteractor.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 05/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit
import CocoaLumberjack

let logsDirectory: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/logs"

class MZLoggingInteractor: NSObject {

    override init() {
        // Commented out so it doesn't appear in the console/terminal
        // DDLog.add(DDASLLogger.sharedInstance)
        // DDLog.add(DDTTYLogger.sharedInstance)
        let fileManager: DDLogFileManagerDefault = DDLogFileManagerDefault(logsDirectory: logsDirectory)
        let fileLogger: DDFileLogger = DDFileLogger(logFileManager: fileManager)
        fileLogger.maximumFileSize = 1024 * 1024
        fileLogger.rollingFrequency = 3600.0 * 24.0
        fileLogger.logFileManager.maximumNumberOfLogFiles = 3
        fileLogger.logFormatter = DDLogFileFormatterDefault()

        DDLog.add(fileLogger)
    }
}
