//
//  MZPhotoAssetCell.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 21/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZThumbnailView.h"

@class MZPhotoAssetCell;

@protocol MZPhotoAssetCellSelectionDelegate <NSObject>

- (void)photoAssetCell:(MZPhotoAssetCell *)cell
  selectedPhotoAtIndex:(NSUInteger)index
       didChangedState:(MZThumbnailViewState)state;
@end

@interface MZPhotoAssetCell : UITableViewCell <MZThumbnailViewSelectionDelegate>

@property (nonatomic, strong, readonly) IBOutlet MZThumbnailView *thumb1;
@property (nonatomic, strong, readonly) IBOutlet MZThumbnailView *thumb2;
@property (nonatomic, strong, readonly) IBOutlet MZThumbnailView *thumb3;

@property (nonatomic, assign) NSUInteger numberOfThumbnails;
@property (nonatomic, assign) NSUInteger rowNumber;
@property (nonatomic, assign) NSUInteger sectionNumber;
@property (nonatomic, assign) id<MZPhotoAssetCellSelectionDelegate> selectionDelegate;

- (void)clearSelection;
- (void)resetThumbnails;

@end
