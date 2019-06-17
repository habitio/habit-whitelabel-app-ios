//
//  MZBaseInteractor.m
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

#import "MZBaseInteractor.h"
//#import "MZSession.h"

@implementation MZBaseInteractor
@synthesize output;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

+ (BOOL) isArrayContainsAnyArray:(NSArray*)src lookFor:(NSArray*)lookFor
{
//    DLog(@"isArrayContainsAnyArray src %@", src);
//    DLog(@"isArrayContainsAnyArray lookFor %@", lookFor);
    
    for (NSString * v in lookFor)
    {
        if ([src containsObject:v])
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL) isArrayContainsAllArray:(NSArray*)src lookFor:(NSArray*)lookFor
{
//    DLog(@"isArrayContainsAllArray src %@", src);
//    DLog(@"isArrayContainsAllArray lookFor %@", lookFor);
    
    for (NSString * v in lookFor)
    {
        if (![src containsObject:v])
        {
            return NO;
        }
    }
    return YES;
}


+ (NSArray*) arrayOfCommonElements:(NSArray*)src lookFor:(NSArray*)lookFor
{
//    DLog(@"arrayOfCommonElements src %@", src);
//    DLog(@"arrayOfCommonElements lookFor %@", lookFor);
    
    NSMutableArray* returnArray = [NSMutableArray new];
    
    for (NSString * v in lookFor)
    {
        for (NSString * s in src)
        {
            if ([v isEqualToString:s] && ![returnArray containsObject:v]){
                [returnArray addObject:v];
            }
        }
    }
    
//    DLog(@"arrayOfCommonElements returnArray %@", returnArray);
    
    return returnArray;
}


@end
