//
//  ChannelActionsBar.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/5/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditActionsBar;
@protocol EditActionsBarDelegate <NSObject>

- (void)barDidSelectCancelAction:(EditActionsBar *)bar;
- (void)barDidSelectDeleteAction:(EditActionsBar *)bar;
- (void)barDidSelectEditAction:(EditActionsBar *)bar;

@end

@interface EditActionsBar : UIView
@property (nonatomic, weak) id<EditActionsBarDelegate> delegate;

@property (nonatomic, assign) BOOL editEnabled; // Default = YES
@property (nonatomic, assign) BOOL deleteEnabled; // Default = YES

- (void)setSelectedCount:(NSUInteger)count;
@end
