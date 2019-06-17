//
//  MZBadge.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 07/10/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZBadge.h"

#import <QuartzCore/QuartzCore.h>

#if !__has_feature(objc_arc)
#error JSBadgeView must be compiled with ARC.
#endif

static const CGFloat JSBadgeViewShadowRadius = 1.0f;
static const CGFloat JSBadgeViewHeight = 17.0f;
static const CGFloat JSBadgeViewTextSideMargin = 10.0f;
static const CGFloat JSBadgeViewCornerRadius = 10.0f;

// Thanks to Peter Steinberger: https://gist.github.com/steipete/6526860
static BOOL JSBadgeViewIsUIKitFlatMode(void)
{
    static BOOL isUIKitFlatMode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.2
#endif
        
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
        {
            // If your app is running in legacy mode, tintColor will be nil - else it must be set to some color.
            if (UIApplication.sharedApplication.keyWindow)
            {
                isUIKitFlatMode = [UIApplication.sharedApplication.keyWindow performSelector:@selector(tintColor)] != nil;
            }
            else
            {
                // Possible that we're called early on (e.g. when used in a Storyboard). Adapt and use a temporary window.
                isUIKitFlatMode = [[[UIWindow alloc] init] performSelector:@selector(tintColor)] != nil;
            }
        }
    });
    
    return isUIKitFlatMode;
}

@implementation MZBadge

+ (void)applyCommonStyle
{
    MZBadge *badgeViewAppearanceProxy = MZBadge.appearance;
    
    badgeViewAppearanceProxy.backgroundColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeAlignment = JSBadgeViewAlignmentTopRight;
    badgeViewAppearanceProxy.badgeBackgroundColor = UIColor.redColor;
    badgeViewAppearanceProxy.badgeTextFont = [UIFont boldSystemFontOfSize:UIFont.systemFontSize];
    badgeViewAppearanceProxy.badgeTextColor = UIColor.whiteColor;
}

+ (void)applyLegacyStyle
{
    MZBadge *badgeViewAppearanceProxy = MZBadge.appearance;
    
    badgeViewAppearanceProxy.badgeOverlayColor = [UIColor colorWithWhite:1.0f alpha:0.3];
    badgeViewAppearanceProxy.badgeTextShadowColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeShadowColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    badgeViewAppearanceProxy.badgeShadowSize = CGSizeMake(0.0f, 3.0f);
    badgeViewAppearanceProxy.badgeStrokeWidth = 2.0f;
    badgeViewAppearanceProxy.badgeStrokeColor = UIColor.whiteColor;
}

+ (void)applyIOS7Style
{
    MZBadge *badgeViewAppearanceProxy = MZBadge.appearance;
    
    badgeViewAppearanceProxy.badgeOverlayColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeTextShadowColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeShadowColor = UIColor.clearColor;
    badgeViewAppearanceProxy.badgeStrokeWidth = 0.0f;
    badgeViewAppearanceProxy.badgeStrokeColor = badgeViewAppearanceProxy.badgeBackgroundColor;
}

+ (void)initialize
{
    if (self == MZBadge.class)
    {
        [self applyCommonStyle];
        
        if (JSBadgeViewIsUIKitFlatMode())
        {
            [self applyIOS7Style];
        }
        else
        {
            [self applyLegacyStyle];
        }
    }
}

- (id)initWithParentView:(UIView *)parentView alignment:(JSBadgeViewAlignment)alignment
{
    if ((self = [self initWithFrame:CGRectZero]))
    {
        _badgeAlignment = alignment;
        [parentView addSubview:self];
    }
    
    return self;
}

#pragma mark - Layout

- (CGFloat)marginToDrawInside
{
    return self.badgeStrokeWidth * 2.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect newFrame = self.frame;
    const CGRect superviewBounds = CGRectIsEmpty(_frameToPositionInRelationWith) ? self.superview.bounds : _frameToPositionInRelationWith;
    
    const CGFloat textWidth = [self sizeOfTextForCurrentSettings].width;
    
    const CGFloat marginToDrawInside = [self marginToDrawInside];
    const CGFloat viewWidth = textWidth + JSBadgeViewTextSideMargin + (marginToDrawInside * 2);
    const CGFloat viewHeight = JSBadgeViewHeight + (marginToDrawInside * 2);
    
    const CGFloat superviewWidth = superviewBounds.size.width;
    const CGFloat superviewHeight = superviewBounds.size.height;
    
    newFrame.size.width = viewWidth;
    newFrame.size.height = viewHeight;
    
    switch (self.badgeAlignment) {
        case JSBadgeViewAlignmentTopLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case JSBadgeViewAlignmentTopRight:
            newFrame.origin.x = (superviewWidth - (viewWidth / 2.0f)) - 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case JSBadgeViewAlignmentTopCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case JSBadgeViewAlignmentCenterLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentCenterRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentBottomLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case JSBadgeViewAlignmentBottomRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case JSBadgeViewAlignmentBottomCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case JSBadgeViewAlignmentCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentTopRightAnimationDown:
            newFrame.origin.x = (superviewWidth - (viewWidth / 2.0f)) - 2;
            newFrame.origin.y = (-viewHeight / 2.0f) + 10;
            break;
        default:
            NSAssert(NO, @"Unimplemented JSBadgeAligment type %lu", (unsigned long)self.badgeAlignment);
    }
    
    newFrame.origin.x += _badgePositionAdjustment.x;
    newFrame.origin.y += _badgePositionAdjustment.y;
    
    self.frame = CGRectIntegral(newFrame);
    self.absoluteFrame = self.frame;
    
    [self setNeedsDisplay];
}

