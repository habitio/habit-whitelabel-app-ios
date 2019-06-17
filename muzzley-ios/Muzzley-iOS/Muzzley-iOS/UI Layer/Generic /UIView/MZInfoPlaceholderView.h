//
//  InfoPlaceholderView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZArcHeaderView.h"
#import "MZColorButton.h"

@interface MZInfoPlaceholderView : UIView
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) UIColor *imageTintColor;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, weak) IBOutlet MZColorButton *actionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet MZArcHeaderView *arcView;
@property (weak, nonatomic) IBOutlet UIView *bodyBottomView;

@end
