//
//  MZCollectionView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZCollectionViewCell;
@class MZCollectionReusableView;
@class MZRefreshHeaderView;

typedef NS_ENUM(NSInteger, MZCollectionViewState) {
    MZCollectionViewStateLoading = 0, // Initial loading state. Pull to refresh header will not show.
    MZCollectionViewStateLoaded, // Normal state. Nothing is currently loading.
    MZCollectionViewStateRefreshing, // Refreshing after a pull-to-refresh. The refreshHeaderView will be showing.
    MZCollectionViewStateErrored, // Network request errored.
};

@interface MZCollectionView : UICollectionView
//! If you want to use a refresh header, set this to a subclass of MZRefreshHeaderView
@property (strong, nonatomic) MZRefreshHeaderView *refreshHeaderView;
//! The current state of the table view. Will update the state of the refresh header as needed.
@property (assign, nonatomic) MZCollectionViewState state;

//! Returns a cached cell for this reuse identifier. The cell should only be used for sizing purposes, not for display.
- (MZCollectionViewCell *)sizingCellForReuseIdentifier:(NSString *)reuseIdentifier;

//! Returns a cached reusable view for this reuse identifier. The view should only be used for sizing purposes, not for display.
- (MZCollectionReusableView *)sizingReusableViewForReuseIdentifier:(NSString *)reuseIdentifier;
@end