//
//  MZRefreshControl.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZRefreshControl : UIRefreshControl

- (instancetype)initWithTableView:(UITableView *)tableView;
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
@end