//
//  SignInTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

@class SignInTableViewCell;
@protocol SignInTableViewCellDelegate <NSObject>

- (void)signInTableViewCell:(SignInTableViewCell *)cell didSelectSignInActionWithEmail:(NSString *)email password:(NSString *)password;

- (void)signInTableViewCell:(SignInTableViewCell *)cell didSelectForgotPasswordActionWithEmail:(NSString *)email;

@end

@interface SignInTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SignInTableViewCellDelegate> delegate;

- (void)enableUserInteractionIfNeeded;
- (NSString *)email;
@end
