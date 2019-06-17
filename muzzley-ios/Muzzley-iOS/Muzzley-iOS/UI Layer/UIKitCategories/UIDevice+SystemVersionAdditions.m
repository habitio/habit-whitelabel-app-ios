//
//  UIDevice+ProcessInfoAdditions.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 2/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "UIDevice+SystemVersionAdditions.h"

@implementation UIDevice (SystemVersionAdditions)

- (BOOL)systemVersionEqualTo:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame;
}

- (BOOL)systemVersionGreaterThan:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

- (BOOL)systemVersionGreaterThanOrEqualTo:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

- (BOOL)systemVersionLessThan:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

- (BOOL)systemVersionLessThanOrEqualTo:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending;
}


@end
