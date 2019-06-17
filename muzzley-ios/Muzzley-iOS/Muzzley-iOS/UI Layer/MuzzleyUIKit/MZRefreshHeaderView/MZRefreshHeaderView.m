//
//  MZRefreshHeaderControl.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshHeaderView.h"
#import "MZRefreshHeaderViewPrivate.h"
#import "MZRefreshHeaderViewSubclass.h"

@implementation MZRefreshHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = YES;
        self.refreshState = MZRefreshHeaderViewStateNormal;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    static const CGFloat bottomPadding = 2;
    return CGSizeMake(size.width, self.pullAmountToRefresh + bottomPadding);
}

- (void)setRefreshState:(MZRefreshHeaderViewState)refreshState {
    [self setRefreshState:refreshState animated:YES];
}

- (void)setRefreshState:(MZRefreshHeaderViewState)refreshState animated:(BOOL)animated {
    _refreshState = refreshState;
    
    void (^animationBlock)() = ^{
        UIScrollView *strongScrollView = self.scrollView;
        UIEdgeInsets contentInset = strongScrollView.contentInset;
        // TODO: make this support view controllers that have UIRectEdgeTop
        contentInset.top = (refreshState == MZRefreshHeaderViewStateRefreshing) ? self.pullAmountToRefresh : 0;
        strongScrollView.contentInset = contentInset;
    };
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        if (self.refreshState == MZRefreshHeaderViewStateClosing) {
            self.refreshState = MZRefreshHeaderViewStateNormal;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

- (CGFloat)pullAmountToRefresh {
    NSAssert(NO, @"Abstract method – subclasses must implement this.");
    return 0;
}

#pragma mark UIScrollViewDelegate

- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        // If we were ready to refresh but then dragged back up, cancel the Ready to Refresh state.
        if (self.refreshState == MZRefreshHeaderViewStateReadyToRefresh && scrollView.contentOffset.y > -self.pullAmountToRefresh && scrollView.contentOffset.y < 0) {
            self.refreshState = MZRefreshHeaderViewStateNormal;
            // If we've dragged far enough, put us in the Ready to Refresh state
        } else if (self.refreshState == MZRefreshHeaderViewStateNormal && scrollView.contentOffset.y <= -self.pullAmountToRefresh) {
            self.refreshState = MZRefreshHeaderViewStateReadyToRefresh;
        }
    }
    self.currentPullAmount = MAX(0, -scrollView.contentOffset.y);
}

- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView {
    // Trigger the action if it was pulled far enough.
    if (scrollView.contentOffset.y <= -self.pullAmountToRefresh &&  self.refreshState != MZRefreshHeaderViewStateRefreshing) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        self.currentPullAmount = 0;
    }
}

@end
