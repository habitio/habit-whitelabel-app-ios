//
//  MZColorButton.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZColorButton.h"
@import Hex;

@implementation MZColorButton

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
    
    [self setExclusiveTouch:YES];
    
    self.borderWidth = 0;
    self.defaultBackgroundColor = [UIColor muzzleyBlueColorWithAlpha:1.0];
    self.highlightBackgroundColor = [[UIColor alloc] initWithHex:@"0096b6"];
    self.disabledBackgroundColor = [[UIColor alloc] initWithHex:@"CDD7D9"];
    self.highlightBorderColor = [[UIColor alloc] initWithHex:@"CDD7D9"];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cornerRadiusScale = 0.5;
    [UIView setAnimationsEnabled:NO];
    [self setHighlighted:NO];
    [UIView setAnimationsEnabled:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cornerRadius = self.bounds.size.height * _cornerRadiusScale;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    __typeof__(self) __weak weakSelf = self;
    
    if (highlighted) {
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.backgroundColor = weakSelf.highlightBackgroundColor;
            if (self.borderWidth > 0)
            {
                self.layer.borderWidth = 2;
                self.layer.borderColor = self.highlightBorderColor.CGColor;
            }
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.backgroundColor = weakSelf.defaultBackgroundColor;
            self.layer.borderWidth = self.borderWidth;
             if (self.borderWidth > 0)
             {
                 self.layer.borderColor = self.borderColor.CGColor;
             }
        }];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if(enabled)
        self.backgroundColor = self.defaultBackgroundColor;
    else
        self.backgroundColor = self.disabledBackgroundColor;
}

- (void)setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    _cornerRadiusScale = cornerRadius/self.bounds.size.height;
}

- (void)setCornerRadiusScale:(CGFloat)cornerRadiusScale {
    _cornerRadiusScale = cornerRadiusScale;
    self.layer.cornerRadius = self.bounds.size.height * _cornerRadiusScale;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor {
    _defaultBackgroundColor = defaultBackgroundColor;
    
    [UIView setAnimationsEnabled:NO];
    [self setHighlighted:self.isHighlighted];
    [UIView setAnimationsEnabled:YES];
}

- (void)setHighlightBackgroundColor:(UIColor *)highlightBackgroundColor {
    _highlightBackgroundColor = highlightBackgroundColor;
    
    [UIView setAnimationsEnabled:NO];
    [self setHighlighted:self.isHighlighted];
    [UIView setAnimationsEnabled:YES];
}

- (void)setImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
}

@end
