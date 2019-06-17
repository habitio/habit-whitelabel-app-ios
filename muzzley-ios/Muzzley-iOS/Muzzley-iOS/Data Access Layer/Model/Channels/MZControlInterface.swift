//
//  EChannelInterface.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

import Foundation

class MZControlInterface: NSObject {

    enum MZControlInterfaceKey: NSString {
        case uuid = "uuid"
        case src = "src"
        case url = "url"
        case eTag = "etag"
        case native = "native"
    }
    
    let uuid: String!
    let src: URL?
    let url: URL?
    let eTag: String!
    let native: [MZNativeComponent]!
    
    init?(url: URL?, src: URL?, uuid: String, eTag: String, native: [MZNativeComponent])
    {
        self.url = url
        self.src = src
        self.uuid = uuid
        self.eTag = eTag
        self.native = native
        
        super.init()
        
        if uuid.isEmpty {
            return nil
        }
    }
    
    class func interfaceWithDictionaryRepresentation(_ dictionary : NSDictionary) -> MZControlInterface? {
        
        // Validate values
        var validURL: URL?
        var validSrcURL: URL?
        var validUUIDString : String!
        var validETag : String!
        var validNative: [MZNativeComponent] = []
        
        if !dictionary.isKind(of: NSDictionary.self) {
            return nil;
        }
        
        if let uuid = dictionary[MZControlInterfaceKey.uuid.rawValue] as? String
        {
            validUUIDString = uuid
        }
        else
        {
            
            return nil
        }
        
        if let urlString = dictionary[MZControlInterfaceKey.url.rawValue] as? String
        {
            if let url = URL(string: urlString)
            {
                validURL = url
            }
        }
       
        if let srcUrlString = dictionary[MZControlInterfaceKey.src.rawValue] as? String
        {
            if let srcUrl = URL(string: srcUrlString)
            {
                validSrcURL = srcUrl
            }
        }
        
        if let eTag = dictionary[MZControlInterfaceKey.eTag.rawValue] as? String {
            validETag = eTag
        } else {
            validETag = ""
        }
        
        if let nativeList = dictionary[MZControlInterfaceKey.native.rawValue] as? NSArray {
            for (_, native) in nativeList.enumerated() {
                validNative.append(MZNativeComponent(withDictionaty: native as! NSDictionary))
            }
        }
        
        // Create channel interface
        if let interface = MZControlInterface(url: validURL, src:validSrcURL, uuid: validUUIDString, eTag: validETag, native: validNative)
        {
            return interface
        }
        else
        {
            return nil
        }
    }
    
    func dictionaryRepresentation() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        
        var uuid_: String = ""
        if !self.uuid.isEmpty { uuid_ = self.uuid }
        dictionary[MZControlInterfaceKey.uuid.rawValue] = uuid_
        
        var url_: String = ""
        if (self.url != nil) {
            if let validUrl : String = self.url!.absoluteString {
                url_ = validUrl
            }
        }
        dictionary[MZControlInterfaceKey.url.rawValue] = url_
        
        var src_: String = ""
        if (self.src != nil) {
            if let validSrc: String = self.src!.absoluteString {
                src_ = validSrc
            }
        }
        dictionary[MZControlInterfaceKey.src.rawValue] = src_
        
        var eTag_: String = ""
        if (!self.eTag.isEmpty) { eTag_ = self.eTag }
        dictionary[MZControlInterfaceKey.eTag.rawValue] = eTag_
        
        var native_: NSArray = NSArray()
        if (self.native.count > 0) { native_ = self.native as! NSArray }
        dictionary[MZControlInterfaceKey.native.rawValue] = native_
        
        return dictionary
    }
}
