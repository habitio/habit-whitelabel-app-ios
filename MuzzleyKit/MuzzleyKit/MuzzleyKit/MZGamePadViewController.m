//
//  MZGamePadViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 07/12/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZGamePadViewController.h"
#import "MZJoystickViewController.h"

#import "MZUserClient.h"

@interface MZGamePadViewController () <UIGestureRecognizerDelegate>

// Input types
@property (nonatomic, strong) IBOutlet UIButton *buttonA;
@property (nonatomic, strong) IBOutlet UIButton *buttonB;
@property (nonatomic, strong) IBOutlet UIButton *buttonC;
@property (nonatomic, strong) IBOutlet UIButton *buttonD;

@property (nonatomic, strong) MZJoystickViewController *joystickLeft;

// Private IBOutlets
@property (nonatomic, strong) IBOutlet UIButton *buttonABig;
@property (nonatomic, strong) IBOutlet UIButton *buttonBBig;

@property (nonatomic, strong) IBOutlet UIImageView *buttonBigBevel;
@property (nonatomic, strong) IBOutlet UIImageView *buttonABevel;
@property (nonatomic, strong) IBOutlet UIImageView *buttonBBevel;
@property (nonatomic, strong) IBOutlet UIImageView *buttonCBevel;
@property (nonatomic, strong) IBOutlet UIImageView *buttonDBevel;

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

// Only one touch down can activate the joystick movement.
@property (nonatomic, strong) UITouch *joystickLeftAreaTouch;

// private signaling mzmessage for communication with activity
@property (nonatomic, strong) MZMessage *messageSignaling;

@end


#pragma mark - Options dictionary's constant keys
NSString *const kMZGamePadOptionSector = @"sector";
NSString *const kMZGamePadOptionIntensitySteps = @"intensitySteps";
NSString *const kMZGamePadOptionNumberOfButtons = @"numButtons";


@implementation MZGamePadViewController

@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;

- (void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
    
    self.delegate = nil;
}

