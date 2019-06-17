//
//  MZJoystickViewController.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 27/01/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZJoystickViewController.h"

// Options dictionary's constant keys
NSString *const kMZJoystickOptionSector = @"sector";
NSString *const kMZJoystickOptionIntensitySteps = @"intensitySteps";




@interface MZJoystickViewController ()

@property (nonatomic, strong, readwrite) NSDictionary *parameters;

@property (nonatomic, strong) IBOutlet UIImageView *thumbPadView;
@property (nonatomic, strong) IBOutlet UIImageView *thumbPadShadowView;
@property (nonatomic, strong) IBOutlet UIImageView *circularTrackView;
@property (nonatomic, strong) IBOutlet UIImageView *markingsView;

@property (nonatomic, assign) CGFloat lastDegreeAngle;
@property (nonatomic, assign) CGFloat lastIntensity;

@property (nonatomic, assign) CGFloat RADIUS_RANGE_MIN;
@property (nonatomic, assign) CGFloat RADIUS_RANGE_MAX;
@property (nonatomic, assign) CGFloat RADIUS_DISTANCE_MIN;
@property (nonatomic, assign) CGFloat RADIUS_DISTANCE_MAX;


//@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@property (nonatomic, assign) CGFloat sector;
@property (nonatomic, assign) NSInteger intensitySteps;

//- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer;

@end




@implementation MZJoystickViewController

@synthesize thumbPadView;
@synthesize thumbPadShadowView;
@synthesize circularTrackView;
@synthesize markingsView;

-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZJoystickViewController *joystickViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZJoystickViewController"];
    self = joystickViewController;
    
    if (self) {
        self.parameters = parameters;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Hook up gesture recognizers.
    //self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector( _handlePanGesture:)];
    
    //self.panRecognizer.minimumNumberOfTouches = 1;
    //self.panRecognizer.maximumNumberOfTouches = 1;
    
    //NSArray *gestureRecognizers = [NSArray arrayWithObjects:self.panRecognizer,nil];
    //[self.view setGestureRecognizers:gestureRecognizers];
    
    // The property lastDegreeAngle stores the previous degree angle so we can know if the joystick entered a new degree angle area.
    self.lastDegreeAngle = -1;
    
    // Configure radius range
    /*
     * The minimum and maximum range limit can be customized. All intensity calculations will be derived from this 2 values.
     *
     *           0.1              0.85
     *  Radius: __|________________|__
     */
    self.RADIUS_RANGE_MIN = 0.1;
    self.RADIUS_RANGE_MAX = 0.85;
  
    self.RADIUS_DISTANCE_MIN = 0;
    self.RADIUS_DISTANCE_MAX = 0;
    
    // The property step stores the value of each degree angle area that represents a joystick 'direction'.
    self.sector = [self validateSector: self.parameters[kMZJoystickOptionSector]];
    self.intensitySteps = [self validateIntensitySteps: self.parameters[kMZJoystickOptionIntensitySteps]];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
}

