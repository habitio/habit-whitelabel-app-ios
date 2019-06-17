//
//  MZCollectionViewDataSource.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MZCollectionView.h"

@interface MZCollectionViewDataSource : NSObject
<
UICollectionViewDataSource
>

@property (nonatomic, weak, readonly) MZCollectionView * collectionView;

- (instancetype)initWithCollectionView:(MZCollectionView *)collectionView;

//! If one of model's properties has changed (but it's still the same object), this will reload the visible cell for that model. Useful whenever something mutates the state of a model (i.e. image loading)
- (void)reloadVisibleCellForModel:(NSObject *)model inCollectionView:(MZCollectionView *)collectionView;
//- (void)reloadVisibleReusableViewForModel:(NSObject *)model inCollectionView:(UICollectionView *)collectionView;
@end
