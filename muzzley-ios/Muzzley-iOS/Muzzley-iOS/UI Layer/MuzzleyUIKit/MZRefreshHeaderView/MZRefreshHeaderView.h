//
//  MZRefreshHeaderControl.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MZRefreshHeaderViewState) {
    MZRefreshHeaderViewStateNormal = 0, // No refresh is currently happening. The user might have pulled the header down a bit, but not enough to trigger a refresh.
    MZRefreshHeaderViewStateReadyToRefresh, // The user has pulled down the header far enough to trigger a refresh, but has not released yet.
    MZRefreshHeaderViewStateRefreshing, // Refreshing, either after the user pulled to refresh or a refresh was started programmatically.
    MZRefreshHeaderViewStateClosing, // The refresh has just finished and the refresh header is in the process of closing.
};

//! Abstract class used for refresh header views. See MZRefreshHeaderViewSubclass for the abstract methods you'll need to implement. MZTableView will call those methods automatically. Add a target for the UIControlEventValueChanged event to refresh the table view.
@interface MZRefreshHeaderView : UIControl

@end
