//
//  MZRefreshableCollectionViewControllerSubclass.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshableCollectionViewController.h"

@interface MZRefreshableCollectionViewController ()

//! You don't need to implement this, but make sure to call super if you do.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

//! You don't need to implement this, but make sure to call super if you do.
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate NS_REQUIRES_SUPER;
@end