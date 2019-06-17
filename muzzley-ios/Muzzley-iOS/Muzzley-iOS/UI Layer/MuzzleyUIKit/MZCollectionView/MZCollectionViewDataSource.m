//
//  MZCollectionViewDataSource.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewDataSource.h"
#import "MZCollectionViewDataSourceSubclass.h"

#import "MZCollectionView.h"
#import "MZCollectionViewCellPrivate.h"
#import "MZCollectionReusableViewPrivate.h"
#import "MZRefreshHeaderViewPrivate.h"

@interface MZCollectionViewDataSource ()
@property (nonatomic, weak, readwrite) MZCollectionView * collectionView;
@end

@implementation MZCollectionViewDataSource

- (instancetype)initWithCollectionView:(MZCollectionView *)collectionView {
    if (self = [super init]) {
        self.collectionView = collectionView;
    }
    return self;
}

#pragma mark - Public Helpers
- (void)reloadVisibleCellForModel:(NSObject *)model inCollectionView:(UICollectionView *)collectionView {
    for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleItems]) {
        if ([self collectionView:collectionView modelForCellAtIndexPath:indexPath] == model) {
            [(MZCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] setModel:model];
            return;
        }
    }
}

- (void)reloadVisibleReusableViewForModel:(NSObject *)model inCollectionView:(UICollectionView *)collectionView {
    /*for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleItems]) {
        if ([self collectionView:collectionView modelForCellAtIndexPath:indexPath] == model) {
            [(MZCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] setModel:model];
            return;
        }
    }*/
}

#pragma mark - Configuration
- (void)collectionView:(UICollectionView *)collectionView configureCell:(MZCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSObject *model = [self collectionView:collectionView modelForCellAtIndexPath:indexPath];
    [cell setModel:model];
}

- (void)collectionView:(UICollectionView *)collectionView configureReusableView:(MZCollectionReusableView *)reusableView forIndexPath:(NSIndexPath *)indexPath {
    NSObject *model = [self collectionView:collectionView modelForReusableView:reusableView atIndexPath:indexPath];
    [reusableView setModel:model];
}

#pragma mark - Reuse Identifiers
- (NSString *)collectionView:(UICollectionView *)collectionView reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Must have a reuse identifier for all rows.");
    return nil;
}

- (NSString *)collectionView:(UICollectionView *)collectionView reuseIdentifierForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Must have a reuse identifier for all supplementary views.");
    return nil;
}

#pragma mark -  Models
- (NSObject *)collectionView:(UICollectionView *)collectionView modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Must have a model for all rows.");
    return nil;
}

- (NSObject *)collectionView:(UICollectionView *)collectionView modelForReusableView:(MZCollectionReusableView *)reusableView atIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Must have a model for all supplementary views.");
    return nil;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(NO, @"This is abstract.");
    return -1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *const reuseID = [[[self collectionView:collectionView reuseIdentifierForCellAtIndexPath:indexPath] componentsSeparatedByString:@"."] lastObject];
    NSAssert(reuseID != nil, @"Must have a reuse identifier.");
    
    MZCollectionViewCell *cell = (MZCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    [self collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *const reuseID = [self collectionView:collectionView reuseIdentifierForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    NSAssert(reuseID != nil, @"Must have a reuse identifier.");
    
    MZCollectionReusableView *reusableView = (MZCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseID forIndexPath:indexPath];
    [self collectionView:collectionView configureReusableView:reusableView forIndexPath:indexPath];
    return reusableView;
}

@end
