//
//  MZComponentVibration.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 09/12/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZComponentVibration.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MZComponentVibration ()

@property (nonatomic, strong) NSDictionary *parameters;

@property (nonatomic,readwrite) BOOL active;

@end



@implementation MZComponentVibration

@synthesize active = _active;

#pragma mark - Singleton

+ (MZComponentVibration *)sharedComponentVibration
{
    static MZComponentVibration *sharedComponentVibration = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedComponentVibration = [MZComponentVibration new];
    });
    
    return sharedComponentVibration;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [self _initialize];
    }
    return self;
}

-(void)_initialize
{
    self.active = NO;
}

- (void)configure:(NSDictionary *)parameters
{
    if (parameters && [parameters isKindOfClass:[NSDictionary class]]) {
        
        self.parameters = parameters;
    }
}

- (void)activate:(BOOL)yesOrNo
{
    self.active = yesOrNo;
}

- (void)handleProtocolData:(NSDictionary *)protocolData
{
    NSString *signalAction = protocolData[@"a"];
    //NSObject *dataObject =   protocolData[@"d"];
    
    if ([signalAction isEqualToString:@"vibrate"]) {
        
        [self vibrate];
    }
}

- (void)vibrate
{
    if (self.active) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

@end
