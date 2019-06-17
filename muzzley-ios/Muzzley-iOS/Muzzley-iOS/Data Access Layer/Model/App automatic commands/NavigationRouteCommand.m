//
//  MuzCommand.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "NavigationRouteCommand.h"

@interface NavigationRouteCommand ()
@property (nonatomic, readwrite) NSURL *url;
@end

@implementation NavigationRouteCommand

- (void)dealloc
{
    self.url = nil;
}

- (instancetype)initWithUrl:(NSURL *)url
{
    if (self = [super init]) {
        
        if (![url isKindOfClass:[NSURL class]]) return nil;
        if (![url.scheme isEqualToString:MUZZLEY_URL_COMMAND_ID]) return nil;
        if (![url.host isEqualToString:MUZZLEY_URL_COMMAND_NAVIGATE_ID]) return nil;
        self.url = url;
    }
    return self;
}

@end
