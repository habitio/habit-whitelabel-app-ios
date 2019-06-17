//
//  MZWidgetStore.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 15/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

protocol MZWidgetStoreDelegate : NSObjectProtocol
{
 func handleFetchedURLRequest(request: URLRequest, widgetId : String, channelId: String)
}

class MZWidgetStore: NSObject {

	var delegate : MZWidgetStoreDelegate?
	var widgetRepository : MZWidgetRepository
	
	override init()
	{
		self.widgetRepository = MZWidgetRepository()
	}
	
	func fetchURLRequestForWidget(widgetUUID: String, channelId: String, eTag : String)
	{
		// If widget content is updated retrive from cache otherwise request remote update
		let widgetCachedETag = self.widgetRepository.ETagForId(widgetUUID)
		
		if(eTag == widgetCachedETag)
		{
			if(self.delegate != nil)
			{
				self.delegateHandleFetchedURLRequestForWidgetId(widgetUUID: widgetUUID, channelId: channelId)
			}
		}
		else
		{
			let widgetWS = MZWidgetsWebService()
			widgetWS.getArchiveWithUUID(widgetUUID, eTag: widgetCachedETag, completion: { (archive, eTag, error) in
				if(error == nil)
				{
					if(archive != nil)
					{
						self.widgetRepository.unzipWidgetContent(zipData: archive as! Data, eTag: eTag, widgetUUID: widgetUUID)
					}
					else
					{
						// Show error
						let alert = UIAlertView(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_error_text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: ""))
						alert.show()
					}
				}
				self.delegateHandleFetchedURLRequestForWidgetId(widgetUUID: widgetUUID, channelId: channelId)
			})
		}
	}
	
	func getWidgetURLRequest(widgetUUID: String) -> URLRequest
	{
		let widgetURL = self.widgetRepository.widgetURIForId(widgetUUID)
		return URLRequest(url: widgetURL!)
	}
	
	func delegateHandleFetchedURLRequestForWidgetId(widgetUUID : String, channelId: String)
	{
		let request = self.getWidgetURLRequest(widgetUUID: widgetUUID)
		if(self.delegate != nil)
		{
			self.delegate?.handleFetchedURLRequest(request: request, widgetId: widgetUUID, channelId: channelId)
		}
	}
}
