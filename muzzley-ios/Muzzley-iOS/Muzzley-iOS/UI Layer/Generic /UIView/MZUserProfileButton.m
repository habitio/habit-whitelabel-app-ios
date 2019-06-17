//
//  MZUserProfileButton.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZUserProfileButton.h"

@implementation MZUserProfileButton

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"highlighted"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObservers];
        [self layoutCustomSubviews];
    }
    return self;
}

- (void)awakeFromNib
{
    [self addObservers];
    [self layoutCustomSubviews];
}

- (void)layoutCustomSubviews
{
    
    // Allow default layout, then adjust image and label positions
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    CGFloat spacing = 10;
    CGFloat insetAmount = spacing * 0.5;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
   
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.3] forState:UIControlStateHighlighted];
    
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15];
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

- (void)addObservers
{
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.highlighted) {
        self.imageView.alpha = 0.3;
    } else {
        self.imageView.alpha = 1.0;
    }
}
@end
