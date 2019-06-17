//
//  UserAuthSignUpViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

@class UserAuthSignUpViewController;
@protocol UserAuthSignUpViewControllerDelegate <NSObject>

- (void)userAuthSignUpViewControllerDidSignUp:(UserAuthSignUpViewController*)viewController;
@end

@interface UserAuthSignUpViewController : BaseViewController
@property (nonatomic, weak) id<UserAuthSignUpViewControllerDelegate> delegate;
@end
