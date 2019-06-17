//
//  MZTileNativeComponentViewModel.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 13/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZTileNativeComponentViewModel: NSObject {
    
    internal var identifier: String!
    internal var type: String!
    internal var size: CGFloat!
    
    fileprivate var model: MZNativeComponent!
    
    override init() {
        super.init()
    }
    
    convenience init(withModel model: MZNativeComponent)
	{
        self.init()
        self.model = model
        self.identifier = model.identifier
        self.type = model.type
        self.size = model.size
    }
    
    internal func toJsonDictionary() -> NSDictionary
	{
		return NSDictionary(dictionary: ["id": self.identifier, "type": self.type, "size": "\(self.size)"])
    }
}
