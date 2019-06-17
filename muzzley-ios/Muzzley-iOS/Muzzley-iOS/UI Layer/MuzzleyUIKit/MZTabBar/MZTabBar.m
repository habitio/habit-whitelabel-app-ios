//
//  MZTabBar.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTabBar.h"

@interface MZTabBar ()
@property (nonatomic, readwrite) NSArray *items;
@property (nonatomic, weak) UIView *contentView;
@end

@implementation MZTabBar

#pragma mark - Initializers Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setupInterface];
        return self;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupInterface];
        return self;
    }
    return nil;
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 50)]) {
        [self _setupInterface];
        return self;
    }
    return nil;
}

#pragma mark - Private Methods
- (void)_setupInterface {
    self.lastIndexSelected = -1;
    self.barTintColor = [UIColor whiteColor];
    
    UIView *contentView = [UIView new];
    
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    NSArray *tab_h_constraints;
    if (UI_USER_INTERFACE_IDIOM () == UIUserInterfaceIdiomPhone) {
        tab_h_constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:0 metrics:nil views:@{@"_contentView":_contentView}];
        
    } else if (UI_USER_INTERFACE_IDIOM () == UIUserInterfaceIdiomPad) {
        NSLayoutConstraint *centerX = [NSLayoutConstraint
                                       constraintWithItem:contentView
                                       attribute:NSLayoutAttributeCenterX
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeCenterX
                                       multiplier:1
                                       constant:0];
        
        NSLayoutConstraint *width = [NSLayoutConstraint
                                     constraintWithItem:contentView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                     constant:500];
        
        tab_h_constraints = @[centerX, width];
    }
    
    NSArray *tab_v_constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics:nil views:@{@"_contentView":_contentView}];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ) {
        [NSLayoutConstraint activateConstraints:tab_h_constraints];
        [NSLayoutConstraint activateConstraints:tab_v_constraints];
    }
    else
    {
        [self addConstraints:tab_h_constraints];
        [self addConstraints:tab_v_constraints];
    }
    
    [self layoutIfNeeded];
}

#pragma mark - Public Methods

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    
    self.backgroundColor = _barTintColor;
}

- (void)addItems:(NSArray *)items {
    
    items = [items isKindOfClass:[NSArray class]] ? items : [NSArray new];
    
    self.items = items;
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    MZTabBarItem *previousTabBarItem;
    for (NSUInteger index = 0; index < self.items.count; index++) {
        
        MZTabBarItem *tabBarItem = self.items[index];
        if (![tabBarItem isKindOfClass:[MZTabBarItem class]]) { continue; }
        
        [tabBarItem setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:tabBarItem];
        
        NSArray *tab_h_constraints;
        
        if (index == 0) {
            tab_h_constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabBarItem]" options:0 metrics:nil views:@{@"tabBarItem":tabBarItem}];
            
        } else if(index == self.items.count -1) {
            tab_h_constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousTabBarItem][tabBarItem(==previousTabBarItem)]|" options:0 metrics:nil views:@{@"tabBarItem":tabBarItem, @"previousTabBarItem":previousTabBarItem}];
        } else {
            tab_h_constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousTabBarItem][tabBarItem(==previousTabBarItem)]" options:0 metrics:nil views:@{@"tabBarItem":tabBarItem, @"previousTabBarItem":previousTabBarItem}];
        }
        NSArray *tab_v_constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tabBarItem]|" options:0 metrics:nil views:@{@"tabBarItem":tabBarItem}];
        
        previousTabBarItem = tabBarItem;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ) {
            [NSLayoutConstraint activateConstraints:tab_h_constraints];
            [NSLayoutConstraint activateConstraints:tab_v_constraints];
        } else {
            [self addConstraints:tab_h_constraints];
            [self addConstraints:tab_v_constraints];
        }
        
        //tabBarItem.selected = NO;
		
        tabBarItem.tintColor = self.tintColor;

		[tabBarItem removeTarget:self action:@selector(_didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        [tabBarItem addTarget:self action:@selector(_didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        [tabBarItem removeTarget:self action:@selector(_didDoubleTapItem:) forControlEvents:UIControlEventTouchDownRepeat];
        [tabBarItem addTarget:self action:@selector(_didDoubleTapItem:) forControlEvents:UIControlEventTouchDownRepeat];

    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)handleScroll:(UIScrollView *)scrollView {
    CGFloat contentWidth = scrollView.contentSize.width;
    NSUInteger itemsCount = self.items.count;
    CGFloat itemWidth = 0;
    
    if (itemsCount > 0) {
        itemWidth = contentWidth / itemsCount;
    
        CGFloat currentIndex = (scrollView.contentOffset.x / itemWidth);
        
        for (NSUInteger i = 0; i < itemsCount; i++) {
            MZTabBarItem *item = self.items[i];
            
            CGFloat distance =  fabs(i - currentIndex);
            distance = MIN(distance, 0.5);
            CGFloat alphaAddition = 0.4 - (distance * 0.8);
            
            CGFloat alpha = 0.6 + alphaAddition;
            item.imageView.alpha = alpha;
        }
    }
}

- (void)handleScrollEnd:(UIScrollView *)scrollView {
    [self handleScroll:scrollView];
}

- (void)setSelectedItem:(MZTabBarItem *)selectedItem {
	for (MZTabBarItem * item in _items)
	{
		if(item != selectedItem)
		{
			item.selected = NO;
			item.highlighted = NO;
		}
	}
    _selectedItem.selected = NO;
    selectedItem.selected = YES;
    selectedItem.highlighted = NO;
    _selectedItem = selectedItem;
}

- (void)hideItemsAnimated:(BOOL)animated {
    
    CGFloat duration = animated ? 0.2 : 0;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        for (MZTabBarItem *item in self.items) {
            item.alpha = 0;
        }
    } completion:nil];
}

- (void)showItemsAnimated:(BOOL)animated {
    CGFloat duration = animated ? 0.2 : 0;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        for (MZTabBarItem *item in self.items) {
            item.alpha = 1;
        }
    } completion:nil];
}

- (void)_didSelectedItem:(MZTabBarItem *)item {
    self.lastIndexSelected = [self.items indexOfObject:self.selectedItem];
    
    self.selectedItem = item;
    
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItem:)])
    {
        [self.delegate tabBar:self didSelectItem:item];
    }
}


- (void)_didDoubleTapItem:(MZTabBarItem *)item
{
    if ([self.delegate respondsToSelector:@selector(tabBar:didDoubleTapItem:)])
    {
        [self.delegate tabBar:self didDoubleTapItem:item];
    }
}

@end
