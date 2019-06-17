//
//  MZPressGestureRecognizer.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 10/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZPressGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MZPressGestureRecognizer

// called automatically by the runtime after the gesture state has
// been set to UIGestureRecognizerStateEnded any internal state
// should be reset to prepare for a new attempt to recognize the gesture
// after this is received all remaining active touches will be ignored
// (no further updates will be received for touches that had already
// begun but haven't ended)
- (void)reset
{
    [super reset];
    
    self.firstScreenLocation = CGPointZero;
    self.lastScreenLocation = CGPointZero;
    self.state = UIGestureRecognizerStatePossible;
}

// mirror of the touch-delivery methods on UIResponder
// UIGestureRecognizers aren't in the responder chain, but observe
// touches hit-tested to their view and their view's subviews
// UIGestureRecognizers receive touches before the view to which
// the touch was hit-tested
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count > 1)
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if (self.state == UIGestureRecognizerStatePossible) {
        
        UITouch *touch = [touches anyObject];
        self.firstScreenLocation = [touch locationInView:self.view];
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent: event];
    
    //BOOL detectionSuccess = !CGRectEqualToRect(CGRectZero,
    //                                           testForCircle(points, firstTouchDate));
    UITouch *touch = [touches anyObject];
    self.lastScreenLocation = [touch locationInView:self.view];
    self.state = UIGestureRecognizerStateEnded;
}

@end
