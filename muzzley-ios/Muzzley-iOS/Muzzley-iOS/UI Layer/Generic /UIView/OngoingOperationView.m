//
//  OngoingOperationView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/5/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "OngoingOperationView.h"

@interface OngoingOperationView ()
@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation OngoingOperationView

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
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 100)]) {
        [self _loadNib];
        return self;
    }
    return nil;
}

#pragma mark - Private Methods
- (void)_loadNib
{
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

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _view.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
    return _view.backgroundColor;
}

- (void)_setupInterface
{
    self.message = @"Ongoing...";
}

- (void)setMessage:(NSString *)message
{
    if (![message isKindOfClass:[NSString class]]) message = @"";
    _message = message;
    self.label.text = _message;
}

- (void)setMessageColor:(UIColor *)messageColor
{
    _messageColor = messageColor;
    self.label.textColor = messageColor;
}

@end
