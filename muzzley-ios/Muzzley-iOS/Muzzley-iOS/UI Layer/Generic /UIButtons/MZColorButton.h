//
//  MZColorButton.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MZColorButton : UIButton
@property (nonatomic, strong) IBInspectable UIColor * defaultBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor * highlightBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor * disabledBackgroundColor;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadiusScale;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *highlightBorderColor;

- (void)setTitle:(NSString *)title;
- (void)setImage:(UIImage *)image;
- (void)_init;
@end
