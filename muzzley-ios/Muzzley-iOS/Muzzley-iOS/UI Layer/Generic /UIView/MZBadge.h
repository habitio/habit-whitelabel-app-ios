//
//  MZBadge.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 07/10/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//
//  This is a simple class which emulates the badges on apps on the iOS home screen
//  and on UITabBarItems

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JSBadgeViewAlignment)
{
    JSBadgeViewAlignmentTopLeft = 1,
    JSBadgeViewAlignmentTopRight,
    JSBadgeViewAlignmentTopCenter,
    JSBadgeViewAlignmentCenterLeft,
    JSBadgeViewAlignmentCenterRight,
    JSBadgeViewAlignmentBottomLeft,
    JSBadgeViewAlignmentBottomRight,
    JSBadgeViewAlignmentBottomCenter,
    JSBadgeViewAlignmentCenter,
    JSBadgeViewAlignmentTopRightAnimationDown
};

@interface MZBadge : UIView

@property (nonatomic, copy) NSString *badgeText;

#pragma mark - Customization

@property (nonatomic, assign) JSBadgeViewAlignment badgeAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *badgeTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize badgeTextShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeTextShadowColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIFont *badgeTextFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *badgeBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 * Color of the overlay circle at the top. Default is semi-transparent white.
 */
@property (nonatomic, strong) UIColor *badgeOverlayColor UI_APPEARANCE_SELECTOR;

/**
 * Color of the badge shadow. Default is semi-transparent black.
 */
@property (nonatomic, strong) UIColor *badgeShadowColor UI_APPEARANCE_SELECTOR;

/**
 * Offset of the badge shadow. Default is 3.0 points down.
 */
@property (nonatomic, assign) CGSize badgeShadowSize UI_APPEARANCE_SELECTOR;

/**
 * Width of the circle around the badge. Default is 2.0 points.
 */
@property (nonatomic, assign) CGFloat badgeStrokeWidth UI_APPEARANCE_SELECTOR;

/**
 * Color of the circle around the badge. Default is white.
 */
@property (nonatomic, strong) UIColor *badgeStrokeColor UI_APPEARANCE_SELECTOR;

/**
 * Allows to shift the badge by x and y points.
 */
@property (nonatomic, assign) CGPoint badgePositionAdjustment UI_APPEARANCE_SELECTOR;

/**
 * You can use this to position the view if you're drawing it using drawRect instead of `-addSubview:`
 * (optional) If not provided, the superview frame is used.
 */
@property (nonatomic, assign) CGRect frameToPositionInRelationWith UI_APPEARANCE_SELECTOR;

/**
 * Optionally init using this method to have the badge automatically added to another view.
 */
- (id)initWithParentView:(UIView *)parentView alignment:(JSBadgeViewAlignment)alignment;


@property (nonatomic, assign) CGRect absoluteFrame;

- (void)setBadgeText:(NSString *)badgeText animated:(BOOL)animated;

@end