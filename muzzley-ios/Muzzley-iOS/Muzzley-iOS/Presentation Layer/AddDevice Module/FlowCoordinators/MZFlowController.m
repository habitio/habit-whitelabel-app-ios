//
//  CoordinationController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 07/05/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZFlowController.h"

@implementation MZFlowController

- (void)dealloc
{
    self.viewController = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.viewController = nil;
    }
    return self;
}

@end
