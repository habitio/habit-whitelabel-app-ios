//
//  MZTableViewChildViewControllerCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

//! Implement this protocol in a MZTableViewCell subclass to use a child view controller inside of a table view cell. The MZTableViewDataSource subclass must have something set as the parentViewController property.
@protocol MZTableViewChildViewControllerCell <NSObject>

//! This method should return the view controller managed by the cell so that it can be properly connected with its parent.
@property (readonly, nonatomic) UIViewController *childViewController;

@end
