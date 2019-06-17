//
//  MZAppManagerHelper.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 23/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

class MZSessionValidationHelper: NSObject
{
	// True, can proceed to root
	// False, logout if it's not logged out already

	class func validClientVersion() -> Bool
	{
		if let goodUntil = MZLocalStorageHelper.loadVersionGoodUntilFromNSUserDefaults()
		{
			let dateFormatter = DateFormatter()
			let format = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
			let goodUntilDate = dateFormatter.date(from: goodUntil)
			
//			if(goodUntilDate.compare(Date.))
			
		}
	
//		if ([[NSUserDefaults standardUserDefaults] stringForKey:@"goodUntil"] != nil)
//		{
//			NSString * goodUntil = [[NSUserDefaults standardUserDefaults] stringForKey:@"goodUntil"];
//			NSDate * goodUntilDate = [NSDate dateFromString:goodUntil withFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"];
//			
//			if (completion && [goodUntilDate compare:[NSDate new]] == NSOrderedDescending)
//			{
//				completion(YES, nil);
//				completion = nil;
//			}
//		}
//		
//		NSDictionary * params = @{MZClientVersionWebService.key_version:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]};
//		
//		//TODO only call this if missing 2 days to end
//		[[MZClientVersionWebService sharedInstance] getVersionSupport:params completion:^(id result, NSError * error) {
//			if (error == nil)
//			{
//			if ([result isKindOfClass:[NSDictionary class]] && result[@"goodUntil"] != nil)
//			{
//			NSDate * goodUntilDate = [NSDate dateFromString:result[@"goodUntil"] withFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"];
//			[[NSUserDefaults standardUserDefaults] setObject:result[@"goodUntil"] forKey:@"goodUntil"];
//			[[NSUserDefaults standardUserDefaults] synchronize];
//			if (completion) { completion([goodUntilDate compare:[NSDate new]] == NSOrderedDescending, error); return; }
//			}
//			}
//			
//			if (completion) {
//			completion(YES, error);
//			}
//			}];

		return true
	}
	
	class func loadUserAuthInfoFromCache() -> Bool
	{
		let userAuthInfo = MZLocalStorageHelper.loadAuthInfoFromNSUserDefaults()
		if(userAuthInfo == nil)
		{
			return false
		}
		
		if(userAuthInfo!.userId.isEmpty)
		{
			return false
		}
		
		MZSession.sharedInstance.authInfo = userAuthInfo
		
		return true
	}
	

	class func refreshToken(completion: @escaping (_ success: Bool) -> Void)
	{
		MZOAuthWebService.sharedInstance.refreshToken { (response, error) in
			if(response != nil)
			{
				completion(true)
				return
			}
			completion(false)
		}
	}
	
	class func needsToRefreshToken(expiresDateStr: String) -> Bool
	{
		var dateFormatter = DateFormatter()
		dateFormatter.calendar = Calendar.current
		dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
		
		let todayDate = Date()
//		print(expiresDateStr)
		let expiresDate = dateFormatter.date(from: expiresDateStr)
		
		if(expiresDate == nil) // Invalid date
		{
				return true
		}
		
		let daysBetweenUntilExpiration = Calendar.current.dateComponents([.day],
			                                                             from: todayDate,
			                                                             to: expiresDate!)
//		print(daysBetweenUntilExpiration.day!)
		
		// Already passed or is the same day, then refresh
		if(daysBetweenUntilExpiration.day! <= 0)
		{
			return true
		}
		else
		{
			return false
		}
	}
	
	class func loadUserProfileFromCache() -> Bool
	{
        
//		let userProfile = MZLocalStorageHelper.loadUserInfoFromNSUserDefaults()
//		if(userProfile == nil)
//		{
//			return false
//		}
//		
//		if(userProfile.userId.isEmpty)
//		{
//			return false
//		}
//		
//		MZSessionDataManager.sharedInstance.session.userProfile = userProfile
//		
		return true
	}
	
}
