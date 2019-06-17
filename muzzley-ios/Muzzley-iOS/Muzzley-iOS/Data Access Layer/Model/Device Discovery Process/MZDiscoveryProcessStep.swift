//
//  MZDiscoveryProcessStep.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 11/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation

@objc class MZDiscoveryProcessStep : NSObject
{
//	@property (nonatomic, copy) NSString *context;
//	@property (nonatomic, strong) NSNumber *step;
//	@property (nonatomic, copy) NSString *title;
//	@property (nonatomic, copy) NSString *resultUrl;
//	@property (nonatomifrodc, strong) NSArray *actions;
//	
//
	let key_context = "context"
	let key_step = "step"
	let key_title = "title"
	let key_resultUrl = "resultUrl"
	let key_actions = "actions"
	
	
	var context : String = ""
	var step : Int = 0
	var title : String = ""
	var resultUrl : String = ""
	var actions : NSArray = NSArray()
	
	init(dictionary : NSDictionary)
	{
		if let _context = dictionary[key_context] as? String
		{
			self.context = _context
		}
		else
		{
			self.context = ""
		}
		
		if let _step = dictionary[key_step] as? Int
		{
			self.step = _step
		}
		else
		{
			self.step = 0
		}
		
		if let _title = dictionary[key_title] as? String
		{
			self.title = _title
		}
		else
		{
			self.title = ""
		}
		
		if let _resultUrl = dictionary[key_resultUrl] as? String
		{
			self.resultUrl = _resultUrl
		}
		else
		{
			self.resultUrl = ""
		}
		
		let mutableActions = NSMutableArray()
	
		if let _actions = dictionary[key_actions] as? NSArray
		{
			for actionDict in _actions
			{
				let action = MZDiscoveryProcessAction(dictionary: actionDict as! NSDictionary)
				mutableActions.add(action)
			}
			self.actions = mutableActions

		}
		else
		{
			self.actions = NSArray()
		}
	}
}
