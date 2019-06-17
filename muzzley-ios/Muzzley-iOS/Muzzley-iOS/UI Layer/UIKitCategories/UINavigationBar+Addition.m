//
//  UINavigationBar+Addition.m
//  UINavigationBar+Addition
//
//  Created by Hugo Sousa on 19/12/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "UINavigationBar+Addition.h"

@implementation UINavigationBar (Addition)

/**
 * Hide 1px hairline of the nav bar
 */
- (void)hideBottomHairline {
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = YES;
}

/**
 * Show 1px hairline of the nav bar
 */
- (void)showBottomHairline {
    // Show 1px hairline of translucent nav bar
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = NO;
}


- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}


@end
