//
//  MZTableViewCellImg.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 9/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZTableViewCellImg.h"

#import "UIImageView+AFNetworking.h"

@interface MZTableViewCellImg ()

@end

@implementation MZTableViewCellImg

- (void)awakeFromNib {
    // Initialization code
    self.centralImageView.layer.cornerRadius = self.centralImageView.bounds.size.width * 0.5;
    self.centralImageView.layer.masksToBounds = YES;
    self.centralImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.centralImageView.layer.shouldRasterize = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) { self.centralImageView.alpha = 0.3; }
    else { self.centralImageView.alpha = 1.0; }
}

- (void)setPlaceholderBackgroundColor:(UIColor *)color
{
    self.centralImageView.backgroundColor = color;
}

- (void)setupWithImageURL:(NSURL *)imageUrl
{
    [self.centralImageView cancelImageDownloadTask];
    self.centralImageView.image = nil;
    
    if ([imageUrl isKindOfClass:[NSURL class]]) {
        [self.centralImageView setImage:imageUrl];
    }
}


@end
