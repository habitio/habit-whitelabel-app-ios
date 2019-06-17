//
//  MZLogInInteractor.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UserAuthInteractorIO.h"

@interface UserAuthInteractor : NSObject <UserAuthInteractorInput>

@property (nonatomic, weak) id<UserAuthInteractorOutput> output;

@end