#pragma mark View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Panning
- (void)setThumbPadTranslation:(CGPoint)translation
{
    /// Tan(angle) = Opposite / Adjacent
    /// Sin(angle) = Opposite / Hypotenuse
    /// Cos(angle) = Adjacent / Hypotenuse
    
    CGFloat radius = self.circularTrackView.bounds.size.width/2 -
    self.thumbPadView.bounds.size.width/2;
    
    self.RADIUS_DISTANCE_MAX = radius * self.RADIUS_RANGE_MAX;
    self.RADIUS_DISTANCE_MIN = radius * self.RADIUS_RANGE_MIN;
    
    /// Calculate the angle of any touch relative to the center of the joystick
    CGFloat dx = self.thumbPadView.center.x - self.circularTrackView.center.x;
    CGFloat dy = self.thumbPadView.center.y - self.circularTrackView.center.y;
    CGFloat deltaAngleRad = atan2f(dy, dx);
    CGFloat deltaAngleDegree = deltaAngleRad * (180/M_PI);
    
    /// Update views position with relative translation
    self.thumbPadView.center = CGPointMake(self.thumbPadView.center.x + translation.x,
                                           self.thumbPadView.center.y + translation.y);
    
    self.thumbPadShadowView.center = CGPointMake(self.thumbPadView.center.x,
                                                 self.thumbPadView.center.y + 20);
    
    
    /*
     *  Calculate if thumbPad center point is inside a circle
     *
     *  (x - center_x)^2 + (y - center_y)^2 < radius^2  #Inside the circle
     */
    
    CGFloat point = sqrtf(
                          powf(self.thumbPadView.center.x - self.circularTrackView.center.x, 2) +
                          powf(self.thumbPadView.center.y - self.circularTrackView.center.y, 2));
    
    /// Draw thumbpad in the perimeter of the circle
    if (point > self.RADIUS_DISTANCE_MAX) {
        
        /// Calculate the angle of any touch relative to the center of the joystick
        CGFloat dx = self.thumbPadView.center.x - self.circularTrackView.center.x;
        CGFloat dy = self.thumbPadView.center.y - self.circularTrackView.center.y;
        CGFloat deltaAngleRad = atan2f(dy, dx);
        
        /// x = Cos(angle) * radius + CenterX;
        /// Y = Sin(angle) * radius + CenterY;
        CGFloat px = cosf(deltaAngleRad) * self.RADIUS_DISTANCE_MAX + self.circularTrackView.center.x;
        CGFloat py = sinf(deltaAngleRad) * self.RADIUS_DISTANCE_MAX + self.circularTrackView.center.y;
        
        /// Update views position
        self.thumbPadView.center = CGPointMake(px, py);
        
        self.thumbPadShadowView.center = CGPointMake(self.thumbPadView.center.x,
                                                     self.thumbPadView.center.y + 20);
    }
    
    point = sqrtf(
                  powf(self.thumbPadView.center.x - self.circularTrackView.center.x, 2) +
                  powf(self.thumbPadView.center.y - self.circularTrackView.center.y, 2));
    
    if (point > self.RADIUS_DISTANCE_MIN) {
        
        /// Calculate an intensity value based on a minimum and maximum point in the radius of the joystick
        /*
         * R:  .___|_________________|__.
         *    0   0.2               0.8  1
         *
         * I:      0-----------------1
         *
         * R: Radius value
         * I: Intensity value
         */
        CGFloat newIntensity = [self intensityForRadiusPoint:point
                                      radiusMinDistancePoint:self.RADIUS_DISTANCE_MIN
                                      radiusMaxDistancePoint:self.RADIUS_DISTANCE_MAX];
        
        /// Convert the intensity value on a relative one based on the parameter intensitySteps
        /*
         * Ex: intensitySteps = 4 steps
         * Input intensity:0.4
         *
         * R: ._____._____._____._____.
         *      0.25  0.5   0.75   1
         *
         * Output intensity: 0.5
         */
        
        newIntensity = [self convertToRelativeIntensityStep:newIntensity
                                                      steps:self.intensitySteps];
        
        /// Convert the degree angle on a relative sector degree angle
        /* The joystick circle is divided in equal sectors based on the parameter sector.
         Each sector's degree angle center alignment corresponds to a multiple of sector value in the circle.
         The relative angle degree is calculated based on if the degree angle is inside the sector area.
         *
         * Read: http://en.wikipedia.org/wiki/Circular_sector
         *
         * Ex: Sector = 90
         *     Input angle degree = 40
         *     90
         *     |        45
         *     |      -
         *     |   -
         *     | -
         *     |---------- 0
         | -
         *     |   -
         *     |      -
         *     |        315
         *    270
         */
        deltaAngleDegree = [self convertToRelativeAngleDegree:deltaAngleDegree
                                                       sector:self.sector];
        
        
        /// Foward calls to the delegate if it's a new relative angle degree or a new intensity
        if ( self.lastDegreeAngle != deltaAngleDegree ||
            self.lastIntensity != newIntensity) {
            
            self.lastDegreeAngle = deltaAngleDegree;
            self.lastIntensity = newIntensity;
            
            /// Delegate Joystick rotation
            if ([self.delegate respondsToSelector:@selector(joystickController:didRotate:intensity:)]) {
                [self.delegate joystickController:self
                                        didRotate:deltaAngleDegree
                                        intensity:newIntensity];
            }
        }
    }
}

