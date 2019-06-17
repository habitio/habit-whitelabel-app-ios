//
//  MZTableView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZTableViewCell;
@class MZTableViewSectionHeaderFooterView;
@class MZRefreshHeaderView;

typedef NS_ENUM(NSInteger, MZTableViewState) {
    MZTableViewStateLoading = 0, // Initial loading state. Pull to refresh header will not show.
    MZTableViewStateLoaded, // Normal state. Nothing is currently loading.
    MZTableViewStateRefreshing, // Refreshing after a pull-to-refresh. The refreshHeaderView will be showing.
    MZTableViewStateErrored, // Network request errored.
};

@interface MZTableView : UITableView

//! If you want to use a refresh header, set this to a subclass of MZRefreshHeaderView
@property (strong, nonatomic) MZRefreshHeaderView *refreshHeaderView;

//! The current state of the table view. Will update the state of the refresh header as needed.
@property (assign, nonatomic) MZTableViewState state;

@end
