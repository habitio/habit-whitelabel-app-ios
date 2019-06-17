//
//  SignUpTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 20/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

@class SignUpTableViewCell;
@protocol SignUpTableViewCellDelegate <NSObject>

- (void)signUpTableViewCell:(SignUpTableViewCell *)cell didSelectSignUpActionWithName:(NSString *)name email:(NSString *)email password:(NSString *)password;
@end

@interface SignUpTableViewCell : UITableViewCell
@property (nonatomic, weak) id<SignUpTableViewCellDelegate> delegate;

- (void)enableUserInteractionIfNeeded;
@end
