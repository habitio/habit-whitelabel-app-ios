//
//  MZBezierDrawView.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 15/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZBezierDrawView.h"

@interface MZBezierDrawView ()

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIImage *incrementalImage;

@property (nonatomic, assign) bool alreadyEnded;

@end

@implementation MZBezierDrawView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        self.path = [UIBezierPath bezierPath];
        
        self.path.lineWidth = 2;
        //self.path.lineCapStyle = kCGLineCapRound;
        //self.path.lineJoinStyle = kCGLineJoinRound;
        NSLog(@"%f %f %f %f", self.frame.origin.x , self.frame.origin.y, self.frame.size.width, self.frame.size.height );
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        self.path = [UIBezierPath bezierPath];
        
        self.path.lineWidth = 2;
        //self.path.lineCapStyle = kCGLineCapRound;
        //self.path.lineJoinStyle = kCGLineJoinRound;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
        [_incrementalImage drawInRect:rect];
        [_path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.alreadyEnded = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    //float x = p.x < 0 ? 0: p.x;
    //float y = p.y < 0 ? 0: p.y;
    NSLog(@" BEGAN [%.2f %.2f]", p.x, p.y);
    
    if (_pathHistoryDecay == -1) {
        
        [_path moveToPoint:p];
    }
    
    if ([self.delegate respondsToSelector:@selector(bezierDraw:touchBegan:)]) {
        [self.delegate bezierDraw:self touchBegan:p];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if (_alreadyEnded) {
        
        if (p.y < 1) {
            return;
            
        } else {
            [self touchesBegan:touches withEvent:event];
            return;
        }
        
    } else {
       
        if (p.y < 1) {
            
            [self touchesEnded:touches withEvent:event];
            self.alreadyEnded = YES;
            return;
        }
    }
    
    NSLog(@" MOVED [%.2f %.2f]", p.x, p.y);
    if (_pathHistoryDecay == -1) {
        
        [_path addLineToPoint:p];
        [self setNeedsDisplay];
    }
    
    if ([self.delegate respondsToSelector:@selector(bezierDraw:touchMoved:)]) {
        [self.delegate bezierDraw:self touchMoved:p];
    }
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.alreadyEnded) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
   
    //float x = p.x < 0 ? 0: p.x;
    float y = p.y < 1 ? 0: p.y;
    
    p = CGPointMake(p.x, y);
     NSLog(@" ENDED [%.2f %.2f]", p.x, p.y );
    
    if (_pathHistoryDecay == -1) {
        
        [_path addLineToPoint:p];
        [self drawBitmap];
        [self setNeedsDisplay];
        [_path removeAllPoints];
    }
    
    if ([self.delegate respondsToSelector:@selector(bezierDraw:touchEnded:)]) {
        [self.delegate bezierDraw:self touchEnded:p];
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    [[UIColor blackColor] setStroke];
    if (!_incrementalImage) // first draw; paint background white by ...
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds]; // enclosing bitmap by a rectangle defined by another UIBezierPath object
        [[UIColor clearColor] setFill];
        [rectpath fill]; // filling it with clear color
    }
    
    [_incrementalImage drawAtPoint:CGPointZero];
    [_path stroke];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)clean {
    
    self.incrementalImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    [[UIColor blackColor] setStroke];
    if (!_incrementalImage) // first draw; paint background white by ...
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds]; // enclosing bitmap by a rectangle defined by another UIBezierPath object
        [[UIColor clearColor] setFill];
        [rectpath fill]; // filling it with clear color
    }
    
    [_incrementalImage drawAtPoint:CGPointZero];
    [_path stroke];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
    [_path removeAllPoints];
}
@end
