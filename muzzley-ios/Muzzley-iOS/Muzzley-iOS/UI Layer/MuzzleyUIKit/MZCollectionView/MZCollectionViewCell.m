//
//  MZCollectionViewcell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewCell.h"

@interface MZCollectionViewCell ()
@property (nonatomic, assign, readwrite) BOOL sizingCell;
@end

@implementation MZCollectionViewCell

@synthesize sizingCell = _sizingCell;

- (instancetype)initWithFrame:(CGRect)frame
{
    NSString *cellNibName = NSStringFromClass([self class]);
    NSArray *resultantNib = [[NSBundle mainBundle] loadNibNamed:cellNibName owner:nil options:nil];
    
    if ([resultantNib count] > 0) {
        if ([[resultantNib objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            self = [resultantNib objectAtIndex:0];
            [self setFrame:frame];
            return self;
        }
    }
    return self = [super initWithFrame:frame];
}

- (void)setNeedsContentViewLayout {
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

#pragma mark - Applying a cell's model
- (void)setModel:(NSObject *)model { }

/*!
 * Returns contentView's size based upon Auto Layout constraints.
 */
// Determine size. If your constraints aren't setup correctly
// this won't work. So make sure you:
//
// 1. Set ContentCompressionResistancePriority for all labels
//    i.e. [self.label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
//
// 2. Set PreferredMaxLayoutWidth for all labels that will have a
//    auto height. This should equal width of cell minus any buffers on sides.
//    i.e self.label.preferredMaxLayoutWidth = defaultSize - buffers;
//
// 3. Set any imageView's images correctly. Remember if you don't
//    set a fixed width/height on a UIImageView it will use the 1x
//    intrinsic size of the image to calculate a constraint. So if your
//    image isn't sized correctly it will produce an incorrect value.
//
#pragma mark - Determining height of cells that use Auto Layout
- (CGSize)intrinsicContentSize {
    // force layout on cell view hierarchy using specified width
    // this makes sure any preferredMaxLayoutWidths, etc. are set
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // height computed based upon Auto Layout constraints in contentView
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
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

