//
//  MZLightBorderButton.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZLightBorderButton.h"
@import Hex;

@implementation MZLightBorderButton

- (instancetype)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    [super _init];
    self.defaultBackgroundColor = [UIColor whiteColor];
    self.highlightBackgroundColor = [UIColor colorWithWhite:0 alpha:0.03];
    [self setTitleColor:[[UIColor alloc] initWithHex:@"99A7AA"] forState:UIControlStateNormal];
    [self setBorderColor:[[UIColor alloc] initWithHex:@"E0E4E5"]];
    self.borderWidth = 1;
    
    self.tintColor = self.titleLabel.textColor;
    
    [self setImage:nil];
    [self setHighlighted:NO];
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    
    if (image) {
        [self setContentEdgeInsets:UIEdgeInsetsMake(5,10,5,16)];
    } else {
        [self setContentEdgeInsets:UIEdgeInsetsMake(5,16,5,16)];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
@end
