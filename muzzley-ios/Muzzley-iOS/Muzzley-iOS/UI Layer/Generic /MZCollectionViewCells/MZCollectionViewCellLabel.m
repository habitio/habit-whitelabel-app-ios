//
//  LabelCollectionViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 28/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewCellLabel.h"

@implementation MZCollectionViewCellLabelViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.attributedText = [[NSAttributedString alloc] initWithString:@""];
    }
    return self;
}
@end

@implementation MZCollectionViewCellLabel

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
    [self setNeedsContentViewLayout];
    self.label.preferredMaxLayoutWidth = self.label.frame.size.width;
    
    [super layoutSubviews];
}

- (void)setModel:(MZCollectionViewCellLabelViewModel *)model {
    NSAssert([model isKindOfClass:[MZCollectionViewCellLabelViewModel class]], @"Must use %@ with %@", NSStringFromClass([MZCollectionViewCellLabelViewModel class]), NSStringFromClass([self class]));
    self.label.attributedText = model.attributedText;
}

@end
