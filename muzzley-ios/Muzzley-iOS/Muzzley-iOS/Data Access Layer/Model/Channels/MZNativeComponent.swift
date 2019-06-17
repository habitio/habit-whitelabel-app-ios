//
//  MZNativeComponent.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 13/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZNativeComponent: NSObject {
    
    fileprivate enum MZNativeComponentKey: NSString {
        case id = "id"
        case compType = "type"
        case size = "size"
    }
    
    internal var identifier: String!
    internal var type: String!
    internal var size: CGFloat!
    
    override init()
	{
        super.init()
    }
    
    convenience init(withDictionaty dictionary: NSDictionary) {
        self.init()
        
        if let id = dictionary[MZNativeComponentKey.id.rawValue] as? String {
            self.identifier = id
        } else {
            self.identifier = ""
        }
        
        if let type = dictionary[MZNativeComponentKey.compType.rawValue] as? String {
            self.type = type
        } else {
            self.type = ""
        }
		
		
        if let size = dictionary[MZNativeComponentKey.size.rawValue] as? String
		{
			
			if let n = Float(size)//NSNumberFormatter().numberFromString(size)
			{
                self.size = CGFloat(n)
            }
			else
			{
                self.size = 0.0
            }
        } else {
            self.size = 0.0
			
		}
    }
    
}
