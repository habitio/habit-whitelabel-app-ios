//
//  UIFont+Muzzley.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 25/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

    class func lightFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-Light", size: CGFloat(size))!
    }
    
    class func lightItalicFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-LightItalic", size: CGFloat(size))!
    }
    
    class func regularFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-Regular", size: CGFloat(size))!
    }
    
    class func italicFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-Italic", size: CGFloat(size))!
    }
    
    class func boldFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-Bold", size: CGFloat(size))!
    }
    
    class func boldItalicFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-BoldItalic", size: CGFloat(size))!
    }
    
    class func heavyFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoDisplay-Heavy", size: CGFloat(size))!
    }

    class func semiboldFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-Semibold", size: CGFloat(size))!
    }
    
    class func semiboldItalicFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-SemiboldItalic", size: CGFloat(size))!
    }
    
    class func mediumFontOfSize(_ size: Float) -> UIFont {
        return UIFont(name: "SanFranciscoText-Medium", size: CGFloat(size))!
    }
    
}
