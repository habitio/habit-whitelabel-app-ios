//
//  MZJoystickViewController.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 27/01/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZJoystickViewController;

@protocol MZJoystickDelegate <NSObject>
@optional
/** Sent to receiver after direction was performed. */
- (void) joystickController:(MZJoystickViewController *)joystick
                  didRotate:(CGFloat)degrees
                  intensity:(CGFloat)intensity;

@end




// Options dictionary's constant keys
extern NSString *const kMZJoystickOptionSector;
extern NSString *const kMZJoystickOptionIntensitySteps;

@interface MZJoystickViewController : UIViewController

@property (nonatomic, strong, readonly) IBOutlet UIImageView *thumbPadView;
@property (nonatomic, strong, readonly) IBOutlet UIImageView *thumbPadShadowView;
@property (nonatomic, strong, readonly) IBOutlet UIImageView *circularTrackView;
@property (nonatomic, strong, readonly) IBOutlet UIImageView *markingsView;


//@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panRecognizer;
/** The receiver's delegate or 'nil' if it doesn't have a delegate. */
@property (nonatomic, weak) id <MZJoystickDelegate> delegate;

- (id)initWithParameters:(NSDictionary*)parameters;

- (void)setThumbPadTranslation:(CGPoint)translation;
- (void)resetThumbPadPosition;
@end