- (void)resetThumbPadPosition
{
    self.thumbPadView.center = CGPointMake(self.view.bounds.size.width/2,
                                           self.view.bounds.size.height/2);
    self.thumbPadShadowView.center =
    CGPointMake(self.thumbPadView.center.x,
                self.thumbPadView.center.y + 20);
    
    /// Default value when the thumbpad is in the center of the joystick.
    self.lastDegreeAngle = -1;
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            panGestureRecognizer.minimumNumberOfTouches = 0;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            /// Tan(angle) = Opposite / Adjacent
            /// Sin(angle) = Opposite / Hypotenuse
            /// Cos(angle) = Adjacent / Hypotenuse
            
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            
            CGFloat radius = self.circularTrackView.bounds.size.width/2 -
                             self.thumbPadView.bounds.size.width/2;
            
            self.RADIUS_DISTANCE_MAX = radius * self.RADIUS_RANGE_MAX;
            self.RADIUS_DISTANCE_MIN = radius * self.RADIUS_RANGE_MIN;
            
            /// Calculate the angle of any touch relative to the center of the joystick
            CGFloat dx = self.thumbPadView.center.x - self.circularTrackView.center.x;
            CGFloat dy = self.thumbPadView.center.y - self.circularTrackView.center.y;
            CGFloat deltaAngleRad = atan2f(dy, dx);
            CGFloat deltaAngleDegree = deltaAngleRad * (180/M_PI);
            
            /// Update views position with relative translation
            self.thumbPadView.center = CGPointMake(self.thumbPadView.center.x + translation.x,
                                                   self.thumbPadView.center.y + translation.y);
            
            self.thumbPadShadowView.center = CGPointMake(self.thumbPadView.center.x,
                                                         self.thumbPadView.center.y + 20);
            
            
            /*
             *  Calculate if thumbPad center point is inside a circle
             *
             *  (x - center_x)^2 + (y - center_y)^2 < radius^2  #Inside the circle
             */
            
            CGFloat point = sqrtf(
                                  powf(self.thumbPadView.center.x - self.circularTrackView.center.x, 2) +
                                  powf(self.thumbPadView.center.y - self.circularTrackView.center.y, 2));
            
            /// Draw thumbpad in the perimeter of the circle
            if (point > self.RADIUS_DISTANCE_MAX) {
                
                /// Calculate the angle of any touch relative to the center of the joystick
                CGFloat dx = self.thumbPadView.center.x - self.circularTrackView.center.x;
                CGFloat dy = self.thumbPadView.center.y - self.circularTrackView.center.y;
                CGFloat deltaAngleRad = atan2f(dy, dx);
                
                /// x = Cos(angle) * radius + CenterX;
                /// Y = Sin(angle) * radius + CenterY;
                CGFloat px = cosf(deltaAngleRad) * self.RADIUS_DISTANCE_MAX + self.circularTrackView.center.x;
                CGFloat py = sinf(deltaAngleRad) * self.RADIUS_DISTANCE_MAX + self.circularTrackView.center.y;
                
                /// Update views position
                self.thumbPadView.center = CGPointMake(px, py);
                
                self.thumbPadShadowView.center = CGPointMake(self.thumbPadView.center.x,
                                                             self.thumbPadView.center.y + 20);
            }
            
            point = sqrtf(
                          powf(self.thumbPadView.center.x - self.circularTrackView.center.x, 2) +
                          powf(self.thumbPadView.center.y - self.circularTrackView.center.y, 2));
         
            if (point > self.RADIUS_DISTANCE_MIN) {
                
                /// Calculate an intensity value based on a minimum and maximum point in the radius of the joystick
                /*
                 * R:  .___|_________________|__.
                 *    0   0.2               0.8  1
                 *
                 * I:      0-----------------1
                 *
                 * R: Radius value
                 * I: Intensity value
                 */
                CGFloat newIntensity = [self intensityForRadiusPoint:point
                                              radiusMinDistancePoint:self.RADIUS_DISTANCE_MIN
                                              radiusMaxDistancePoint:self.RADIUS_DISTANCE_MAX];
                
                /// Convert the intensity value on a relative one based on the parameter intensitySteps
                /* 
                 * Ex: intensitySteps = 4 steps
                 * Input intensity:0.4
                 *
                 * R: ._____._____._____._____.
                 *      0.25  0.5   0.75   1
                 *
                 * Output intensity: 0.5
                 */
                
                newIntensity = [self convertToRelativeIntensityStep:newIntensity
                                                              steps:self.intensitySteps];
                
                /// Convert the degree angle on a relative sector degree angle
                /* The joystick circle is divided in equal sectors based on the parameter sector.
                   Each sector's degree angle center alignment corresponds to a multiple of sector value in the circle.
                 The relative angle degree is calculated based on if the degree angle is inside the sector area.
                 *
                 * Read: http://en.wikipedia.org/wiki/Circular_sector
                 *
                 * Ex: Sector = 90
                 *     Input angle degree = 40
                 *     90
                 *     |        45
                 *     |      -
                 *     |   -
                 *     | -
                 *     |---------- 0
                       | -
                 *     |   -
                 *     |      -
                 *     |        315
                 *    270
                 */
                deltaAngleDegree = [self convertToRelativeAngleDegree:deltaAngleDegree
                                                                 sector:self.sector];
                
                
                /// Foward calls to the delegate if it's a new relative angle degree or a new intensity
                if ( self.lastDegreeAngle != deltaAngleDegree ||
                     self.lastIntensity != newIntensity) {
                    
                    self.lastDegreeAngle = deltaAngleDegree;
                    self.lastIntensity = newIntensity;
                
                    /// Delegate Joystick rotation
                    if ([self.delegate respondsToSelector:@selector(joystickController:didRotate:intensity:)]) {
                        [self.delegate joystickController:self
                                                didRotate:deltaAngleDegree
                                                intensity:newIntensity];
                    }
                }
            }
            
            /// reset translation
            [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            panGestureRecognizer.minimumNumberOfTouches = 1;
            
            self.thumbPadView.center = CGPointMake(self.view.bounds.size.width/2,
                                                   self.view.bounds.size.height/2);
            self.thumbPadShadowView.center =
            CGPointMake(self.thumbPadView.center.x,
                        self.thumbPadView.center.y + 20);
            
            /// Delegate Joystick rotation
            if ([self.delegate respondsToSelector:@selector(joystickController:didRotate:intensity:)]) {
                [self.delegate joystickController:self
                                        didRotate:-1
                                        intensity:0];
            }
            
            /// Default value when the thumbpad is in the center of the joystick.
            self.lastDegreeAngle = -1;
            
            break;
        }
        default:
            break;
    }
}

