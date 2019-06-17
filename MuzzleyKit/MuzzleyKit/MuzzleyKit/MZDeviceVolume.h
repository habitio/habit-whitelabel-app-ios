//
//  MZDeviceVolume.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZComponent.h"
#import "MZDeviceVolumeViewController.h"

@class MZDeviceVolume;

/// Device Volume KeyType
typedef enum : NSUInteger {
    MZDeviceVolumeKeyTypeUp      = 1,
    MZDeviceVolumeKeyTypeDown    = 2
} MZDeviceVolumeKeyType;

@protocol MZDeviceVolumeDelegate <MZComponentDelegate>
@optional
/** Sent to receiver after a system volume key being pressed. */

-(void)deviceVolume:(MZDeviceVolume *)deviceVolume didPressKey:(MZDeviceVolumeKeyType)key;

@end

typedef void (^ButtonBlock)();

@interface MZDeviceVolume : MZComponent
{
    float launchVolume;
    BOOL hadToLowerVolume;
    BOOL hadToRaiseVolume;
    BOOL justEnteredForeground;
}

@property (nonatomic, weak) id <MZDeviceVolumeDelegate> delegate;

@property (nonatomic, copy) ButtonBlock upBlock;
@property (nonatomic, copy) ButtonBlock downBlock;
@property (nonatomic, readonly) float launchVolume;

@property (nonatomic, strong) MZDeviceVolumeViewController *deviceVolumeViewController;

+ (MZDeviceVolume *)sharedDeviceVolume;

@end
