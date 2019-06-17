//
//  UserAuthSignInViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

@class UserAuthSignInViewController;
@protocol UserAuthSignInViewControllerDelegate <NSObject>

- (void)userAuthSignInViewControllerDidSignIn:(UserAuthSignInViewController*)viewController;
- (void)userAuthSignInViewController:(UserAuthSignInViewController*)viewController didSelectPasswordRecoveryForEmail:(NSString *)email;

@end

@interface UserAuthSignInViewController : BaseViewController
@property (nonatomic, weak) id<UserAuthSignInViewControllerDelegate> delegate;
@end
