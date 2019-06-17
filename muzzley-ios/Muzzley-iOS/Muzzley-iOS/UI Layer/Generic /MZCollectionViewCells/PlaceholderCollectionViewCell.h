//
//  PlaceholderCollectionViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewCell.h"

@interface PlaceholderCollectionViewCellViewModel : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *imageTintColor;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@end

@class PlaceholderCollectionViewCell;
@protocol PlaceholderCollectionViewCellDelegate <MZCollectionViewCellDelegate>
- (void)placeholderCollectionViewCellDidSelectActionButton:(PlaceholderCollectionViewCell *)cell;
@end

@interface PlaceholderCollectionViewCell : MZCollectionViewCell
@property (nonatomic, weak) id<PlaceholderCollectionViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet MZInfoPlaceholderView *infoPlaceholderView;
@end
