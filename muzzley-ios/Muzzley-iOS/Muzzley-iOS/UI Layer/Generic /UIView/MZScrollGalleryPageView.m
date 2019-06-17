//
//  MZScrollGalleryCellView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZScrollGalleryPageView.h"

@implementation MZScrollGalleryPageView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        
        CGFloat margin = 20;
        
        // Decription Label Creation
        self.descriptionLabel = [[UILabel alloc] initWithFrame:
            CGRectMake(margin,
                       self.bounds.size.height - 60,
                       self.bounds.size.width - (margin * 2),
                       60)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        // Title Label Creation
        self.titleLabel = [[UILabel alloc] initWithFrame:
            CGRectMake(margin,
                       self.descriptionLabel.frame.origin.y - 25,
                       self.bounds.size.width - (margin * 2),
                       25)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        // UIImageView Creation
        self.imageView = [[UIImageView alloc] initWithFrame:
            CGRectMake(margin,
                       self.titleLabel.frame.origin.y - 200,
                       self.bounds.size.width - (margin * 2),
                       165)];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.clipsToBounds = NO;
        
        // Add to super view
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.descriptionLabel];
        
        
        //self.imageView.backgroundColor = [UIColor yellowColor];
        //self.titleLabel.backgroundColor = [UIColor greenColor];
        //self.descriptionLabel.backgroundColor = [UIColor blueColor];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat viewCenterX = self.bounds.size.width * 0.5;
    
    self.imageView.center = CGPointMake(viewCenterX, self.bounds.size.height * 0.5 - 15);
    self.titleLabel.center = CGPointMake(viewCenterX, self.imageView.center.y + 85);
    self.descriptionLabel.center = CGPointMake(viewCenterX, self.titleLabel.center.y + 40);
}
@end
