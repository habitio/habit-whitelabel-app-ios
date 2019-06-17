//
//  MZRefreshHeaderViewSubclass.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshHeaderView.h"

@interface MZRefreshHeaderView ()

//! The current state of the refresh header. The header should update its view as needed for the different states. If you override this method, you must call super.
@property (assign, nonatomic) MZRefreshHeaderViewState refreshState;

//! Start / stop the refreshing animation in the given scroll view.
- (void)setRefreshState:(MZRefreshHeaderViewState)refreshState animated:(BOOL)animated NS_REQUIRES_SUPER;

//! The current distance that the refresh header is being pulled. Will be updated as the user pulls the page down. Animations should be updated as this number changes.
@property (assign, nonatomic) CGFloat currentPullAmount;

//! The distance the user will have to pull the header to trigger a refresh. Abstract method.
@property (readonly, assign, nonatomic) CGFloat pullAmountToRefresh;

@end

