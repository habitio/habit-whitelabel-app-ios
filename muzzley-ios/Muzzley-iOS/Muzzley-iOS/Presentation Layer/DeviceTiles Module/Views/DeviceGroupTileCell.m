//
//  DeviceGroupTileCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/10/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "DeviceGroupTileCell.h"

#import "MZTriStateToggle.h"
#import "DeviceTileRefreshView.h"
#import "DeviceTileProblemView.h"

@interface DeviceGroupTileCell () <UIGestureRecognizerDelegate>
// Views
@property (nonatomic, weak) IBOutlet UIView *cardContentView;
@property (nonatomic, weak) IBOutlet UIView *firstItemView;
@property (nonatomic, weak) IBOutlet UIView *firstItemImageView;
@property (nonatomic, weak) IBOutlet UIView *secondItemImageView;
@property (nonatomic, weak) IBOutlet UIView *thirdItemImageView;
@property (nonatomic, strong) NSArray *itemsImageView;

@property (nonatomic, weak) IBOutlet UIView *fadeImageView;

@property (nonatomic, weak) IBOutlet UILabel *tileMoreItemsLabel;
@property (nonatomic, weak) IBOutlet UILabel *tileDescriptionLabel;

@property (nonatomic, weak) IBOutlet MZTriStateToggle *toggle;

@property (nonatomic, weak) IBOutlet DeviceTileRefreshView *refreshView;
@property (nonatomic, weak) IBOutlet DeviceTileProblemView *problemView;
// Layout Constraints
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstItemImageTrailingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondItemImageTrailingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondItemHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thirdItemHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thirdItemTopSpaceConstraint;
// UIGestureRecognizer
@property (nonatomic, assign) NSUInteger numberOfItems;
@property (nonatomic, assign) NSUInteger maxVisibleItems;
@end

@implementation DeviceGroupTileCell

- (void)awakeFromNib {
    
    CALayer *cardLayer = self.cardContentView.layer;
    cardLayer.cornerRadius = CORNER_RADIUS;
    cardLayer.masksToBounds = YES;
    
    self.itemsImageView = @[self.firstItemImageView, self.secondItemImageView, self.thirdItemImageView];
    self.maxVisibleItems = 3;
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
    CALayer *selfLayer = self.layer;
    selfLayer.shadowOffset = CGSizeMake(0, 0.5);
    selfLayer.shadowOpacity = 0.2;
    selfLayer.shadowColor = [[UIColor blackColor] CGColor];
    selfLayer.shadowRadius = 1;
    selfLayer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cardContentView.layer.cornerRadius] CGPath];
    selfLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    selfLayer.shouldRasterize = YES;
    
    // Update layout constraint
    self.firstItemImageTrailingConstraint.constant = -self.firstItemView.frame.size.width;
    
    if (self.numberOfItems == 2) {
        self.secondItemImageTrailingConstraint.constant = -self.firstItemView.frame.size.width;
        self.thirdItemTopSpaceConstraint.constant = 0;
        self.thirdItemHeightConstraint.constant = 0;
    } else {
        
        self.secondItemImageTrailingConstraint.constant = 0;
        self.thirdItemTopSpaceConstraint.constant = 3;
        CGFloat firstItemHeight = self.firstItemView.frame.size.height;
        CGFloat thirdItemHeight = (firstItemHeight - self.thirdItemTopSpaceConstraint.constant) / 2;
        self.thirdItemHeightConstraint.constant = thirdItemHeight;
    }
    
    [super layoutSubviews];
}

- (void)prepareForReuse {
    self.tileMoreItemsLabel.text = @"";
    self.tileDescriptionLabel.text = @"";
    [self.toggle setState:MZTriStateToggleStateUnknown animated:NO];
    for (UIImageView *imageView in self.itemsImageView) {
        [imageView cancelImageDownloadTask];
        imageView.image = nil;
    }
}

- (void)setModel:(MZTileGroupViewModel *)model {
    NSAssert([model isKindOfClass:[MZTileGroupViewModel class]], @"Must use %@ with %@", NSStringFromClass([MZTileGroupViewModel class]), NSStringFromClass([self class]));
    
    MZTileGroupViewModel *groupTileViewModel = model;
    self.numberOfItems = groupTileViewModel.tilesViewModel.count;
    
    NSString *moreItemsDescription = @"";
    if (self.numberOfItems > self.maxVisibleItems) {
        moreItemsDescription = [NSString stringWithFormat:@"+%lu", (unsigned long)(self.numberOfItems - self.maxVisibleItems)];
    }
    self.tileMoreItemsLabel.text = moreItemsDescription;
    self.tileDescriptionLabel.text = groupTileViewModel.title;
    
    //TODO to similar to tilecell, use a base
    if (model.tileActionViewModel != nil)
    {
        self.toggle.hidden = NO;
        MZTriStateToggleState toggleState = MZTriStateToggleStateUnknown;
        if (groupTileViewModel.tileActionViewModel.state == TileActionViewModelStateOn ) {
            toggleState = MZTriStateToggleStateOn;
        } else if (groupTileViewModel.tileActionViewModel.state == TileActionViewModelStateOff) {
            toggleState = MZTriStateToggleStateOff;
        }
        [self.toggle setState:toggleState animated:YES];
    } else {
        self.toggle.hidden = YES;
    }
    
    for (UIImageView *imageView in self.itemsImageView) {
        [imageView cancelImageDownloadTask];
        imageView.image = nil;
    }
    NSArray *deviceTilesViewModel = groupTileViewModel.tilesViewModel;
    for (NSUInteger i = 0; i < self.numberOfItems; i++) {
        if (i == self.maxVisibleItems) { break; };
        
        MZTileViewModel *deviceTileViewModel = deviceTilesViewModel[i];
        UIImageView *imageView = self.itemsImageView[i];
        [imageView setImageWithURL:deviceTileViewModel.imageURL];
    }
    
    self.refreshView.hidden = groupTileViewModel.state != TileStateLoading;
    self.problemView.hidden = groupTileViewModel.state != TileStateError;
    
    groupTileViewModel.refreshViewModel.animating = groupTileViewModel.state == TileStateLoading;
    
    [self.refreshView renderWithModel:groupTileViewModel.refreshViewModel];
    [self.problemView renderWithModel:groupTileViewModel.problemViewModel];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
