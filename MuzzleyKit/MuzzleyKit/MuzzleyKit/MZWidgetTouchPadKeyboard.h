//
//  MZWidgetTouchPadKeyboard.h
//  MuzzleyKit
//
//  Created by Hugo Sousa on 13/03/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MZWidget.h"

@interface MZWidgetTouchPadKeyboard : MZWidget

@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

// Gesture Recognizers
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender;
- (IBAction)longPressDetected:(UILongPressGestureRecognizer *)sender;
- (IBAction)panDetected:(UIPanGestureRecognizer *)sender;

@end
