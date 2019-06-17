//
//  MZStore.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 22/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZStore: NSObject {
    
    static let key_id: String = "id"
    static let key_name: String = "name"
    static let key_url: String = "url"
    static let key_logo: String = "logo"
    static let key_highlighted: String = "highlighted"
    static let key_price: String = "price"
    static let key_deliver: String = "deliversIn"
    static let key_deliver_timespan: String = "timeSpan"
    static let key_deliver_unit: String = "unit"
    static let key_physical: String = "physical"
    static let key_nearest: String = "nearest"
    static let key_locations: String = "locations"
    static let key_latitude: String = "latitude"
    static let key_longitude: String = "longitude"
    
    var id: String = ""
    var name: String = ""
    var url: String = ""
    var logoURl: String = ""
    var highlighted: Bool = false
    var price: String = ""
    var deliverTimeSpan: [Int] = []
    var deliverUnit: String = ""
    var nearestStore: CGFloat = -1.0
    var locations: [(latitude: Double, longitude: Double)] = []
    
    var dictionaryRepresentation: NSDictionary!
    
    internal var hasBeenViewed: Bool = false
    
    convenience init(dictionary: NSDictionary) {
        self.init()
        
        self.dictionaryRepresentation = dictionary
        
        if let id: String = dictionary[MZStore.key_id] as? String {
            self.id = id
        }
        
        if let name: String = dictionary[MZStore.key_name] as? String {
            self.name = name
        }
        
        if let url: String = dictionary[MZStore.key_url] as? String {
            self.url = url
        }
        
        if let logo: String = dictionary[MZStore.key_logo] as? String {
            self.logoURl = logo
        }
        
        if let highlighted: Bool = dictionary[MZStore.key_highlighted] as? Bool {
            self.highlighted = highlighted
        }
        
        if let price: String = dictionary[MZStore.key_price] as? String {
            self.price = price
        }
        
        if let deliver: NSDictionary = dictionary[MZStore.key_deliver] as? NSDictionary {
            if let timespan: [Int] = deliver[MZStore.key_deliver_timespan] as? [Int] {
                self.deliverTimeSpan = timespan
            }
            
            if let unit: String = deliver[MZStore.key_deliver_unit] as? String {
                self.deliverUnit = unit
            }
        }
        
        if let physical: NSDictionary = dictionary[MZStore.key_physical] as? NSDictionary {
            if let nearest: CGFloat = physical[MZStore.key_nearest] as? CGFloat {
				
				if(MZSessionDataManager.sharedInstance.session.userProfile.preferences.units == "imperial")
				{
					self.nearestStore = nearest * 0.62137 // Convert to miles
				}
				else
				{
					self.nearestStore = nearest // kms
				}
            }
            
            if let locations: [NSDictionary] = physical[MZStore.key_locations] as? [NSDictionary] {
                self.locations.removeAll()
                locations.forEach {
                    if let latitude: Double = $0[MZStore.key_latitude] as? Double {
                        if let longitude: Double = $0[MZStore.key_longitude] as? Double {
                            self.locations.append((latitude, longitude))
                        }
                    }
                }
            }
        }
    }
    
}
