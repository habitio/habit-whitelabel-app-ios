//
//  MZRefreshHeaderViewPrivate.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshHeaderView.h"
#import "MZRefreshHeaderViewSubclass.h"

//! Methods used by MZTableViewDataSource and MZTableView to make the refresh header work.
@interface MZRefreshHeaderView ()

//! The scroll view that this refresh header is at the top of.
@property (weak, nonatomic) UIScrollView *scrollView;

//! Called from scrollViewDidScroll: to update the refresh header
- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView;

//! Called from scrollViewDidEndDragging: to potentially start the refresh
- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView;

@end