#pragma mark - Initializers
- (id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZGamePadViewController *gamePadViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZGamePadViewController"];
    self = gamePadViewController;
    
    if (self) {
        self.parameters = parameters;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Configuring Joystick ////////////////////////////////////////////////////

    NSNumber *sectorNumber = self.parameters[kMZGamePadOptionSector];
    if (sectorNumber && [sectorNumber isKindOfClass:[NSNumber class]]) {
    } else
        sectorNumber = @45;
    
    NSNumber *intensityStepsNumber = self.parameters[kMZGamePadOptionIntensitySteps];
    if (intensityStepsNumber && [intensityStepsNumber isKindOfClass:[NSNumber class]]) {
    } else
        intensityStepsNumber = @0;
    
    self.joystickLeft = [[MZJoystickViewController alloc] initWithParameters:
                         @{
                            kMZJoystickOptionSector: sectorNumber,
                            kMZJoystickOptionIntensitySteps: intensityStepsNumber
                         }];
    
    self.joystickLeft.delegate = self;
    
    self.joystickLeft.view.frame = CGRectMake(0,0,
                                              self.joystickLeft.markingsView.frame.size.width,
                                              self.joystickLeft.markingsView.frame.size.height);
    
    [self.view addSubview: self.joystickLeft.view];
    
    // Configuring Buttons.
    NSInteger numButtons = [self.parameters[kMZGamePadOptionNumberOfButtons] integerValue];
    
    if (numButtons == 1) {
        self.type = MZGamePadTypeOneButton;
    } else if (numButtons == 2) {
        self.type = MZGamePadTypeTwoButtons;
    } else if (numButtons == 3) {
        self.type = MZGamePadTypeThreeButtons;
    } else if (numButtons == 4) {
        self.type = MZGamePadTypeFourButtons;
    } else {
        self.type = MZGamePadTypeFourButtons;
    }
    
    // Hook up gesture recognizers.
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handlePanGesture:)];
    self.panRecognizer.delegate = self;
    
    NSArray *gestureRecognizers = [NSArray arrayWithObjects:self.panRecognizer,nil];
    [self.view setGestureRecognizers:gestureRecognizers];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self resetJoystickPosition:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetJoystickPosition:NO];
    
        switch (self.type) {
        case MZGamePadTypeOneButton:
            self.buttonA.hidden = true;
            self.buttonABevel.hidden = true;
            self.buttonB.hidden = true;
            self.buttonBBevel.hidden = true;
            self.buttonC.hidden = true;
            self.buttonCBevel.hidden = true;
            self.buttonD.hidden = true;
            self.buttonDBevel.hidden = true;
            
            self.buttonABig.hidden = false;
            self.buttonBBig.hidden = false;
            self.buttonBigBevel.hidden = false;
            
            break;
        case MZGamePadTypeTwoButtons:
            self.buttonA.hidden = true;
            self.buttonABevel.hidden = true;
            self.buttonB.hidden = true;
            self.buttonBBevel.hidden = true;
            self.buttonC.hidden = true;
            self.buttonCBevel.hidden = true;
            self.buttonD.hidden = true;
            self.buttonDBevel.hidden = true;
            
            self.buttonABig.hidden = false;
            self.buttonBBig.hidden = false;
            self.buttonBigBevel.hidden = false;
            
            break;
        case MZGamePadTypeThreeButtons:
            self.buttonA.hidden = false;
            self.buttonABevel.hidden = false;
            self.buttonB.hidden = false;
            self.buttonBBevel.hidden = false;
            self.buttonC.hidden = false;
            self.buttonCBevel.hidden = false;
            self.buttonD.hidden = false;
            self.buttonDBevel.hidden = false;
            
            self.buttonABig.hidden = true;
            self.buttonBBig.hidden = true;
            self.buttonBigBevel.hidden = true;
            break;
        case MZGamePadTypeFourButtons:
            self.buttonA.hidden = false;
            self.buttonABevel.hidden = false;
            self.buttonB.hidden = false;
            self.buttonBBevel.hidden = false;
            self.buttonC.hidden = false;
            self.buttonCBevel.hidden = false;
            self.buttonD.hidden = false;
            self.buttonDBevel.hidden = false;
            
            self.buttonABig.hidden = true;
            self.buttonBBig.hidden = true;
            self.buttonBigBevel.hidden = true;
            break;
        default:
            break;
    }
}
#pragma mark - View Rotation
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
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark - Joystick interaction lifecycle

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view == self.buttonA || touch.view == self.buttonB ||
        touch.view == self.buttonC || touch.view == self.buttonD ||
        touch.view == self.buttonABig || touch.view == self.buttonBBig) {
       
        return NO;
    }
    
    // Should receive touch only in the left side of the screen.
    CGPoint point = [touch locationInView:self.view];
    if (point.x >= self.view.bounds.size.width/2) {
         NSLog(@"point.x >=");
        return NO;
    }
    
    if (self.joystickLeftAreaTouch) {
        NSLog(@"!joystickAreaTouch");
       return NO;
    }
    
    float minMargin = 6.0;
    float joystickHalfWidth = self.joystickLeft.view.frame.size.width/2;
    float joystickHalfHeight = joystickHalfWidth;
    
    float newX = MIN(MAX(minMargin + joystickHalfWidth, point.x),
                     self.view.bounds.size.width/2 - joystickHalfWidth - minMargin);
    
    float newY = MIN(MAX(minMargin + joystickHalfHeight, point.y),
                     self.view.bounds.size.height - joystickHalfHeight - minMargin);
    
    point = CGPointMake(newX, newY);
    
    self.joystickLeftAreaTouch = touch;
    
    [UIView animateWithDuration:0.1 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState |
                                UIViewAnimationOptionCurveEaseOut |
                                UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         
                         self.joystickLeft.view.alpha = 1;
                         self.joystickLeft.view.center = point;
                         
                     } completion:^(BOOL finished) {}];
    
    
    
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.joystickLeft.view.alpha = 1;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            self.joystickLeft.view.alpha = 1;
            
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            [self.joystickLeft setThumbPadTranslation:translation];
            /// reset translation
            [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            self.joystickLeftAreaTouch = nil;
            
            [self.joystickLeft resetThumbPadPosition];
            [self resetJoystickPosition:YES];
            
            [self joystickController:self.joystickLeft
                           didRotate:-1
                           intensity:0];
            break;
        }
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches]) {
        if (touch == self.joystickLeftAreaTouch) {
            
            self.joystickLeftAreaTouch = nil;
            
            [self resetJoystickPosition:YES];
            
            break;
        } else {
            NSLog(@"touch != self.areaTouch");
        }
    }
}

