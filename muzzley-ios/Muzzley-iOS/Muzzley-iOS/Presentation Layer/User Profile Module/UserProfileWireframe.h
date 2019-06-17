//
//  MZUserProfileWireframe.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 29/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "Wireframe.h"

@class MZUserProfileViewController;

@interface UserProfileWireframe : Wireframe

@property (nonatomic, weak) MZUserProfileViewController *userProfileViewController;

@end