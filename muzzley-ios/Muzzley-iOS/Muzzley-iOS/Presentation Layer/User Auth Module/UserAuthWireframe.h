//
//  MZUserAuthWireframe.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 29/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UINavigationControllerPortrait.h"


@class UserAuthViewController;

@interface UserAuthWireframe : NSObject

@property (nonatomic, weak) UserAuthViewController *userAuthViewController;
@property (nonatomic, strong) UINavigationControllerPortrait *navigationController;

- (void) setRootViewController:(UIViewController*) viewController;
- (void)showSignInScreenAnimated:(BOOL)animated;
- (void)showCustomSignInScreenAnimated:(BOOL)animated;
- (void)showResetPasswordScreenWithEmail:(NSString *)email animated:(BOOL)animated fromVC:(UIViewController*)viewController;
- (void)showSignUpScreenAnimated:(BOOL)animated;

@end
