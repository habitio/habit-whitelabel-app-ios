//
//  Constants.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 10/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import Foundation

#if DEBUG
    func dLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        print("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
    }
#else
    func dLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
#endif
func aLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    print("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
}

/*class Constants : NSObject
{
    static let VIDEO_STREAM_CLASS = "com.muzzley.properties.url.stream"
    static let AUDIO_STREAM_CLASS = "com.muzzley.properties.url.stream.audio"
    
    
    //TODO check how to use inner class on objc
	class APIUrls
	{
		static let API_BASE_URL = ""
	}
	
	
	class UrlParams
	{
		static let KEY_USER     = "userId"
		static let KEY_TILE     = "tileId"
		static let KEY_ACTION   = "action"
		static let KEY_INCLUDE  = "include"
		static let KEY_EXCLUDE  = "exclude"
		static let KEY_OFFSET   = "offset"
		static let KEY_LIMIT    = "limit"
		static let KEY_PLACE    = "place"
		static let KEY_CATEGORY = "category"
		static let KEY_TYPE     = "type"
		static let KEY_CHANNELS = "channels"
		static let KEY_MUZZCAP  = "muz-capabilities"
	}
}*/

struct Constants
{
    struct Class
    {
        static let Credentials = "com.muzzley.properties.credentials"
        static let VideoStream = "com.muzzley.properties.url.stream"
        static let AudioStream = "com.muzzley.properties.url.stream.audio"
        static let Host = "com.muzzley.properties.host"
    }
}
