//
//  ChannelProfileTableViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZTableViewCellChannelProfile.h"

@implementation MZTableViewCellChannelProfile

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.channelSelectionView.hidden = !selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.channelSelectionView.hidden = !highlighted;
}

@end
