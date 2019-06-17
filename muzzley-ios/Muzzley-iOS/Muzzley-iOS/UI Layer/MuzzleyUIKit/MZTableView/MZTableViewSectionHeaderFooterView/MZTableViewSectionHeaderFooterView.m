//
//  MZTableViewSectionHeaderFooterView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewSectionHeaderFooterView.h"
#import "MZTableViewSectionHeaderFooterViewSubclass.h"
#import "MZTableViewSectionHeaderFooterViewPrivate.h"

#import "MZTableView.h"
#import "MZTableViewCell.h"

static const CGFloat kSmallVerticalPadding = 7;
static const CGFloat kLargeVerticalPadding = 12;
static const CGFloat kDefaultHorizontalPadding = 15;
static const CGFloat kFirstLastSectionExtraVerticalPadding = 17.5;

@interface MZTableViewSectionHeaderFooterView ()
@property (copy, nonatomic) NSArray *contentLayoutGuideConstraints;
@property (strong, nonatomic) NSLayoutConstraint *contentLayoutGuideWidthConstraint;
@end

@implementation MZTableViewSectionHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
    _contentLayoutGuideView = [[UIView alloc] init];
    _contentLayoutGuideView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_contentLayoutGuideView];
    
    [self _installContentLayoutGuideWidthConstraint];
  }
  return self;
}

#pragma mark Layout

- (void)_installContentLayoutGuideWidthConstraint {
  // For some reason, doing |-left-[_contentLayoutGuideView]-(right@999)-| doesn't work when the header's label is more than one line long, so we have to do this as a width.
  self.contentLayoutGuideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.contentLayoutGuideView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
  // Allow the width constraint to be broken by subviews that are constrained with additional non-zero padding
  self.contentLayoutGuideWidthConstraint.priority = UILayoutPriorityRequired - 1;
  [self.contentView addConstraint:self.contentLayoutGuideWidthConstraint];
}

- (void)layoutSubviews {
  UIEdgeInsets edgeInsets = [self _totalInsets];
  // The layout guide doesn't like being told to have a negative width, so we have to make sure it's at least 0.
  self.contentLayoutGuideWidthConstraint.constant = MAX(CGRectGetWidth(self.bounds) - edgeInsets.left - edgeInsets.right, 0);

  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
    [self.contentView layoutIfNeeded];
  }

  [super layoutSubviews];
}

- (void)updateConstraints {
  if (self.contentLayoutGuideConstraints) {
    [self.contentView removeConstraints:self.contentLayoutGuideConstraints];
  }

  // Before this view has been fully configured, UITableView adds a constraint forcing this to be CGSizeZero. To prevent unsatisfiable constraints, we have to let a constraint collapse.

  NSString *vfl = nil;
  switch (self.position) {
    case MZTableViewSectionHeaderFooterPositionUndefined:
      NSAssert(NO, @"undefined MZTableViewSectionHeaderFooterPosition");
    case MZTableViewSectionHeaderFooterPositionHeader:
    case MZTableViewSectionHeaderFooterPositionFirstHeader:
      vfl = @"V:|-(>=top@priorityNotRequired)-[_contentLayoutGuideView]-bottom-|";
      break;
    case MZTableViewSectionHeaderFooterPositionFooter:
    case MZTableViewSectionHeaderFooterPositionLastFooter:
      vfl = @"V:|-top-[_contentLayoutGuideView]-(>=bottom@priorityNotRequired)-|";
      break;
  }

  NSMutableArray *constraints = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:[self _metrics] views:[self _views]]];

  [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_contentLayoutGuideView]" options:0 metrics:[self _metrics] views:[self _views]]];

  self.contentLayoutGuideConstraints = constraints;
  [self.contentView addConstraints:self.contentLayoutGuideConstraints];
  [super updateConstraints];
}

- (NSDictionary *)_views {
  return NSDictionaryOfVariableBindings(_contentLayoutGuideView);
}

- (NSDictionary *)_metrics {
  UIEdgeInsets edgeInsets = [self _totalInsets];
  return @{ @"left": @(edgeInsets.left),
            @"right": @(edgeInsets.right),
            @"top": @(edgeInsets.top),
            @"bottom": @(edgeInsets.bottom),
            @"priorityNotRequired": @(UILayoutPriorityRequired - 1) };
}

- (UIEdgeInsets)_totalInsets {
  // When you don't specify section footers, they are 17.5pt tall by default. This makes up the
  // inter-section padding in grouped table views. Since the first section header doesn't have a
  // (previous section's) footer before it, the first section header's height is made
  // 17.5pts taller by the system when tableView:heightForHeaderInSection: isn't implemented.
  // This code emulates the system behavior. A similar thing happens for footers.
  CGFloat extraTopPadding = self.position == MZTableViewSectionHeaderFooterPositionFirstHeader ? kFirstLastSectionExtraVerticalPadding : 0;
  CGFloat extraBottomPadding = self.position == MZTableViewSectionHeaderFooterPositionLastFooter ? kFirstLastSectionExtraVerticalPadding : 0;
  UIEdgeInsets edgeInsets = self.contentLayoutGuideInsets;
  edgeInsets.top += extraTopPadding;
  edgeInsets.bottom += extraBottomPadding;
  return edgeInsets;
}

#pragma mark Public methods

- (CGFloat)heightForWidth:(CGFloat)width {
  // set our width
  CGRect bounds = self.bounds;
  bounds.size.width = width;
  self.bounds = bounds;
  
  [self updateConstraintsIfNeeded];
  [self layoutIfNeeded];
  
  // calculate minimum required height
  const CGFloat contentViewHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  return contentViewHeight == 0 ? UITableViewAutomaticDimension : contentViewHeight;
}

- (void)setPosition:(MZTableViewSectionHeaderFooterPosition)position {
  if (position != _position) {
    _position = position;
    [self setNeedsUpdateConstraints];
  }
}

#pragma mark Protected helpers

- (UIEdgeInsets)contentLayoutGuideInsets {
  CGFloat top = 0;
  CGFloat bottom = 0;
  
  switch (self.position) {
    case MZTableViewSectionHeaderFooterPositionUndefined:
      NSAssert(NO, @"undefined MZTableViewSectionHeaderFooterPosition");
      
    case MZTableViewSectionHeaderFooterPositionHeader:
    case MZTableViewSectionHeaderFooterPositionFirstHeader:
      top = kLargeVerticalPadding;
      bottom = kSmallVerticalPadding;
      break;
      
    case MZTableViewSectionHeaderFooterPositionFooter:
    case MZTableViewSectionHeaderFooterPositionLastFooter:
      top = kSmallVerticalPadding;
      bottom = kLargeVerticalPadding;
      break;
  }
  
  return UIEdgeInsetsMake(top, kDefaultHorizontalPadding, bottom, kDefaultHorizontalPadding);
}

@end