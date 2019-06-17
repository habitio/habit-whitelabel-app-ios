//
//  PlaceholderCollectionViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//
#import "PlaceholderCollectionViewCell.h"

@implementation PlaceholderCollectionViewCellViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.image = nil;
        self.imageTintColor = [UIColor clearColor];
        self.title = @"";
        self.message = @"";
    }
    return self;
}
@end

@interface PlaceholderCollectionViewCell ()
@end

@implementation PlaceholderCollectionViewCell
@dynamic delegate;

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    
    self.infoPlaceholderView.image = nil;
    self.infoPlaceholderView.imageTintColor = [UIColor clearColor];
    self.infoPlaceholderView.title = @"";
    self.infoPlaceholderView.message = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setNeedsContentViewLayout];
    
    //[self.infoPlaceholderView setNeedsLayout];
    //[self.infoPlaceholderView layoutIfNeeded];
    
    [super layoutSubviews];
}

- (void)setModel:(PlaceholderCollectionViewCellViewModel *)model {
    NSAssert([model isKindOfClass:[PlaceholderCollectionViewCellViewModel class]], @"Must use %@ with %@", NSStringFromClass([PlaceholderCollectionViewCellViewModel class]), NSStringFromClass([self class]));
    
    self.infoPlaceholderView.image = model.image;
    self.infoPlaceholderView.imageTintColor = model.imageTintColor;
    self.infoPlaceholderView.title = model.title;
    self.infoPlaceholderView.message = model.message;
}

#pragma mark - Private Methods


@end