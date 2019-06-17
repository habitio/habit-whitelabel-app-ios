//
//  MZTabBar.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MZTabBarItem.h"

@class MZTabBar;

@protocol MZTabBarDelegate<NSObject>
@optional
- (void)tabBar:(MZTabBar *)tabBar didSelectItem:(MZTabBarItem *)item;
- (void)tabBar:(MZTabBar *)tabBar didDoubleTapItem:(MZTabBarItem *)item;

@end

@interface MZTabBar : UIView
@property (nonatomic) UIColor *barTintColor;

@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, weak) MZTabBarItem *selectedItem;
@property (nonatomic) NSUInteger lastIndexSelected;

@property (nonatomic, weak) id<MZTabBarDelegate> delegate;

- (void)addItems:(NSArray *)items;
- (void)handleScroll:(UIScrollView *)scrollView;
- (void)handleScrollEnd:(UIScrollView *)scrollView;

- (void)hideItemsAnimated:(BOOL)animated;
- (void)showItemsAnimated:(BOOL)animated;
@end

