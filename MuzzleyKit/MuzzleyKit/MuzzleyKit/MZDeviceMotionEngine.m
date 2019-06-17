//
//  MZDeviceMotionEngine.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZDeviceMotionEngine.h"

#import "MZMessage.h"
#import "MZUserClient.h"

typedef enum : NSUInteger {
    FireOnTriggerAxisRoll = 1,
    FireOnTriggerAxisPitch = 2,
    FireOnTriggerAxisYaw = 3,
    
} FireOnTriggerAxis;

@interface MZDeviceMotionEngine ()


@property (nonatomic, strong) CMMotionManager* motionManager;

@property (nonatomic) MZDeviceMotionFireType fireType;
@property (nonatomic) NSTimeInterval pollingTimeInterval;
@property (nonatomic) NSUInteger step;

@property (nonatomic, assign) bool rollActive;
@property (nonatomic, assign) bool pitchActive;
@property (nonatomic, assign) bool yawActive;

@property (nonatomic, readwrite) BOOL active;


@property (nonatomic, strong) NSDictionary *parameters;

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) MZAttitude *lastAttitude;
@property (nonatomic, strong) MZAttitude *lastFireAttitude;

@property (nonatomic, assign) bool canDelegateDeviceMotion;

@end




@implementation MZDeviceMotionEngine
@synthesize active = _active;
@dynamic delegate;
-(void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

#pragma mark -
#pragma mark Singleton

+ (MZDeviceMotionEngine *) sharedDeviceMotionEngine
{
    static MZDeviceMotionEngine *sharedDeviceMotionEngine = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDeviceMotionEngine = [MZDeviceMotionEngine new];
    });
    
    return sharedDeviceMotionEngine;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        [self configure:nil];
        
        self.pollingTimeInterval = 1.0 / 10;
        
        self.lastAttitude = [MZAttitude new];
        self.lastAttitude.roll = 0;
        self.lastAttitude.pitch = 0;
        self.lastAttitude.yaw = 0;
        
        self.lastFireAttitude = [MZAttitude new];
        self.lastFireAttitude.roll = 0;
        self.lastFireAttitude.pitch = 0;
        self.lastFireAttitude.yaw = 0;
        
        self.canDelegateDeviceMotion = NO;
        
        self.motionManager = [CMMotionManager new];
        if (!self.motionManager.deviceMotionAvailable) {
            NSLog(@"WARNING: Device Motion not available in the device!");
            return nil;
        }
        
        CMAttitudeReferenceFrame attitudeReferenceFrame = CMAttitudeReferenceFrameXMagneticNorthZVertical;
        if (([CMMotionManager availableAttitudeReferenceFrames] & attitudeReferenceFrame) == 0 ) {
            NSLog(@"WARNING: Not available attitude reference frames");
            return nil;
        }
        
        self.motionManager.showsDeviceMovementDisplay = YES;
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 20.0;
        
        /*[self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:attitudeReferenceFrame];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.pollingTimeInterval
                                                      target:self
                                                    selector:@selector(pollMotion:)
                                                    userInfo:nil
                                                     repeats:YES];
        */
        self.active = NO;
    }
    return self;
}

- (void) configure:(NSDictionary *)parameters
{
    if (parameters) {
       
        if ([[parameters objectForKey:@"fireType"] isEqualToString:@"onProximity"]) {
            self.fireType = MZDeviceMotionFireTypeOnProximity;
        } else {
            self.fireType = MZDeviceMotionFireTypeOnTrigger;
        }
        
        self.step = [[parameters objectForKey:@"step"] unsignedIntegerValue];
        
        self.rollActive = [[parameters objectForKey:@"roll"] boolValue];
        self.pitchActive = [[parameters objectForKey:@"pitch"] boolValue];
        self.yawActive = [[parameters objectForKey:@"yaw"] boolValue];

    } else {
        
        self.fireType = MZDeviceMotionFireTypeOnProximity;
        self.step = 15;
        self.rollActive = NO;
        self.pitchActive = NO;
        self.yawActive = NO;
    }

}

- (void)setStep:(NSUInteger)step {
    
    _step = step;
    if (step < 1) _step = 1;
}

