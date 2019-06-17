//
//  MZShortcut.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 10/02/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZShortcut: NSObject {

    static let key_id = "id"
    static let key_color = "color"
    static let key_order = "order"
    static let key_origin = "origin"
    static let key_label = "label"
    static let key_showInWatch = "showInWatch"
    static let key_execute = "execute"
    static let key_actions = "actions"
    
    var identifier: String = ""
    var color: UIColor = UIColor.clear
    var order: Int = -1
    var origin: String = "manual"
    var label: String = ""
    var showInWatch: Bool = false
    var executeParams: [NSDictionary] = []
    var actions: [MZBaseWorkerDevice] = []
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    convenience init(dictionary: NSDictionary) {
        self.init()
        
        self.dictionaryRepresentation = dictionary
        
        if let identifier: String = dictionary[MZShortcut.key_id] as? String {
            self.identifier = identifier
        }
        
        if let color: String = dictionary[MZShortcut.key_color] as? String {
            self.color = UIColor(hex: color)
        }
        
        if let order: Int = dictionary[MZShortcut.key_order] as? Int {
            self.order = order
        }
        
        if let origin: String = dictionary[MZShortcut.key_origin] as? String {
            self.origin = origin
        }
        
        if let label: String = dictionary[MZShortcut.key_label] as? String {
            self.label = label
        }
        
        if let showInWatch: Bool = dictionary[MZShortcut.key_showInWatch] as? Bool {
            self.showInWatch = showInWatch
        }
        
        if let execute: [NSDictionary] = dictionary[MZShortcut.key_execute] as? [NSDictionary] {
            execute.forEach{ self.executeParams.append($0) }
        }
        
        if let actions: [NSDictionary] = dictionary[MZShortcut.key_actions] as? [NSDictionary] {
            for element in actions {
                var workerDeviceM: MZBaseWorkerDevice
                let channelId: String = element[MZBaseWorkerDevice.key_channel] as! String
                var componentId: String = ""
                if let comp = element[MZBaseWorkerDevice.key_component] as? String {
                    componentId = comp
                } else {
                    componentId = String(describing: element[MZBaseWorkerDevice.key_component])
                }
                
                if self.actions.isEmpty {
                    workerDeviceM = MZBaseWorkerDevice(dictionary: element)
                    workerDeviceM.type = MZWorker.key_action
                    self.actions.append(workerDeviceM)
                } else {
                    let filtered = self.actions.filter({ (workerDevice: MZBaseWorkerDevice) -> Bool in
                        let sameChannelId = workerDevice.channelId == channelId
                        let filteredComponents = workerDevice.componentIds.filter {$0 == componentId}
                        return (sameChannelId && filteredComponents.count > 0)
                    })
                    
                    if filtered.isEmpty {
                        workerDeviceM = MZBaseWorkerDevice(dictionary: element)
                        workerDeviceM.type = MZWorker.key_action
                        self.actions.append(workerDeviceM)
                    } else {
                        workerDeviceM = filtered[0]
                    }
                }
                
                let workerItem = MZBaseWorkerItem(dictionary: element)
                workerDeviceM.items.append(workerItem)
            }
        }
    }
    
    internal func toWorkerModel() -> MZWorker {
        let worker: MZWorker = MZWorker()
        worker.identifier = self.identifier
        worker.label = self.label
        worker.executeCommands = self.executeParams
        worker.actionDevices = self.actions
        return worker
    }

}
