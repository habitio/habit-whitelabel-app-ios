//
//  MZRefreshableScrollViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshableCollectionViewController.h"

#import "MZCollectionView.h"
#import "MZRefreshHeaderViewPrivate.h"

@implementation MZRefreshableCollectionViewController

#pragma mark UIScrollViewDelegate

// NOTE: The following methods inform a refresh header view of the scrolling behavior of the collectionview.  This makes our refresh headers work.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSAssert([scrollView isKindOfClass:[MZCollectionView class]], @"This can only be the delegate of a MZCollectionView.");
    MZRefreshHeaderView *refreshHeaderView = [(MZCollectionView *)scrollView refreshHeaderView];
    if (refreshHeaderView) {
        NSAssert([refreshHeaderView isKindOfClass:[MZRefreshHeaderView class]], @"The refresh header view must be a subclass of MZRefreshHeaderView.");
        [refreshHeaderView containingScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSAssert([scrollView isKindOfClass:[MZCollectionView class]], @"This can only be the delegate of a MZCollectionView.");
    MZRefreshHeaderView *refreshHeaderView = [(MZCollectionView *)scrollView refreshHeaderView];
    if (refreshHeaderView) {
        NSAssert([refreshHeaderView isKindOfClass:[MZRefreshHeaderView class]], @"The refresh header view must be a subclass of MZRefreshHeaderView.");
        [refreshHeaderView containingScrollViewDidEndDragging:scrollView];
    }
}

@end
