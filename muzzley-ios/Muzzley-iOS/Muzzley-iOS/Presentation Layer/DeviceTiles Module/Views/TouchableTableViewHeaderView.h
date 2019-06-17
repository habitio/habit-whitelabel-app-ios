//
//  TouchableTableViewHeaderView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/5/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchableTableViewHeaderView;
@protocol TouchableTableViewHeaderViewDelegate <NSObject>

- (void)tableViewHeaderWasTapped:(TouchableTableViewHeaderView*)header;
@end

@interface TouchableTableViewHeaderView : UITableViewHeaderFooterView
@property (nonatomic, weak) id<TouchableTableViewHeaderViewDelegate> delegate;
@property (nonatomic) NSInteger index;

- (void)applyUIStyle;

@end
