//
//  MZDeviceMotionEngine.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZComponent.h"

#import <CoreMotion/CoreMotion.h>

#import "MZDeviceMotion.h"

#pragma mark - ENUMERATIONS
typedef enum : NSUInteger {
    
    MZDeviceMotionFireTypeOnTrigger = 1,
    MZDeviceMotionFireTypeOnProximity = 2,
    
} MZDeviceMotionFireType;

typedef enum : NSUInteger {
    
    MZDeviceMotionAxisEnableRoll  = 1,
    MZDeviceMotionAxisEnablePitch = 2,
    MZDeviceMotionAxisEnableYaw   = 3,
    
} MZDeviceMotionAxisEnable;

#pragma mark - PROTOCOLS
@class MZDeviceMotionEngine;

@protocol MZDeviceMotionDelegate <MZComponentDelegate>
@optional

/** Sent to receiver after motion was polled. **/
- (void) deviceMotionEngine:(MZDeviceMotionEngine *)deviceMotionEngine
            didDetectMotion:(MZDeviceMotion*)deviceMotion;

@end


@interface MZDeviceMotionEngine : MZComponent

@property (nonatomic, weak) id <MZDeviceMotionDelegate> delegate;

+ (MZDeviceMotionEngine *) sharedDeviceMotionEngine;

@end
