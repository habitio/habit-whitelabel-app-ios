//
//  NoInternetCollectionViewDataSource.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "NoInternetCollectionViewDataSource.h"
@import Hex;

@implementation NoInternetCollectionViewDataSource

#pragma mark MZCollectionViewDataSource subclass
- (NSString *)collectionView:(UICollectionView *)collectionView reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    return NSStringFromClass([PlaceholderCollectionViewCell class]);
}

- (NSObject *)collectionView:(UICollectionView *)collectionView modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    PlaceholderCollectionViewCellViewModel *viewModel = [PlaceholderCollectionViewCellViewModel new];
    
    /*[self.infoPlaceholderView.actionButton setTitle:@"Reload"];
    [self.infoPlaceholderView.actionButton removeTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [self.infoPlaceholderView.actionButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    */
    viewModel.image = [[UIImage imageNamed:@"IconNoWifi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    viewModel.imageTintColor = [[UIColor alloc] initWithHex:@"BCCED2"];
    
    viewModel.title = NSLocalizedString(@"mobile_no_internet_title", @"");
    viewModel.message = NSLocalizedString(@"mobile_no_internet_text", @"");
    return viewModel;
}

#pragma mark - MZCollectionViewDataSouce
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

@end
