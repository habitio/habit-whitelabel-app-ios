//
//  MZCollectionViewDataSourcePrivate.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewDataSource.h"

@class MZCollectionViewCell;
@class MZCollectionReusableView;

@interface MZCollectionViewDataSource ()

#pragma mark Abstract methods

//! Abstract method – must be handled by subclass. Return the reuse identifier for the given indexPath.
- (NSString *)collectionView:(UICollectionView *)collectionView reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;

//! Abstract method – must be handled by subclass. The returned model will be passed to the cell for indexPath.
- (NSObject *)collectionView:(UICollectionView *)collectionView modelForCellAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Optional Methods

/*!
 * Return the reuse identifier for the given reusable view. By default, returns nil, in which case, no reusable view is created.
 */
- (NSString *)collectionView:(UICollectionView *)collectionView reuseIdentifierForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (NSObject *)collectionView:(UICollectionView *)collectionView modelForReusableView:(MZCollectionReusableView *)reusableView atIndexPath:(NSIndexPath *)indexPath;
/*!
 * Configure cell for display of the content in indexPath – gets the model for indexPath and then calls setModel on cell.
 *
 * Override this method if you need to do cell-specific configuration (for example, alternating background colors) but call super implementation first.
 */
- (void)collectionView:(UICollectionView *)collectionView configureCell:(MZCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

//! Override this method to configure a reusable View to display content but call super implementation first.
- (void)collectionView:(UICollectionView *)collectionView configureReusableView:(MZCollectionReusableView *)reusableView forIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;
@end
