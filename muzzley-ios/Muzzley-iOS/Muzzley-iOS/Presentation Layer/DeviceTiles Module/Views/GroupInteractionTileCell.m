//
//  GroupInteractionTileCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "GroupInteractionTileCell.h"

@interface GroupInteractionTileCell ()
@property (weak, nonatomic) IBOutlet UIView *selectionBar;
@property (weak, nonatomic) IBOutlet UIView *separatorBar;
@property(nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundHeight;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation GroupInteractionTileCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.backgroundHeight.constant = 70.f;
    _selectionBar.hidden =
    _separatorBar.hidden = YES;
    self.titleLabel.textColor = [UIColor muzzleyGray4ColorWithAlpha:1.0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CALayer *layer = self.backgroundImageView.layer;
    
    //layer.cornerRadius = CORNER_RADIUS;
    //cardLayer.masksToBounds = YES;
    layer.shadowOffset = CGSizeMake(0, 1);
    layer.shadowOpacity = 0.2;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 1;
    layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds cornerRadius:self.backgroundImageView.bounds.size.width * 0.5] CGPath];
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.shouldRasterize = YES;
    
    [super layoutSubviews];
}

- (void)setModel:(GroupInteractionTileViewModel *)model {
    NSAssert([model isKindOfClass:[GroupInteractionTileViewModel class]], @"Must use %@ with %@", NSStringFromClass([GroupInteractionTileViewModel class]), NSStringFromClass([self class]));
    self.backgroundImageView.image = [UIImage imageNamed:model.iconName];
    self.titleLabel.text = model.title;

    self.titleLabel.font = [self.titleLabel.font fontWithSize:model.isDetail ? 12.f : 17.f];
    self.backgroundHeight.constant = model.isDetail ? 58.f : 70.f;
    self.selectionBar.hidden =
    self.separatorBar.hidden = !model.isDetail;
    self.selectionBar.backgroundColor = model.isSelected ? [UIColor muzzleyBlueColorWithAlpha:1.f] : [UIColor muzzleyGray4ColorWithAlpha:1.f];
    self.titleLabel.textColor = model.isDetail && model.isSelected ? [UIColor muzzleyBlueColorWithAlpha:1.f] : [UIColor muzzleyGray4ColorWithAlpha:1.f];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
@end
