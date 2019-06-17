//
//  NoInternetTableViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "PlaceholderTableViewCell.h"
@interface PlaceholderTableViewCell ()
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@end

@implementation PlaceholderTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self.iconView setTintColor:[UIColor clearColor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width;
    self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.frame.size.width;
    
    [super layoutSubviews];
}

- (void)setIconImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconView.image = image;
}

- (void)setIconTintColor:(UIColor *)color
{
    [self.iconView setTintColor:color];
}

- (void)setTitleString:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setDescriptionString:(NSString *)description
{
    self.descriptionLabel.text = description;
}

@end
