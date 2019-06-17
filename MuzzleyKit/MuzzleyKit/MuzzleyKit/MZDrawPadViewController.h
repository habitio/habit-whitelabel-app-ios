//
//  MZDrawPadViewController.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 08/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"
#import "MZBezierDrawView.h"

@interface MZDrawPadViewController : MZWidget <MZBezierDrawDelegate>

/// UI Objects
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonClean;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

/// IBACTIONS
- (IBAction)cleanDrawView:(id)sender;

@end
