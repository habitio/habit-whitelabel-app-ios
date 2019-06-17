//
//  MZSwipeNavigatorViewController.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 18/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"

@interface MZSwipeNavigatorViewController : MZWidget

/// UI Objects
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonOK;
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonBack;

@property (nonatomic, strong, readonly) IBOutlet UIImageView *tapCenter;
@property (nonatomic, weak) IBOutlet UIImageView *trackpad;
/// Gestures Recognizers
@property (nonatomic, strong, readonly) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (nonatomic, strong, readonly) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (nonatomic, strong, readonly) IBOutlet UISwipeGestureRecognizer *upSwipeGesture;
@property (nonatomic, strong, readonly) IBOutlet UISwipeGestureRecognizer *downSwipeGesture;
@property (nonatomic, strong, readonly) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong, readonly) IBOutlet UIPinchGestureRecognizer *pinchGesture;

/// IBACTIONS
- (IBAction)buttonTouchUpInside:(id)sender;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer;
- (IBAction)handleTap:(UITapGestureRecognizer*)recognizer;
- (IBAction)handlePinch:(UIPinchGestureRecognizer*)recognizer;

@end
