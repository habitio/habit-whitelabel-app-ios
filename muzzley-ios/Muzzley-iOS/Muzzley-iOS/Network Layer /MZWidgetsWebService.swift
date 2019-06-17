//
//  MZWidgetsWebService.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

import RxSwift
import AFNetworking

class MZWidgetsWebService: MZBaseWebService
{

	func getArchiveWithUUID(_ uuid: String, eTag: String, completion: @escaping (_ result: AnyObject?, _ etag : String, _ error: NSError?) -> Void)
	{
		let path = MZEndpoints.WidgetArchive(uuid: uuid)

		self.sessionManager.responseSerializer = AFHTTPResponseSerializer()
	
		self.sessionManager.requestSerializer.setValue(eTag, forHTTPHeaderField: "If-None-Match")

		self.sessionManager.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        
        dLog("Loading widget with path " + path)
        
		self.sessionManager.get(path, parameters: nil, progress: { (progress) in
			}, success: { (task, responseObject) in
				let lowercasedHeaders = self.lowercaseHeaders(allHeaderFields: (task.response as! HTTPURLResponse).allHeaderFields as NSDictionary) //(task as! HTTPURLResponse).allHeaderFields as NSDictionary)
				let originalContentSHA256 = lowercasedHeaders["content-sha256"] as! String
				let etagValue = lowercasedHeaders["etag"] as! String
				let content : NSData = responseObject as! NSData
				
				let contentSHA256 = (content.sha256() as! NSData).hexRepresentation(withSpaces: false, uppercase: false)
				if(content.isKind(of: NSData.self) && originalContentSHA256 == contentSHA256)
				{
					completion(content, etagValue, nil)
				}
				else
				{
					let error = NSError(domain: "WidgetsWSErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey	: "Widget Serialization data error"])
					completion(nil, etagValue, error)
				}
			}, failure: { (task, error) in
				if let err = error as? NSError
				{
					if(err.code == NSURLErrorCancelled) { return }
					
					completion(nil, "", err)
				}
			}
		)
	}

	func lowercaseHeaders(allHeaderFields: NSDictionary) -> NSDictionary
	{
		let lowercasedHeaders = NSMutableDictionary()
		for header in allHeaderFields
		{
			lowercasedHeaders[(header.key as! String).lowercased()] = (header.value as! String).lowercased()
		}
		
		return lowercasedHeaders
	}
}

