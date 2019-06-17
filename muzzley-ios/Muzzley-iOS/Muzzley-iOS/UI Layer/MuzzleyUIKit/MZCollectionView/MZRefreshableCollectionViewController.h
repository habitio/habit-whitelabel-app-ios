//
//  MZRefreshableScrollViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

@class MZCollectionView;

@interface MZRefreshableCollectionViewController : BaseViewController
<
UIScrollViewDelegate
>

@property (nonatomic) MZCollectionView *collectionView;
@end
