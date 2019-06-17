//
//  UserAuthResetPasswordViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

@class UserAuthResetPasswordViewController;
@protocol UserAuthResetPasswordViewControllerDelegate <NSObject>

- (void)userAuthResetPasswordViewControllerDidSendPasswordRecoveryEmail:(UserAuthResetPasswordViewController *)viewController;

@end

@interface UserAuthResetPasswordViewController : BaseViewController

@property (nonatomic, weak) id<UserAuthResetPasswordViewControllerDelegate> delegate;

- (instancetype)initWithEmail:(NSString *)email;

@end
