//
//  : MZChannelsTableViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZChannelsTableViewCell.h"

#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"
#import "UIImage+RoundedCorner.h"

@implementation MZChannelsTableViewCell

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.channelImageView.layer.cornerRadius = self.channelImageView.frame.size.width / 2.0;
    self.channelImageView.layer.masksToBounds = YES;
    self.channelImageView.layer.borderColor = [UIColor muzzleyGrayColorWithAlpha:1].CGColor;
    self.channelImageView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.channelSelectedImageView.highlighted = selected;
}

@end