-(void)resetJoystickPosition:(BOOL)animated
{
    float minMargin = 6.0;
    
    if (animated) {
        
        [UIView animateWithDuration:0.1 delay:0
            options:UIViewAnimationOptionBeginFromCurrentState |
                    UIViewAnimationOptionCurveEaseOut |
                    UIViewAnimationOptionAllowUserInteraction
            animations:^{
                self.joystickLeft.view.alpha = 0.5;
                
                self.joystickLeft.view.center =
                CGPointMake(self.joystickLeft.view.frame.size.width/2 + minMargin,
                            self.view.bounds.size.height - (self.joystickLeft.view.frame.size.height * 0.5) - (minMargin *10));
                             
            }
            completion:^(BOOL finished) {}];
    }
    else {
        self.joystickLeft.view.alpha = 0.5;
        
        self.joystickLeft.view.center =
        CGPointMake(self.joystickLeft.view.frame.size.width/2 + minMargin,
                    self.view.bounds.size.height - (self.joystickLeft.view.frame.size.height * 0.5) - (minMargin*10));
    }
}

#pragma mark - Quit Activity flow
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    } else {
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)])
            [self.delegate widgetNeedsToDismiss:self];
    }
}

#pragma mark - IBAction Button Delegate calls
- (IBAction)touchDown:(id)sender {
    
    UIButton *newSender;
    if (sender == self.buttonABig) {
        newSender = self.buttonA;
    } else if(sender == self.buttonBBig) {
        newSender = self.buttonB;
    } else {
        newSender = sender;
    }
    
    [self _buttonTouchDown:newSender];
}

- (IBAction)touchUp:(id)sender {
    
    UIButton *newSender;
    if (sender == self.buttonABig) {
        newSender = self.buttonA;
    } else if(sender == self.buttonBBig) {
        newSender = self.buttonB;
    } else {
        newSender = sender;
    }
    
    [self _buttonTouchUp:newSender];
}

#pragma mark - Joystick Delegate
- (void)joystickController:(MZJoystickViewController *)joystick
                 didRotate:(CGFloat)degrees
                 intensity:(CGFloat)intensity
{
    NSString *widget = @"gamepad";
    NSString *component;
    
    NSString *event = @"press";
    
    if (joystick == self.joystickLeft) {
        component = @"jl";
    }
    
    if (degrees == -1) {
        event = @"release";
    }
    
    id value;
    
    if (self.parameters[kMZGamePadOptionIntensitySteps]) {
        value = [NSMutableDictionary new];
        [value setObject:[NSNumber numberWithInteger:degrees] forKey:@"a"];
        [value setObject:[NSNumber numberWithFloat:intensity] forKey:@"i"];
    }
    else {
        value = [NSString stringWithFormat:@"%ld",(long)degrees];
    }
    
    NSDictionary *data = @{
                           @"w": widget,
                            @"c": component,
                            @"v": value,
                            @"e": event
                           };
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal
                                          data:data completion:nil];
}

#pragma mark - Activity Communication Signaling 
-(void)_buttonTouchDown:(UIButton *)button
{
    
    NSString *widget = @"gamepad";
    NSString *component;
    NSString *value = @"";
    NSString *event = @"press";
    
    if (button == self.buttonA) {
        component = @"ba";
        value = @"a";
    }else if (button == self.buttonB){
        component = @"bb";
        value = @"b";
    }else if (button == self.buttonC){
        component = @"bc";
        value = @"c";
    }else if (button == self.buttonD){
        component = @"bd";
        value = @"d";
    }

    NSDictionary *data = @{
                           @"w": widget,
                           @"c": component,
                           @"v": value,
                           @"e": event
                           };

    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal
                                          data:data completion:nil];
    
}

-(void)_buttonTouchUp:(UIButton *)button
{
    
    NSString *widget = @"gamepad";
    NSString *component;
    NSString *value = @"";
    NSString *event = @"release";
    
    if (button == self.buttonA) {
        component = @"ba";
        value = @"a";
    }else if (button == self.buttonB){
        component = @"bb";
        value = @"b";
    }else if (button == self.buttonC){
        component = @"bc";
        value = @"c";
    }else if (button == self.buttonD){
        component = @"bd";
        value = @"d";
    }
    
    NSDictionary *data = @{
                           @"w": widget,
                           @"c": component,
                           @"v": value,
                           @"e": event
                           };
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal
                                          data:data completion:nil];
}

@end