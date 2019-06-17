//
//  MZTableViewSectionHeaderFooterViewSubclass.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewSectionHeaderFooterView.h"

@interface MZTableViewSectionHeaderFooterView ()

/*!
 * You should add subviews to this view, and pin those views to it using Auto Layout constraints.
 *
 * This view is inset by contentLayoutGuideInsets + _systemContentLayoutGuideInsets. contentLayoutGuideInsets can be overridden by subclasses.
 */
@property (readonly, strong, nonatomic) UIView *contentLayoutGuideView;

@property (readonly, assign, nonatomic) UIEdgeInsets contentLayoutGuideInsets;

@end