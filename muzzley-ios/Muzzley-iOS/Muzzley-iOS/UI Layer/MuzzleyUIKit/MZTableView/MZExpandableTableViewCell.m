//
//  MZExpandableTableViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZExpandableTableViewCell.h"

#import "MZTableViewCellPrivate.h"

@interface MZExpandableTableViewCell ()
@property (weak, nonatomic, readwrite) IBOutlet UIView *headerContentView;
@property (weak, nonatomic, readwrite) IBOutlet UIView *expandableContentView;
@end

@implementation MZExpandableTableViewCell

- (CGFloat)heightForWidth:(CGFloat)width separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    
    // set cell width
    CGRect bounds = self.bounds;
    bounds.size.width = width;
    self.bounds = bounds;
    
    // now force layout on cell view hierarchy using specified width
    // this makes sure any preferredMaxLayoutWidths, etc. are set
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGFloat height = 0;
    // height computed based upon Auto Layout constraints in headerContentView
    CGPoint superViewOrigin = self.headerContentView.superview.frame.origin;
    const CGFloat headerContentViewHeight = self.headerContentView.frame.size.height;
    
    height = (superViewOrigin.y * 2) + headerContentViewHeight;
    
    if (self.isExpanded) {
        // height computed based upon Auto Layout constraints in expandableContentView
        const CGFloat expandableContentViewHeight = self.expandableContentView.frame.size.height;
        height += expandableContentViewHeight;
    }
    
    if (height == 0) {
        // didn't seem like there were Auto Layout constraints that defined contentView's height
        return UITableViewAutomaticDimension;
    } else {
        // +0.5 or 1.0 to account for cell separator http://tomabuct.com/post/73484699239/uitableviews-in-ios-7
        const CGFloat kCellSeparatorViewHeight = (1 / UIScreen.mainScreen.scale);
        const CGFloat separatorHeight = separatorStyle == UITableViewCellSeparatorStyleNone ? 0 : kCellSeparatorViewHeight;
        
        return height + separatorHeight;
    }
}

@end
