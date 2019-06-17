//
//  MZInfiniteScrollView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

@interface RootScrollView : UIScrollView

@property (nonatomic, weak) UIGestureRecognizer *tableViewGestureRecognizer;
@property (nonatomic, readonly) NSUInteger visibleItem;

- (void)addItem:(UIView *)view;
- (void)scrollToItemIndex:(NSUInteger)toItemIndex animated:(BOOL)animated;
@end
