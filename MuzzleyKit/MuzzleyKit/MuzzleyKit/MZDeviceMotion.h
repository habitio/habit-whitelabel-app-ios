//
//  MZDeviceMotion.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 05/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <CoreMotion/CMAccelerometer.h>
#import <CoreMotion/CMAttitude.h>
#import <CoreMotion/CMGyro.h>
#import <CoreMotion/CMMagnetometer.h>
#import "MZAttitude.h"

@interface MZDeviceMotion : NSObject

/*
 *  attitude
 *
 *  Discussion:
 *    Returns the attitude of the device.
 *
 */
@property(nonatomic) MZAttitude *attitude;

/*
 *  rotationRate
 *
 *  Discussion:
 *    Returns the rotation rate of the device for devices with a gyro.
 *
 */
@property(nonatomic) CMRotationRate rotationRate;

/*
 *  gravity
 *
 *  Discussion:
 *    Returns the gravity vector expressed in the device's reference frame. Note
 *		that the total acceleration of the device is equal to gravity plus
 *		userAcceleration.
 *
 */
@property(nonatomic) CMAcceleration gravity;

/*
 *  userAcceleration
 *
 *  Discussion:
 *    Returns the acceleration that the user is giving to the device. Note
 *		that the total acceleration of the device is equal to gravity plus
 *		userAcceleration.
 *
 */
@property(nonatomic) CMAcceleration userAcceleration;


@end
