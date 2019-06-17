//
//  MZTableViewSectionHeaderFooterLabelView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewSectionHeaderFooterView.h"

//! A section header / footer view that supports a single, multi-line label
@interface MZTableViewSectionHeaderFooterLabelView : MZTableViewSectionHeaderFooterView

//! We don't use the default textLabel because then this header/footer would be sized assuming the system default header/footer font.
@property (readonly, strong, nonatomic) UILabel *label;

//! Setting this property will set the label's text.
@property (copy, nonatomic) NSString *text;

@end
