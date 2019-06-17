//
//  MZRefreshControl.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshControl.h"

@interface MZRefreshControl ()
@property (nonatomic, weak) UIScrollView *scrollView;
@end

@implementation MZRefreshControl

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        
        if ([tableView isKindOfClass:[UITableView class]]) {
            self.scrollView = tableView;
            UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:tableView.style];
            tableViewController.tableView = tableView;
            tableViewController.refreshControl = self;
        }
    }
    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        
        if ([collectionView isKindOfClass:[UICollectionView class]]) {
            self.scrollView = collectionView;
            [self.scrollView addSubview:self];
            [self.scrollView sendSubviewToBack:self];
        }
    }
    return self;

}

- (void)beginRefreshing {
    [super beginRefreshing];
    
    if (self.scrollView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            self.scrollView.contentOffset = CGPointMake(0, -self.frame.size.height);
        } completion:^(BOOL finished){
            
        }];
    }
}

- (void)endRefreshing
{
    //__typeof__(self) __weak weakSelf = self;
    
    //[UIView animateWithDuration:0.2 animations:^{
    //    [weakSelf.scrollView layoutIfNeeded];
    //} completion:^(BOOL finished) {
        [super endRefreshing];
    
    //}];
}

@end
