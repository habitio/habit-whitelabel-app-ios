//
//  PulseView.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 18/03/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "PulseView.h"
@interface PulseView ()

@property (nonatomic, strong) CAShapeLayer *innerCircle;
@property (nonatomic, strong) CAShapeLayer *borderCircle;

@end

@implementation PulseView

// Set up your view to use a CAShapeLayer
+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

// The system sends layoutSubviews to your view whenever it changes size (including when it first appears). You override layoutSubviews to set up the shape and animate it:
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setLayerProperties];
    //[self attachAnimations];
}

// You set the layer's path (which determines its shape) and the fill color for the shape:

- (void)setLayerProperties
{
    if (!_innerCircle) {
        self.innerCircle = [CAShapeLayer layer];
        _innerCircle.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
        _innerCircle.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_innerCircle];
    }
}

// You need to attach two animations to the layer - one for the path and one for the fill color:

- (void)attachAnimations
{
    //[self attachPathAnimation];
    //[self attachColorAnimation];
    //[self attachFadeOutAnimation];
}

// Here's how you animate the layer's path:

- (void)attachBorderAnimation
{
    if (!_borderCircle) {
        self.borderCircle = [CAShapeLayer layer];
        self.borderCircle.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_borderCircle];
        
        _borderCircle.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
        _borderCircle.fillColor = [UIColor clearColor].CGColor;
        _borderCircle.lineWidth = 2;
        _borderCircle.strokeColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1].CGColor;
    }
    
    CABasicAnimation *animation = [self animationWithKeyPath:@"path"];
    animation.toValue = (__bridge id)[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, -10, -10)].CGPath;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_borderCircle addAnimation:animation forKey:animation.keyPath];
}

// Here's how you animate the layer's fill color:

- (void)attachColorAnimationWithColor:(UIColor *)color
{
    CABasicAnimation *animation = [self animationWithKeyPath:@"fillColor"];
    animation.toValue = (__bridge id)color.CGColor;
    [_innerCircle addAnimation:animation forKey:animation.keyPath];
}

- (void)attachFadeOutAnimation
{
    CABasicAnimation *animation = [self animationWithKeyPath:@"opacity"];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    [self.layer addAnimation:animation forKey:animation.keyPath];
}
// Both of the attach*Animation methods use a helper method that creates a basic animation and sets it up to repeat indefinitely with autoreverse and a one second duration:

- (CABasicAnimation *)animationWithKeyPath:(NSString *)keyPath
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.autoreverses = NO;
    animation.repeatCount = 1;
    animation.duration = 0.3;
    return animation;
}

- (void)pulseTouchDown
{
    [self attachColorAnimationWithColor:[UIColor lightGrayColor]];
}

- (void)pulseLongPress
{
    [self attachColorAnimationWithColor:[UIColor redColor]];
    [self attachBorderAnimation];
}
@end
