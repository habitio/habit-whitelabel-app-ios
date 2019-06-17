//
//  MZUserAuthModuleDelegate.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 29/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

extern NSString *const UserAuthModuleDidAuthenticateNotification;

@class UserAuthViewController;

@protocol UserAuthDelegate <NSObject>

- (void)userAuthViewControllerDidAuthenticate:(UserAuthViewController *)viewController;

@end