#pragma mark - Private

- (CGSize)sizeOfTextForCurrentSettings
{
    //return [self.badgeText sizeWithFont:self.badgeTextFont];
    return CGSizeMake(100, 50);
}

#pragma mark - Setters

- (void)setBadgeAlignment:(JSBadgeViewAlignment)badgeAlignment
{
    if (badgeAlignment != _badgeAlignment)
    {
        _badgeAlignment = badgeAlignment;
        
        [self setNeedsLayout];
    }
}

- (void)setBadgePositionAdjustment:(CGPoint)badgePositionAdjustment
{
    _badgePositionAdjustment = badgePositionAdjustment;
    
    [self setNeedsLayout];
}

- (void)setBadgeText:(NSString *)badgeText
{
    if (badgeText != _badgeText)
    {
        _badgeText = [badgeText copy];
        
        [self setNeedsLayout];
    }
}

- (void)setBadgeText:(NSString *)badgeText animated:(BOOL)animated
{
    self.badgeText = badgeText;
   
    CGPoint pt = self.center;
    
    if (animated) {
        
        [UIView animateWithDuration:0.3 animations:^{
        
            self.center = CGPointMake(pt.x, pt.y + 5);
            
           
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                  self.center = CGPointMake(pt.x, pt.y - 5);
                
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    if (badgeTextColor != _badgeTextColor)
    {
        _badgeTextColor = badgeTextColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeTextShadowColor:(UIColor *)badgeTextShadowColor
{
    if (badgeTextShadowColor != _badgeTextShadowColor)
    {
        _badgeTextShadowColor = badgeTextShadowColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeTextShadowOffset:(CGSize)badgeTextShadowOffset
{
    _badgeTextShadowOffset = badgeTextShadowOffset;
    
    [self setNeedsDisplay];
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont
{
    if (badgeTextFont != _badgeTextFont)
    {
        _badgeTextFont = badgeTextFont;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor
{
    if (badgeBackgroundColor != _badgeBackgroundColor)
    {
        _badgeBackgroundColor = badgeBackgroundColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeStrokeWidth:(CGFloat)badgeStrokeWidth
{
    if (badgeStrokeWidth != _badgeStrokeWidth)
    {
        _badgeStrokeWidth = badgeStrokeWidth;
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setBadgeStrokeColor:(UIColor *)badgeStrokeColor
{
    if (badgeStrokeColor != _badgeStrokeColor)
    {
        _badgeStrokeColor = badgeStrokeColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeShadowColor:(UIColor *)badgeShadowColor
{
    if (badgeShadowColor != _badgeShadowColor)
    {
        _badgeShadowColor = badgeShadowColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeShadowSize:(CGSize)badgeShadowSize
{
    if (!CGSizeEqualToSize(badgeShadowSize, _badgeShadowSize))
    {
        _badgeShadowSize = badgeShadowSize;
        
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    const BOOL anyTextToDraw = (self.badgeText.length > 0);
    
    if (anyTextToDraw)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        const CGFloat marginToDrawInside = [self marginToDrawInside];
        const CGRect rectToDraw = CGRectInset(rect, marginToDrawInside, marginToDrawInside);
        
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(JSBadgeViewCornerRadius, JSBadgeViewCornerRadius)];
        
        /* Background and shadow */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetFillColorWithColor(ctx, self.badgeBackgroundColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.badgeShadowSize, JSBadgeViewShadowRadius, self.badgeShadowColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathFill);
        }
        CGContextRestoreGState(ctx);
        
        const BOOL colorForOverlayPresent = self.badgeOverlayColor && ![self.badgeOverlayColor isEqual:[UIColor clearColor]];
        
        if (colorForOverlayPresent)
        {
            /* Gradient overlay */
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, borderPath.CGPath);
                CGContextClip(ctx);
                
                const CGFloat height = rectToDraw.size.height;
                const CGFloat width = rectToDraw.size.width;
                
                const CGRect rectForOverlayCircle = CGRectMake(rectToDraw.origin.x,
                                                               rectToDraw.origin.y - ceilf(height * 0.5),
                                                               width,
                                                               height);
                
                CGContextAddEllipseInRect(ctx, rectForOverlayCircle);
                CGContextSetFillColorWithColor(ctx, self.badgeOverlayColor.CGColor);
                
                CGContextDrawPath(ctx, kCGPathFill);
            }
            CGContextRestoreGState(ctx);
        }
        
        /* Stroke */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetLineWidth(ctx, self.badgeStrokeWidth);
            CGContextSetStrokeColorWithColor(ctx, self.badgeStrokeColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        CGContextRestoreGState(ctx);
        
        /* Text */
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, self.badgeTextColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.badgeTextShadowOffset, 1.0, self.badgeTextShadowColor.CGColor);
            
            CGRect textFrame = rectToDraw;
            const CGSize textSize = [self sizeOfTextForCurrentSettings];
            
            textFrame.size.height = textSize.height;
            textFrame.origin.y = rectToDraw.origin.y + ceilf((rectToDraw.size.height - textFrame.size.height) / 2.0f);
            
            /*[self.badgeText drawInRect:textFrame
                              withFont:self.badgeTextFont
                         lineBreakMode:UILineBreakModeCharacterWrap
                             alignment:UITextAlignmentCenter];*/
        }
        CGContextRestoreGState(ctx);
    }
}

@end