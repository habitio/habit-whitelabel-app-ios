//
//  MZComponent.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 23/07/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZComponent.h"

@interface MZComponent ()

@property (nonatomic, readwrite) BOOL active;

@end

@implementation MZComponent

@synthesize active = _active;

- (void)configure:(NSDictionary *)parameters
{
    //[NSException raise:@"Invoked abstract method" format:@"MZComponent subclasses should override the configure: abstract method"];
    NSLog(@"MZComponent subclasses should override the configure: abstract method");
}

- (void)activate:(BOOL)yesOrNo
{
    //[NSException raise:@"Invoked abstract method" format:@"MZComponent subclasses should override the activate: abstract method"];
    NSLog(@"MZComponent subclasses should override the activate: abstract method");
}

- (void)handleProtocolData:(NSDictionary *)protocolData
{
    //[NSException raise:@"Invoked abstract method" format:@"MZComponent subclasses should override the handleProtocolData:responseCallback: abstract method"];
    NSLog(@"MZComponent subclasses should override the handleProtocolData:responseCallback: abstract method");
}
@end
