//
//  InfoPlaceholderView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZInfoPlaceholderView.h"

@interface MZInfoPlaceholderView ()
@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@end

@implementation MZInfoPlaceholderView

#pragma mark - Initializers Methods
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _loadNib];
        return self;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _loadNib];
        return self;
    }
    return nil;
}

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 400)]) {
        [self _loadNib];
        return self;
    }
    return nil;
}

#pragma mark - Private Methods
- (void)_loadNib {
    NSString *className = NSStringFromClass([self class]);
    self.view = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
    [self addSubview:self.view];
    
    // Add constraints to inner view to match self bounds
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(_view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_view]|" options:0 metrics:nil views:views]];
    
    // setup subviews
    [self _setupInterface];
}

- (void)_setupInterface {
    
    self.image = nil;
    self.imageTintColor = [UIColor clearColor];
    self.title = @"";
    self.message = @"";
    [self.loadingIndicator stopAnimating];
    
//    self.backgroundColor = [UIColor clearColor];
    [self.iconView setTintColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width;
    self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.frame.size.width;
    
    //[self.actionButton layoutIfNeeded];
    
    [super layoutSubviews];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.iconView.image = image;
}

- (void)setImageTintColor:(UIColor *)imageTintColor {
    if (!imageTintColor) {
        imageTintColor = [UIColor clearColor];
    }
    _imageTintColor = imageTintColor;
    
    [self.iconView setTintColor:imageTintColor];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
    self.descriptionLabel.text = message;
}

@end
