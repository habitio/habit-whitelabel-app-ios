//
//  MZThumbnailView.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 21/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MZThumbnailViewStateDeselected  = 1,
    MZThumbnailViewStateSelected    = 2,
} MZThumbnailViewState;

typedef enum : NSUInteger {
    MZThumbnailViewTypeImage  = 1,
    MZThumbnailViewTypeVideo  = 2,
} MZThumbnailViewType;

@class MZThumbnailView;

@protocol MZThumbnailViewSelectionDelegate <NSObject>
- (void)thumbnail:(MZThumbnailView *)thumbnailView didChangeState:(MZThumbnailViewState)state;
@end

@interface MZThumbnailView : UIImageView

@property(nonatomic, strong, readonly) UIView *highlightView;
@property(nonatomic, strong, readonly) UIImageView *checkImageView;
@property (nonatomic, strong, readonly) UIImageView *mediaTypeImageInternalView;
@property (nonatomic, strong, readonly) UIImageView *mediaTypeVideoInternalView;

@property(nonatomic, assign) MZThumbnailViewState state;
@property(nonatomic, assign) MZThumbnailViewType type;

@property(nonatomic, weak) id<MZThumbnailViewSelectionDelegate> delegate;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)reset;

@end
