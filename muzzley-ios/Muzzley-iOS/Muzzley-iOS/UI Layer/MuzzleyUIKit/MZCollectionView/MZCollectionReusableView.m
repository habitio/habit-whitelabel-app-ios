//
//  MZCollectionReusableView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionReusableView.h"

@interface MZCollectionReusableView ()
@property (nonatomic, assign, readwrite) BOOL sizingCell;
@end

@implementation MZCollectionReusableView
@synthesize sizingCell = _sizingCell;

- (instancetype)initWithFrame:(CGRect)frame
{
    NSString *cellNibName = NSStringFromClass([self class]);
    NSArray *resultantNib = [[NSBundle mainBundle] loadNibNamed:cellNibName owner:nil options:nil];
    
    if ([resultantNib count] > 0) {
        if ([[resultantNib objectAtIndex:0] isKindOfClass:[UICollectionReusableView class]]) {
            self = [resultantNib objectAtIndex:0];
            [self setFrame:frame];
            return self;
        }
    }
    return self = [super initWithFrame:frame];
}

#pragma mark - Applying a cell's model
- (void)setModel:(NSObject *)model { }

#pragma mark - Determining height of cells that use Auto Layout
- (CGSize)intrinsicContentSize {
    // force layout on cell view hierarchy using specified width
    // this makes sure any preferredMaxLayoutWidths, etc. are set
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // height computed based upon Auto Layout constraints in contentView
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    // Return which size is bigger since systemLayoutFittingSize will return
    // the smallest size fitting that fits.
    size.width = MAX(self.frame.size.width, size.width);
    // Return our size that was calculated
    return size;
}

- (void)setSizingCell:(BOOL)sizingCell
{
    _sizingCell = sizingCell;
}

@end
