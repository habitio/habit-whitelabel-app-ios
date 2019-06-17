//
//  MZTabBarItem.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTabBarItem.h"

@interface MZTabBarItem ()
@property (nonatomic, weak) UIView *highlightCircle;
@end

@implementation MZTabBarItem

- (instancetype)init {
    
    self = [super initWithFrame:CGRectMake(0, 0, 44, 44)];
    if (!self) return nil;
    
    self.exclusiveTouch = YES;
    self.selected = NO;
    self.adjustsImageWhenHighlighted = NO;
    self.imageView.alpha = 0.6;
    /*UIView *highlightCircle = [UIView new];
    highlightCircle.backgroundColor = [UIColor colorWithWhite:0 alpha:0.06];
    highlightCircle.alpha = 0;
    highlightCircle.userInteractionEnabled = NO;
    [self insertSubview:highlightCircle atIndex:0];
    
    self.highlightCircle = highlightCircle;*/

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.highlightCircle.bounds = CGRectMake(0, 0, self.imageView.bounds.size.width + 16,
                                             self.imageView.bounds.size.height + 16);
    self.highlightCircle.center = CGPointMake(self.bounds.size.width * 0.5,
                                              self.bounds.size.height * 0.5);
    self.highlightCircle.layer.cornerRadius = (self.highlightCircle.bounds.size.height * 0.5);
}

- (void)setHighlighted:(BOOL)highlighted {
    //[super setHighlighted:highlighted];
    if (highlighted) {
        if (self.selected) { return; };
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.highlightCircle.alpha = 1;
        } completion:nil];
        
    } else {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.highlightCircle.alpha = 0;
        } completion:nil];
    }
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    if (selected) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.imageView.alpha = 1;
        } completion:nil];
        
    } else {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.imageView.alpha = 0.6;
        } completion:nil];
    }
}

@end
