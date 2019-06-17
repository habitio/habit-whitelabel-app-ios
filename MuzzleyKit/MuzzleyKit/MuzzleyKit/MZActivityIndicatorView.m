//
//  MZActivityIndicatorView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 15/05/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZActivityIndicatorView.h"

#import <QuartzCore/QuartzCore.h>

@implementation MZActivityIndicatorView

- (id)init
{
    if (self = [super init]) {
        [self _commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    //self.alpha = 0;
}

- (void)startRotating
{
    
    [self.layer removeAllAnimations];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: 2.0 * M_PI ]; /// full rotation
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VAL;
    
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    self.hidden = NO;
}

- (void)stopRotating {
    
    self.hidden = YES;
    [self.layer removeAllAnimations];
}

#pragma mark - Tinting
- (void)tintToColor:(UIColor*)color
{
    self.image = [self imageRepresentationWithTintColor: color];
}

- (UIImage *)imageRepresentation
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage*) imageRepresentationWithTintColor:(UIColor*)color
{
    UIImage* viewImage = [self imageRepresentation];
    viewImage = [self tintedImage:viewImage usingColor:color];
    return viewImage;
}

- (UIImage *)tintedImage:(UIImage*)image usingColor:(UIColor *)tintColor {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    
    CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return tintedImage;
}
@end
