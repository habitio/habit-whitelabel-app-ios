//
//  MZProduct.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 22/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZProduct: NSObject {

    static let key_name: String         = "title"
    static let key_description: String  = "description"
    static let key_image: String        = "image"
    static let key_specs: String        = "specs"
    static let key_stores: String       = "stores"
    
    var imageURL: String = ""
    var name: String = ""
    var productDescription: String = ""
    var specs: String = ""
    var stores: [MZStore] = []
    
    var dictionaryRepresentation: NSDictionary!
    
    convenience init(dictionary: NSDictionary) {
        self.init()
        
        self.dictionaryRepresentation = dictionary
        
        if let image: String = dictionary[MZProduct.key_image] as? String {
            self.imageURL = image
        }
        
        if let name: String = dictionary[MZProduct.key_name] as? String {
            self.name = name
        }
        
        if let desc: String = dictionary[MZProduct.key_description] as? String {
            self.productDescription = desc
        }
        
        if let specs: String = dictionary[MZProduct.key_specs] as? String {
            self.specs = specs
        }
        
        if let stores: [NSDictionary] = dictionary[MZProduct.key_stores] as? [NSDictionary] {
            self.stores.removeAll()
            stores.forEach{ self.stores.append(MZStore(dictionary: $0)) }
        }
    }
    
}
