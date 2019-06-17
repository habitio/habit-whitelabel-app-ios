//
//  TouchDownGestureRecognizer.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 10/10/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZTouchDownGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MZTouchDownGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateRecognized;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateFailed;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateFailed;
}


@end