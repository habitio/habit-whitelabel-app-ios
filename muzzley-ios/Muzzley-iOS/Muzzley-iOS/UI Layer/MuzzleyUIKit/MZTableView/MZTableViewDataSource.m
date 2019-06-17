//
//  MZTableViewDataSource.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewDataSource.h"
#import "MZTableViewDataSourceSubclass.h"

#import "MZRefreshHeaderViewPrivate.h"
#import "MZTableView.h"
#import "MZTableViewPrivate.h"
#import "MZTableViewCell.h"
#import "MZTableViewCellPrivate.h"
#import "MZExpandableTableViewCell.h"
#import "MZTableViewChildViewControllerCell.h"
#import "MZTableViewSectionHeaderFooterView.h"
#import "MZTableViewSectionHeaderFooterViewPrivate.h"

@implementation MZTableViewDataSource

#pragma mark Public Helpers

- (void)reloadVisibleCellForModel:(NSObject *)model inTableView:(UITableView *)tableView {
    for (NSIndexPath *indexPath in [tableView indexPathsForVisibleRows]) {
        if ([self tableView:tableView modelForCellAtIndexPath:indexPath] == model) {
            [(MZTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] setModel:model];
            return;
        }
    }
}

#pragma mark Configuration

- (void)tableView:(UITableView *)tableView configureCell:(MZTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    [cell setModel:[self tableView:tableView modelForCellAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView configureHeader:(MZTableViewSectionHeaderFooterView *)headerView forSection:(NSUInteger)section {
    headerView.position = section == 0 ? MZTableViewSectionHeaderFooterPositionFirstHeader : MZTableViewSectionHeaderFooterPositionHeader;
}

- (void)tableView:(UITableView *)tableView configureFooter:(MZTableViewSectionHeaderFooterView *)footerView forSection:(NSUInteger)section {
    footerView.position = (section == [tableView numberOfSections] - 1) ? MZTableViewSectionHeaderFooterPositionLastFooter : MZTableViewSectionHeaderFooterPositionFooter;
}

#pragma mark Reuse Identifiers

- (NSString *)tableView:(UITableView *)tableView reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Must have a reuse identifier for all rows.");
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView reuseIdentifierForHeaderInSection:(NSUInteger)section {
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView reuseIdentifierForFooterInSection:(NSUInteger)section {
    return nil;
}

#pragma mark Models

- (NSObject *)tableView:(UITableView *)tableView modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Must have a model for all rows.");
    return nil;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(NO, @"This is abstract.");
    return -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const reuseID = [self tableView:tableView reuseIdentifierForCellAtIndexPath:indexPath];
    NSAssert(reuseID != nil, @"Must have a reuse identifier.");
    MZTableViewCell *cell = (MZTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    [self tableView:tableView configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *const reuseID = [self tableView:tableView reuseIdentifierForHeaderInSection:section];
    
    if (reuseID == nil) {
        return nil;
    }
    
    MZTableViewSectionHeaderFooterView *headerView = (MZTableViewSectionHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseID];
    headerView.sizingView = NO;
    [self tableView:tableView configureHeader:headerView forSection:section];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *const reuseID = [self tableView:tableView reuseIdentifierForFooterInSection:section];
    
    if (reuseID == nil) {
        return nil;
    }
    
    MZTableViewSectionHeaderFooterView *footerView = (MZTableViewSectionHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseID];
    footerView.sizingView = NO;
    [self tableView:tableView configureFooter:footerView forSection:section];
    return footerView;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert([tableView isKindOfClass:[MZTableView class]], @"This can only be the delegate of a MZTableView.");
    
    NSString *const reuseID = [self tableView:tableView reuseIdentifierForCellAtIndexPath:indexPath];
    MZTableViewCell *cell = [(MZTableView *)tableView sizingCellForReuseIdentifier:reuseID];
    
    if (![cell isKindOfClass:[MZExpandableTableViewCell class]]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            return UITableViewAutomaticDimension;
        }
    }
    
    [self tableView:tableView configureCell:cell forIndexPath:indexPath];
    
    return [cell heightForWidth:CGRectGetWidth(tableView.bounds) separatorStyle:tableView.separatorStyle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSAssert([tableView isKindOfClass:[MZTableView class]], @"This can only be the delegate of a MZTableView.");
    
    NSString *const reuseID = [self tableView:tableView reuseIdentifierForHeaderInSection:section];
    if (reuseID) {
        MZTableViewSectionHeaderFooterView *headerView = [(MZTableView *)tableView sizingHeaderFooterViewForReuseIdentifier:reuseID];
        headerView.sizingView = YES;
        [self tableView:tableView configureHeader:headerView forSection:section];
        return [headerView heightForWidth:CGRectGetWidth(tableView.bounds)];
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSAssert([tableView isKindOfClass:[MZTableView class]], @"This can only be the delegate of a MZTableView.");
    
    NSString *const reuseID = [self tableView:tableView reuseIdentifierForFooterInSection:section];
    if (reuseID) {
        MZTableViewSectionHeaderFooterView *footerView = [(MZTableView *)tableView sizingHeaderFooterViewForReuseIdentifier:reuseID];
        footerView.sizingView = YES;
        [self tableView:tableView configureFooter:footerView forSection:section];
        return [footerView heightForWidth:CGRectGetWidth(tableView.bounds)];
    } else {
        return UITableViewAutomaticDimension;
    }
}

#pragma mark ChildViewController support

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *parentViewController = self.parentViewController;
    if ([cell conformsToProtocol:@protocol(MZTableViewChildViewControllerCell)]) {
        NSAssert(parentViewController != nil, @"Must have a parent view controller to support cell %@", cell);
        UITableViewCell<MZTableViewChildViewControllerCell> *viewControllerCell = (UITableViewCell<MZTableViewChildViewControllerCell> *)cell;
        UIViewController *childViewController = [viewControllerCell childViewController];
        [parentViewController addChildViewController:childViewController];
        [childViewController didMoveToParentViewController:parentViewController];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(MZTableViewChildViewControllerCell)]) {
        NSAssert(self.parentViewController != nil, @"Must have a parent view controller to support cell %@", cell);
        UITableViewCell<MZTableViewChildViewControllerCell> *viewControllerCell = (UITableViewCell<MZTableViewChildViewControllerCell> *)cell;
        UIViewController *childViewController = [viewControllerCell childViewController];
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
    }
}

#pragma mark UIScrollViewDelegate

// NOTE: The following methods inform a refresh header view of the scrolling behavior of the tableview.  This makes our refresh headers work.

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSAssert([scrollView isKindOfClass:[MZTableView class]], @"This can only be the delegate of a MZTableView.");
    MZRefreshHeaderView *refreshHeaderView = [(MZTableView *)scrollView refreshHeaderView];
    if (refreshHeaderView) {
        NSAssert([refreshHeaderView isKindOfClass:[MZRefreshHeaderView class]], @"The refresh header view must be a subclass of MZRefreshHeaderView.");
        [refreshHeaderView containingScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSAssert([scrollView isKindOfClass:[MZTableView class]], @"This can only be the delegate of a MZTableView.");
    MZRefreshHeaderView *refreshHeaderView = [(MZTableView *)scrollView refreshHeaderView];
    if (refreshHeaderView) {
        NSAssert([refreshHeaderView isKindOfClass:[MZRefreshHeaderView class]], @"The refresh header view must be a subclass of MZRefreshHeaderView.");
        [refreshHeaderView containingScrollViewDidEndDragging:scrollView];
    }
}

@end
