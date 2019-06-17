//
//  MZInfiniteScrollView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "RootScrollView.h"

@interface RootScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *subItems;
@property (nonatomic, readwrite) NSUInteger visibleItem;
@end


@implementation RootScrollView

- (void)dealloc
{
    self.subItems = nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.pagingEnabled = YES;
        self.subItems = [NSMutableArray new];
        //self.visibleItemIndex = 0;
    }
    return self;
}

- (void)addItem:(UIView *)view
{
    view.tag = self.subItems.count;
    view.frame = CGRectMake(self.bounds.size.width * self.subItems.count, 0,
                            self.bounds.size.width, self.bounds.size.height);
    // Recalculate new content size
    [self.subItems addObject:view];
   
    self.contentSize = CGSizeMake(self.bounds.size.width * self.subItems.count,
                                  self.bounds.size.height);
    [self addSubview:view];
}

- (NSUInteger)visibleItem
{
    NSUInteger visibleItem = 0;
    for (NSUInteger i = 0; i < _subItems.count; i++) {
        
        UIView *view = _subItems[i];
        if (view.frame.origin.x == self.contentOffset.x) {
            visibleItem = i;
            break;
        }
    }
    return visibleItem;
}

- (void)scrollToItemIndex:(NSUInteger)toItemIndex animated:(BOOL)animated
{
    NSUInteger fromItemIndex = self.visibleItem;
    //self.visibleItemIndex = toItemIndex;
    NSInteger indexDifference = toItemIndex - fromItemIndex;
    CGFloat distanceToScroll = indexDifference * CGRectGetWidth(self.bounds);
    
    if (!animated) {
        self.contentOffset = CGPointMake((fromItemIndex * CGRectGetWidth(self.bounds)) + distanceToScroll , 0);
        return;
    }
    
    [UIView
     animateWithDuration:0.3
     delay:0.0
     options:UIViewAnimationOptionCurveEaseOut //| UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.contentOffset = CGPointMake((fromItemIndex * CGRectGetWidth(self.bounds)) + distanceToScroll, 0);
     }
     completion:^(BOOL finished) {
 
     }];
}


@end