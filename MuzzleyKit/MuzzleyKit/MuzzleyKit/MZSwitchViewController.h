//
//  MZSwitchViewController.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 11/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"

@interface MZSwitchViewController : MZWidget

/// UI Objects
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonSwitch;
@property (nonatomic, strong, readonly) IBOutlet UIImageView *imageSwitchBox;

/// IBACTIONS
- (IBAction)switchPressedUpInside:(id)sender;
- (IBAction)switchPressedDown:(id)sender;

@end