- (CGFloat)roundWithDecimals:(NSInteger)decimals num:(CGFloat)num
{
    int tenpow = 1;
    for (; decimals; tenpow *= 10, decimals--);
    return round(tenpow * num) / tenpow;
}

- (CGFloat)validateSector:(NSNumber *)number {
    
    CGFloat sector = 1;
    if (number && [number isKindOfClass:[NSNumber class]]) {
        // The step cannot be lower than 1.
        sector = number.floatValue >= 1.0 ? number.floatValue : 45;
    } else
        sector = 45;
    return sector;
}

- (CGFloat)validateIntensitySteps:(NSNumber *)number {
    
    CGFloat intensitySteps = 0;
    if (number && [number isKindOfClass:[NSNumber class]]) {
       
        intensitySteps = number.integerValue >= 0 ? number.integerValue : 0;
    } else
        intensitySteps = 0;
    return intensitySteps;
}


- (CGFloat)intensityForRadiusPoint:(CGFloat)point
            radiusMinDistancePoint:(CGFloat)radiusMinDistancePoint
            radiusMaxDistancePoint:(CGFloat)radiusMaxDistancePoint
{
    return (point - radiusMinDistancePoint)/(radiusMaxDistancePoint - radiusMinDistancePoint);
}

- (CGFloat)convertToRelativeAngleDegree:(CGFloat)angleDegree sector:(CGFloat)sector
{
    /// Convert to a 0 - 360 degrees format.
    if (angleDegree > 0.0f)
        angleDegree = 360 - angleDegree;
    else
        angleDegree = angleDegree * -1;
    
    /// Shift half the self.step value to create an area around each multiple step value.
    CGFloat angleDegreeRelative = angleDegree - sector/2;
    
    /// Convert the absolute angle degree into the related area angle degree.
    angleDegreeRelative = round( (angleDegreeRelative + (sector/2) ) / sector) * sector;
    if (angleDegreeRelative == 360)
        angleDegreeRelative = 0;
    
    /// Convert to an absolute value.
    angleDegreeRelative = fabs(angleDegreeRelative);
    //NSLog(@"%.2f(%.2f)",angleDegreesRelative, angleDegrees);
    return angleDegreeRelative;
}

- (CGFloat)convertToRelativeIntensityStep:(CGFloat)intensityStep steps:(CGFloat)steps
{
    CGFloat relativeIntensityStep = 0;
    if (intensityStep > 1.0)
        intensityStep = 1.0;
    
    if (steps > 0) {
    
        CGFloat stepArea = 1/steps;
        NSUInteger idx;
        
        for (idx = 1; idx <= steps; idx++) {
            if( intensityStep <= idx * stepArea ) {
                relativeIntensityStep = idx * stepArea;
                break;
            }
        }
    }
    //NSLog(@"%f (%f)", 1.0, relativeIntensityStep);
    return relativeIntensityStep;
}
@end
