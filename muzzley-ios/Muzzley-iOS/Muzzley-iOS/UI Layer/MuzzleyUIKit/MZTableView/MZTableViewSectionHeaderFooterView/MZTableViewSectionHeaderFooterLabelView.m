//
//  MZTableViewSectionHeaderFooterLabelView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewSectionHeaderFooterLabelView.h"

#import "MZTableViewSectionHeaderFooterViewSubclass.h"
#import "UIDevice+SystemVersionAdditions.h"

@implementation MZTableViewSectionHeaderFooterLabelView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
    _label = [[UILabel alloc] init];
    _label.numberOfLines = 0;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentLayoutGuideView addSubview:_label];

    [self _installLabelConstraints];
  }
  return self;
}

#pragma mark Layout

- (void)_installLabelConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(_label);

  [self.contentLayoutGuideView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_label]|" options:0 metrics:nil views:views]];
  [self.contentLayoutGuideView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_label]|" options:0 metrics:nil views:views]];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  if ([[UIDevice currentDevice] systemVersionLessThan:@"8.0"]) {
    self.label.preferredMaxLayoutWidth = CGRectGetWidth(self.label.bounds);
    [super layoutSubviews];
  }
}

#pragma mark Text property

- (void)setText:(NSString *)text {
  self.label.text = text;
}

- (NSString *)text {
  return self.label.text;
}

@end