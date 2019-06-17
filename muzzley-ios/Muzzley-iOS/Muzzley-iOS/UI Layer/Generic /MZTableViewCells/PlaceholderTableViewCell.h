//
//  NoInternetTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderTableViewCell : UITableViewCell

- (void)setIconImageNamed:(NSString *)name;
- (void)setIconTintColor:(UIColor *)color;

- (void)setTitleString:(NSString *)title;

- (void)setDescriptionString:(NSString *)description;
@end
