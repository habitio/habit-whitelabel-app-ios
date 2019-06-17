//
//  MZArcHeaderView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZArcHeaderView.h"

@implementation MZArcHeaderView

- (void)drawRect:(CGRect)rect {
    
    CAShapeLayer *shape = [CAShapeLayer new];
    shape.frame = self.layer.bounds;
    
    CGFloat width = self.layer.frame.size.width;
    CGFloat height = self.layer.frame.size.height;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint:CGPointMake(0, height)];
    [bezierPath addQuadCurveToPoint:CGPointMake(width, height)
                 controlPoint:CGPointMake(width * 0.5, -height)];
    [bezierPath closePath];

    shape.path = bezierPath.CGPath;
    self.layer.mask = shape;
}
@end
