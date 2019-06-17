//
//  MZScrollGalleryView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

@class MZScrollGalleryView;
@class MZScrollGalleryPageView;
@protocol MZScrollGalleryViewDataSource <NSObject>

@required
- (NSUInteger)numberOfPagesInScrollGalleryView:(MZScrollGalleryView *)scrollGalleryView;

- (MZScrollGalleryPageView *)scrollGalleryView:(MZScrollGalleryView *)scrollGalleryView pageAtIndex:(NSUInteger)index;

@end


@protocol MZScrollGalleryViewDelegate <NSObject>

@optional
- (void)scrollGalleryView:(MZScrollGalleryView *)scrollGalleryView didScrollWithOffset:(CGPoint)offset;

@end


@class DDPageControl;
@interface MZScrollGalleryView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<MZScrollGalleryViewDataSource>dataSource;
@property (nonatomic, weak) id<MZScrollGalleryViewDelegate>delegate;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DDPageControl *pageControl;

- (void)reloadData;

@end