- (void)activate:(BOOL)yesOrNo
{
    self.active = yesOrNo;
    
    if (self.active) {
        
        //if (![self.motionManager isDeviceMotionActive]) {
        [self.motionManager stopDeviceMotionUpdates];
        
        CMAttitudeReferenceFrame attitudeReferenceFrame = CMAttitudeReferenceFrameXMagneticNorthZVertical;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:attitudeReferenceFrame];
        
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.pollingTimeInterval
                                                      target:self
                                                    selector:@selector(pollMotion:)
                                                    userInfo:nil
                                                     repeats:YES];
        //}
        
    } else {
        
        [self.timer invalidate];
        [self.motionManager stopDeviceMotionUpdates];
    }
    
}

- (void)pollMotion:(id)sender
{
    /// Wait until the magnetometer is ready, and then we start taking attitude readings (converted to degrees)
    CMDeviceMotion* deviceMotion = self.motionManager.deviceMotion;
    if (deviceMotion.magneticField.accuracy <= CMMagneticFieldCalibrationAccuracyLow) {
        return; /// not ready yet
    }
    
    NSInteger totalSteps = 360/self.step;
    
    /// The values are all close to zero when the device is level with its top pointing to magnetic north, and each value increases as the device is rotated counterclockwise with respect to an eye that has the corresponding positive axis pointing at it. So, for example, a device held upright (top pointing at the sky) has a pitch approaching 90; a device lying on its right edge has a roll approaching 90; and a device lying on its back with its top pointing west has a yaw approaching 90.
    
    /// There are some quirks to be aware of in the way that Euler angles operate mathematically:
    
    /// Roll and Yaw increase with counterclockwise rotation from 0 to π (180 degrees) and then jump to -π (-180 degrees) and continue to increase to 0 as the rotation completes a circle; but Pitch increases to π/2 (90 degrees) and then decreases to 0, then decreases to -π/2 (-90 degrees) and increases to 0. This means that attitude alone, if we are exploring it through pitch, roll, and yaw, is insufficient to describe the device’s attitude, since a pitch value of, say, π/4 (45 degrees) could mean two different things. To distinguish those two things, we can supplement attitude with the z-component of gravity
    
    MZAttitude *mzAttitude = [self convertAttitudeRadiansToDegreesFromDeviceMotion:deviceMotion];
    MZDeviceMotion *mzDeviceMotion = [MZDeviceMotion new];
    
    ///////////////////////////////////////////////////////
    ///  Calculate Fire range logic                     ///
    ///////////////////////////////////////////////////////
    self.canDelegateDeviceMotion = NO;
    if (self.fireType == MZDeviceMotionFireTypeOnProximity) {
        
        mzAttitude.roll =  round( (mzAttitude.roll + (self.step/2) ) / self.step) * self.step;
        mzAttitude.pitch = round( (mzAttitude.pitch + (self.step/2) ) / self.step) * self.step;
        mzAttitude.yaw =   round( (mzAttitude.yaw + (self.step/2) ) / self.step) * self.step;
        
        if (mzAttitude.roll == 360)  mzAttitude.roll = 0;
        if (mzAttitude.pitch == 360) mzAttitude.pitch = 0;
        if (mzAttitude.yaw == 360)   mzAttitude.yaw = 0;
        
        if ( mzAttitude.roll != self.lastFireAttitude.roll && self.rollActive) self.canDelegateDeviceMotion = YES;
        if ( mzAttitude.pitch != self.lastFireAttitude.pitch && self.pitchActive) self.canDelegateDeviceMotion = YES;
        if ( mzAttitude.yaw != self.lastFireAttitude.yaw && self.yawActive) self.canDelegateDeviceMotion = YES;
        
        if (self.canDelegateDeviceMotion) {
            
            /// Call the delegate
            mzDeviceMotion.attitude = mzAttitude;
            mzDeviceMotion.rotationRate = deviceMotion.rotationRate;
            mzDeviceMotion.gravity = deviceMotion.gravity;
            mzDeviceMotion.userAcceleration = deviceMotion.userAcceleration;
            
            if ([self.delegate respondsToSelector:@selector(deviceMotionEngine:didDetectMotion:)] ) {
                
                [self.delegate deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
            }
            [self _deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
            
            self.lastFireAttitude = mzAttitude;
        }
        
        
    } else if (self.fireType == MZDeviceMotionFireTypeOnTrigger) {
        
        /// Roll
        if (mzAttitude.roll != self.lastAttitude.roll && self.rollActive) {
            
            /// Check which step area corresponds the new attitude
            NSInteger lastPitchStep = self.lastAttitude.roll / self.step; //  359 35
            NSInteger newPitchStep = mzAttitude.roll / self.step;         //  0    0
            NSInteger rangeToTrigger = newPitchStep - lastPitchStep;       //  0 - 35 = -35
            NSInteger absRangeToTrigger = labs(rangeToTrigger);             //  35
            bool isOnStep = (mzAttitude.roll % self.step == 0); // yes
            bool stepForward;
            
            
            if (rangeToTrigger != 0 || isOnStep) {
                /// Fires
                /// Find a shortcut range if the old range
                if (absRangeToTrigger > totalSteps * 0.5 ) {
                    
                    rangeToTrigger = rangeToTrigger > 0 ? (rangeToTrigger - totalSteps) : (rangeToTrigger + totalSteps);
                    absRangeToTrigger = labs(rangeToTrigger);
                }
                
                stepForward = rangeToTrigger > 0;
                NSInteger lastFirePitch;
                
                for (int i = 1; i <= absRangeToTrigger ; i++) {
                    
                    if (stepForward) { /// is going Up ( counter-clockwise )
                        lastFirePitch = (lastPitchStep + i) * self.step;
                        lastFirePitch = lastFirePitch % 360;
                        
                    } else { /// is going Down ( clockwise )
                        lastFirePitch = (lastPitchStep - i + 1 ) * self.step;
                        if (lastFirePitch < 0) lastFirePitch = 360 + lastFirePitch;
                    }
                    
                    /// Fire
                    mzDeviceMotion.attitude = [MZAttitude new];
                    mzDeviceMotion.attitude.roll = lastFirePitch;
                    /// BUG The next line of code is needed to avoid getting a large degree number that sometimes spawns in the sector 1
                    /// when rotating from a degree greater than 0 to 0. It should fire 0 but instead fires a large degree number.
                    if (mzDeviceMotion.attitude.roll > 359 || mzDeviceMotion.attitude.roll < 0) mzDeviceMotion.attitude.roll = 0;
                    self.lastFireAttitude.roll = mzDeviceMotion.attitude.roll;
                    mzDeviceMotion.attitude.pitch = self.lastFireAttitude.pitch;
                    mzDeviceMotion.attitude.yaw = self.lastFireAttitude.yaw;
                    
                    mzDeviceMotion.rotationRate = deviceMotion.rotationRate;
                    mzDeviceMotion.gravity = deviceMotion.gravity;
                    mzDeviceMotion.userAcceleration = deviceMotion.userAcceleration;
                    
                    if ([self.delegate respondsToSelector:@selector(deviceMotionEngine:didDetectMotion:)] ) {
                        
                        [self.delegate deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
                    }
                    [self _deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
                }
                
                //self.lastFireAttitude.roll = lastFirePitch;
                self.lastAttitude.roll = mzAttitude.roll;
                
            } else {
                /// If the angle is one of the steps fire it
                //if (mzAttitude.pitch % self.step == 0) self.lastFireAttitude.pitch = mzAttitude.pitch;
                //NSLog(@"INFO:RangeTrigger = 0");
            }
            
        }
        
        /// Pitch
        /// If the angle is the same ignore it
        if (mzAttitude.pitch != self.lastAttitude.pitch && self.pitchActive) {
            
            /// Check which step area corresponds the new attitude
            NSInteger lastPitchStep = self.lastAttitude.pitch / self.step; //  359 35
            NSInteger newPitchStep = mzAttitude.pitch / self.step;         //  0    0
            NSInteger rangeToTrigger = newPitchStep - lastPitchStep;       //  0 - 35 = -35
            NSInteger absRangeToTrigger = labs(rangeToTrigger);             //  35
            bool isOnStep = (mzAttitude.pitch % self.step == 0); // yes
            bool stepForward;
            
            if (rangeToTrigger != 0 || isOnStep) {
                /// Fires
                /// Find a shortcut range if the old range
                if (absRangeToTrigger > totalSteps * 0.5 ) {
                    
                    rangeToTrigger = rangeToTrigger > 0 ? (rangeToTrigger - totalSteps) : (rangeToTrigger + totalSteps);
                    absRangeToTrigger = labs(rangeToTrigger);
                }
                
                stepForward = rangeToTrigger > 0;
                NSInteger lastFirePitch;
                
                for (int i = 1; i <= absRangeToTrigger ; i++) {
                    
                    if (stepForward) { /// is going Up ( counter-clockwise )
                        lastFirePitch = (lastPitchStep + i) * self.step;
                        lastFirePitch = lastFirePitch % 360;
                        
                    } else { /// is going Down ( clockwise )
                        lastFirePitch = (lastPitchStep - i + 1 ) * self.step;
                        if (lastFirePitch < 0) lastFirePitch = 360 + lastFirePitch;
                    }
                    
                    /// Fire
                    mzDeviceMotion.attitude = [MZAttitude new];
                    mzDeviceMotion.attitude.roll = self.lastFireAttitude.roll;
                    mzDeviceMotion.attitude.pitch = lastFirePitch;
                    /// BUG The next line of code is needed to avoid getting a large degree number that sometimes spawns in the sector 1
                    /// when rotating from a degree greater than 0 to 0. It should fire 0 but instead fires a large degree number.
                    if (mzDeviceMotion.attitude.pitch > 359 || mzDeviceMotion.attitude.pitch < 0) mzDeviceMotion.attitude.pitch = 0;
                    self.lastFireAttitude.pitch = mzDeviceMotion.attitude.pitch;
                    mzDeviceMotion.attitude.yaw = self.lastFireAttitude.yaw;
                    
                    mzDeviceMotion.rotationRate = deviceMotion.rotationRate;
                    mzDeviceMotion.gravity = deviceMotion.gravity;
                    mzDeviceMotion.userAcceleration = deviceMotion.userAcceleration;
                    
                    if ([self.delegate respondsToSelector:@selector(deviceMotionEngine:didDetectMotion:)] ) {
                        
                        [self.delegate deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
                    }
                    [self _deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
                }
                
                //self.lastFireAttitude.pitch = lastFirePitch;
                self.lastAttitude.pitch = mzAttitude.pitch;
                
            } else {
                /// If the angle is one of the steps fire it
                //if (mzAttitude.pitch % self.step == 0) self.lastFireAttitude.pitch = mzAttitude.pitch;
                //NSLog(@"INFO:RangeTrigger = 0");
            }
        }
        
        /// Yaw
        /// If the angle is the same ignore it
        if (mzAttitude.yaw != self.lastAttitude.yaw && self.yawActive) {
            
            /// Check which step area corresponds the new attitude
            NSInteger lastPitchStep = self.lastAttitude.yaw / self.step; //  359 35
            NSInteger newPitchStep = mzAttitude.yaw / self.step;         //  0    0
            NSInteger rangeToTrigger = newPitchStep - lastPitchStep;       //  0 - 35 = -35
            NSInteger absRangeToTrigger = labs(rangeToTrigger);             //  35
            bool isOnStep = (mzAttitude.yaw % self.step == 0); // yes
            bool stepForward;
            
            if (rangeToTrigger != 0 || isOnStep) {
                /// Fires
                /// Find a shortcut range if the old range
                if (absRangeToTrigger > totalSteps * 0.5 ) {
                    
                    rangeToTrigger = rangeToTrigger > 0 ? (rangeToTrigger - totalSteps) : (rangeToTrigger + totalSteps);
                    absRangeToTrigger = labs(rangeToTrigger);
                }
                
                stepForward = rangeToTrigger > 0;
                NSInteger lastFirePitch;
                
                for (int i = 1; i <= absRangeToTrigger ; i++) {
                    
                    if (stepForward) { /// is going Up ( counter-clockwise )
                        lastFirePitch = (lastPitchStep + i) * self.step;
                        lastFirePitch = lastFirePitch % 360;
                        
                    } else { /// is going Down ( clockwise )
                        lastFirePitch = (lastPitchStep - i + 1 ) * self.step;
                        if (lastFirePitch < 0) lastFirePitch = 360 + lastFirePitch;
                    }
                    
                    /// Fire
                    mzDeviceMotion.attitude = [MZAttitude new];
                    mzDeviceMotion.attitude.roll = self.lastFireAttitude.roll;
                    mzDeviceMotion.attitude.pitch = self.lastFireAttitude.pitch;
                    mzDeviceMotion.attitude.yaw = lastFirePitch;
                    /// BUG The next line of code is needed to avoid getting a large degree number that sometimes spawns in the sector 1
                    /// when rotating from a degree greater than 0 to 0. It should fire 0 but instead fires a large degree number.
                    if (mzDeviceMotion.attitude.yaw > 359 || mzDeviceMotion.attitude.yaw < 0) mzDeviceMotion.attitude.yaw = 0;
                    self.lastFireAttitude.yaw = mzDeviceMotion.attitude.yaw;
                    
                    mzDeviceMotion.rotationRate = deviceMotion.rotationRate;
                    mzDeviceMotion.gravity = deviceMotion.gravity;
                    mzDeviceMotion.userAcceleration = deviceMotion.userAcceleration;
                    
                    if ([self.delegate respondsToSelector:@selector(deviceMotionEngine:didDetectMotion:)] ) {
                        
                        [self.delegate deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
                    }
                    [self _deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
                }
                
                //self.lastFireAttitude.yaw = lastFirePitch;
                self.lastAttitude.yaw = mzAttitude.yaw;
                
            } else {
                /// If the angle is one of the steps fire it
                //if (mzAttitude.pitch % self.step == 0) self.lastFireAttitude.pitch = mzAttitude.pitch;
                //NSLog(@"INFO:RangeTrigger = 0");
            }
            
        }
        
        
    }
    
    /// This next (simple and very silly) example illustrates a use of CMAttitude’s rotationMatrix property. Our goal is to make a CALayer rotate in response to the current attitude of the device. We start as before, except that our reference frame is CMAttitudeReferenceFrameXArbitraryZVertical; we are interested in how the device moves from its initial attitude, without reference to any particular fixed external direction such as magnetic north. In pollAttitude, our first step is to store the device’s current attitude in a CMAttitude instance variable, ref:
    
    /* CMDeviceMotion* mot = self.motman.deviceMotion;
     CMAttitude* att = mot.attitude;
     if (!self.ref) {
     self.ref = att;
     return;
     }
     */
    /// That code works correctly because on the first few polls, as the attitude-detection hardware warms up, att is nil, so we don’t get past the return call until we have a valid initial attitude. Our next step is highly characteristic of how CMAttitude is used: we call the CMAttitude method multiplyByInverseOfAttitude:, which transforms our attitude so that it is relative to the stored initial attitude:
    
    // [att multiplyByInverseOfAttitude:self.ref];
    /// Finally, we apply the attitude’s rotation matrix directly to a layer in our interface as a transform. Well, not quite directly: a rotation matrix is a 3×3 matrix, whereas a CATransform3D, which is what we need in order to set a layer’s transform, is a 4×4 matrix. However, it happens that the top left nine entries in a CATransform3D’s 4×4 matrix constitute its rotation component, so we start with an identity matrix and set those entries directly:
    /*
     CMRotationMatrix r = att.rotationMatrix;
     CATransform3D t = CATransform3DIdentity;
     t.m11 = r.m11;
     t.m12 = r.m12;
     t.m13 = r.m13;
     t.m21 = r.m21;
     t.m22 = r.m22;
     t.m23 = r.m23;
     t.m31 = r.m31;
     t.m32 = r.m32;
     t.m33 = r.m33;
     CALayer* lay = // whatever;
     [CATransaction setDisableActions:YES];
     lay.transform = t;
     */
    
    /// The result is that the layer apparently tries to hold itself still as the device rotates. The example is rather crude because we aren’t using OpenGL to draw a three-dimensional object, but it illustrates the principle well enough.
    
    /// There is a quirk to be aware of in this case as well: over time, the transform has a tendency to drift. Thus, even if we leave the device stationary, the layer will gradually rotate. That is the sort of effect that CMAttitudeReferenceFrameXArbitraryCorrectedZVertical is designed to help mitigate, by bringing the magnetometer into play.
    
    /// Here are some additional considerations to be aware of when using Core Motion:
    
    /// The documentation warns that your app should create only one CMMotionManager instance. This is not a terribly onerous restriction, but it’s rather odd that, if this is important, the API doesn’t provide a shared singleton instance accessed through a class method.
    /// Use of Core Motion is legal while your app is running the background. To take advantage of this, your app would need to be running in the background for some other reason; there is no Core Motion UIBackgroundModes setting in an Info.plist. For example, you might run in the background because you’re using Core Location, and take advantage of this to employ Core Motion as well.
    /// Core Motion requires that various sensors be turned on, such as the magnetometer and the gyroscope. This can result in some increased battery drain, so try not to use any sensors you don’t have to, and remember to stop generating updates as soon as you no longer need them.
    
}

- (MZAttitude *) convertAttitudeRadiansToDegreesFromDeviceMotion:(CMDeviceMotion *) deviceMotion{
    
    CMAcceleration g = deviceMotion.gravity; // NSLog(@"Pitch is tilted %@", g.z > 0 ? @"forward" : @"back");
    
    CGFloat to_degree = 180 / M_PI;
    
    MZAttitude *mzAttitude = [MZAttitude new];
    
    mzAttitude.roll =  round(deviceMotion.attitude.roll * to_degree);
    mzAttitude.pitch = round(deviceMotion.attitude.pitch * to_degree);
    mzAttitude.yaw = round(deviceMotion.attitude.yaw * to_degree);
    
    /// Transform Roll in 0 - 359 degrees range
    if (mzAttitude.roll < 0) {
        mzAttitude.roll = 360 + mzAttitude.roll;
    }
    
    /// Transform Pitch in 0 - 359 degrees range
    if (mzAttitude.pitch < 0 && g.z < 0 ) {                   ///  _|_
                                                              ///   |\
        mzAttitude.pitch = mzAttitude.pitch;
        mzAttitude.pitch = 360 + mzAttitude.pitch;
        
    } else if (mzAttitude.pitch < 0 && g.z >= 0 ) {           ///  _|_
                                                              ///  /|
        mzAttitude.pitch = -90 - (90 + mzAttitude.pitch);
        mzAttitude.pitch = 360 + mzAttitude.pitch;
        
    } else if (mzAttitude.pitch >= 0 && g.z < 0 ) {           ///  _\|_
                                                              ///    |
        mzAttitude.pitch = mzAttitude.pitch;
        
    } else if (mzAttitude.pitch >= 0 && g.z >= 0 ) {           ///  _|/_
                                                               ///   |
        mzAttitude.pitch = 90 + (90 - mzAttitude.pitch);
    }
    
    /// Transform Yaw in 0 - 359 degrees range
    if (mzAttitude.yaw < 0) {
        mzAttitude.yaw = 360 + mzAttitude.yaw;
    }
    
    return mzAttitude;
}

- (void) checkFireOnTriggerForAxis:(FireOnTriggerAxis) axis attitude:(MZAttitude *)mzAttitude {
    
    NSInteger totalSteps = 360/self.step;
    NSInteger lastAttitudeAxis = 0;
    NSInteger attitudeAxis = 0;
    
    if (axis == FireOnTriggerAxisRoll) {
        
        lastAttitudeAxis = self.lastAttitude.roll;
        attitudeAxis = mzAttitude.roll;
        
    } else if (axis == FireOnTriggerAxisPitch) {
        
        lastAttitudeAxis = self.lastAttitude.pitch;
        attitudeAxis = mzAttitude.pitch;
        
    } else if (axis == FireOnTriggerAxisYaw) {
        
        lastAttitudeAxis = self.lastAttitude.yaw;
        attitudeAxis = mzAttitude.yaw;
    }
    
    /// Check which step area corresponds the new attitude
    NSInteger lastAxisStep = lastAttitudeAxis / self.step;         //  359 35
    NSInteger newAxisStep = attitudeAxis / self.step;         //  0    0
    
    NSInteger rangeToTrigger = newAxisStep - lastAxisStep;       //  0 - 35 = -35
    NSInteger absRangeToTrigger = labs(rangeToTrigger);             //  35
    
    bool isOnStep = (attitudeAxis % self.step == 0);
    bool stepForward;
    
    CMDeviceMotion* deviceMotion = self.motionManager.deviceMotion;
    MZDeviceMotion *mzDeviceMotion = [MZDeviceMotion new];
    
    if (rangeToTrigger != 0 || isOnStep) {
        /// Fires
        /// Find a shortcut range if the old range
        if (absRangeToTrigger > totalSteps * 0.5 ) {
            
            rangeToTrigger = rangeToTrigger > 0 ? (rangeToTrigger - totalSteps) : (rangeToTrigger + totalSteps);
            absRangeToTrigger = labs(rangeToTrigger);
        }
        
        stepForward = rangeToTrigger > 0;
        NSInteger lastFireAxis;
        
        for (int i = 1; i <= absRangeToTrigger ; i++) {
            
            if (stepForward) { /// is going Up ( counter-clockwise )
                lastFireAxis = (lastAxisStep + i) * self.step;
                lastFireAxis = lastFireAxis % 360;
                
            } else { /// is going Down ( clockwise )
                lastFireAxis = (lastAxisStep - i + 1 ) * self.step;
                if (lastFireAxis < 0) lastFireAxis = 360 + lastFireAxis;
            }
            
            /// Fire
            mzDeviceMotion.attitude = [MZAttitude new];
            mzDeviceMotion.attitude.roll = self.lastFireAttitude.roll;
            mzDeviceMotion.attitude.pitch = self.lastFireAttitude.pitch;
            mzDeviceMotion.attitude.yaw = self.lastFireAttitude.yaw;
            
            if      (axis == FireOnTriggerAxisRoll)   mzDeviceMotion.attitude.roll = lastFireAxis;
            else if (axis == FireOnTriggerAxisPitch)  mzDeviceMotion.attitude.pitch = lastFireAxis;
            else                                      mzDeviceMotion.attitude.yaw = lastFireAxis;
            
            mzDeviceMotion.rotationRate = deviceMotion.rotationRate;
            mzDeviceMotion.gravity = deviceMotion.gravity;
            mzDeviceMotion.userAcceleration = deviceMotion.userAcceleration;
            
            if ([self.delegate respondsToSelector:@selector(deviceMotionEngine:didDetectMotion:)] ) {
                
                [self.delegate deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
            }
            [self _deviceMotionEngine:self didDetectMotion:mzDeviceMotion];
            
        }
        
        if (axis == FireOnTriggerAxisRoll) {
            
            self.lastFireAttitude.roll = lastAttitudeAxis;
            self.lastAttitude.roll = attitudeAxis;
            
        } else if (axis == FireOnTriggerAxisPitch) {
            
            self.lastFireAttitude.pitch = lastAttitudeAxis;
            self.lastAttitude.pitch = attitudeAxis;
            
        } else if (axis == FireOnTriggerAxisYaw) {
            
            self.lastFireAttitude.yaw = lastAttitudeAxis;
            self.lastAttitude.yaw = attitudeAxis;
        }
        
    } else {
        /// If the angle is one of the steps fire it
        //if (mzAttitude.pitch % self.step == 0) self.lastFireAttitude.pitch = mzAttitude.pitch;
        //NSLog(@"INFO:RangeTrigger = 0");
    }
}

//////////////////////////////////////////////////////////////////////////
/// DeviceVolume Component Delegate Methods
//////////////////////////////////////////////////////////////////////////
-(void)_deviceMotionEngine:(MZDeviceMotionEngine *)deviceMotionEngine didDetectMotion:(MZDeviceMotion *)deviceMotion
{
    NSString *widget = @"";
    NSString *component = @"deviceMotion";
    NSMutableDictionary *value = [NSMutableDictionary new];
    NSString *event = @"attitude";
    
    if (deviceMotionEngine.rollActive) {
        [value setObject:[NSNumber numberWithDouble: deviceMotion.attitude.roll] forKey:@"roll"];
    }
    if (deviceMotionEngine.pitchActive) {
        [value setObject:[NSNumber numberWithDouble: deviceMotion.attitude.pitch] forKey:@"pitch"];
    }
    if (deviceMotionEngine.yawActive) {
        [value setObject:[NSNumber numberWithDouble: deviceMotion.attitude.yaw] forKey:@"yaw"];
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:nil];
}
@end
