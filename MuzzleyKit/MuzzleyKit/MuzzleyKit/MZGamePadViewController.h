//
//  MZGamePadViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 07/12/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"
#import "MZJoystickViewController.h"

// Gamepad Custom Configurations
typedef enum : NSUInteger {
    MZGamePadTypeOneButton      = 1,
    MZGamePadTypeTwoButtons     = 2,
    MZGamePadTypeThreeButtons   = 3,
    MZGamePadTypeFourButtons    = 4,
} MZGamePadType;


// Options dictionary's constant keys
extern NSString *const kMZGamePadOptionSector;
extern NSString *const kMZGamePadOptionIntensitySteps;
extern NSString *const kMZGamePadOptionNumberOfButtons;

@interface MZGamePadViewController : MZWidget <MZJoystickDelegate>

// Input Objects
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonA;
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonB;
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonC;
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonD;
@property (nonatomic, strong, readonly) MZJoystickViewController *joystickLeft;

// MZGamePadType configuration
@property (nonatomic, assign) MZGamePadType type;

// IBACTIONS
- (IBAction)touchDown:(id)sender;
- (IBAction)touchUp:(id)sender;

@end
