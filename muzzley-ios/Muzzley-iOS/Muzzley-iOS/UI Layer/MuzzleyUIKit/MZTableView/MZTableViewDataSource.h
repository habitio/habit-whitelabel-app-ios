//
//  MZTableViewDataSource.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

//! If one of model's properties has changed (but it's still the same object), this will reload the visible cell for that model. Useful whenever something mutates the state of a model (i.e. image loading)
- (void)reloadVisibleCellForModel:(NSObject *)model inTableView:(UITableView *)tableView;

//! Set as the parent view controller of any cells implementing MZTableViewChildViewControllerCell.
@property (weak, nonatomic) UIViewController *parentViewController;

@end
