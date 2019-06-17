//
//  MZSwitch.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTriStateToggle.h"
@import Hex;

@interface MZTriStateToggle () <UIGestureRecognizerDelegate>
@property (nonatomic, assign, readwrite) MZTriStateToggleState state;
@property (nonatomic) UIView *toggleBackground;
@property (nonatomic) UIView *toggleThumb;
@property (nonatomic) UIImageView *thumbImageView;

@property (nonatomic, weak) NSLayoutConstraint *thumbCenterXConstraint;

@property (nonatomic, weak) UITapGestureRecognizer *tapGesture;
@property (nonatomic, weak) UISwipeGestureRecognizer *swipeRightGesture;
@property (nonatomic, weak) UISwipeGestureRecognizer *swipeLeftGesture;

@end

@implementation MZTriStateToggle

- (instancetype)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    
    self.unknownTintColor = [[UIColor alloc] initWithHex: @"FFA531"]; //[[UIColor alloc] init:@"FFA531"];
    self.onTintColor = [[UIColor alloc] initWithHex: @"10B5D8"]; //[UIColor colorWithHex:@"10B5D8"];
    self.offTintColor = [[UIColor alloc] initWithHex: @"B7C4C6"]; //[UIColor colorWithHex:@"B7C4C6"];
    self.thumbTintColor = [UIColor whiteColor];
	[self setIsAccessibilityElement:true];
	[self setAccessibilityIdentifier:@"toggle"];
    [self setExclusiveTouch:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
    self.tapGesture.delegate = self;
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlideToRightGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
    self.swipeRightGesture = swipeRightGesture;
    self.swipeRightGesture.delegate = self;
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlideToLeftGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
    self.swipeLeftGesture = swipeLeftGesture;
    self.swipeLeftGesture.delegate = self;
    
    UIView *selfView = self;
    NSDictionary *viewParent = NSDictionaryOfVariableBindings(selfView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[selfView(==50)]" options:0 metrics:nil views:viewParent]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfView(==30)]" options:0 metrics:nil views:viewParent]];
    
    self.toggleBackground = [UIView new];
    self.toggleBackground.userInteractionEnabled = NO;
    [self.toggleBackground setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.toggleBackground.layer.borderWidth = 1;
    
    [self addSubview:self.toggleBackground];
    NSDictionary *views = NSDictionaryOfVariableBindings(_toggleBackground);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toggleBackground]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toggleBackground]|" options:0 metrics:nil views:views]];
    
    self.toggleThumb = [UIView new];
    self.toggleThumb.userInteractionEnabled = NO;
    [self.toggleThumb setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.toggleThumb.backgroundColor = self.thumbTintColor;
    [self addSubview:self.toggleThumb];
    
    self.thumbImageView = [UIImageView new];
    self.thumbImageView.clipsToBounds = YES;
    [self.thumbImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.thumbImageView setContentMode:UIViewContentModeScaleAspectFill];
    views = NSDictionaryOfVariableBindings(_thumbImageView);
    [self.toggleThumb addSubview:self.thumbImageView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_thumbImageView]-5-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_thumbImageView]-5-|" options:0 metrics:nil views:views]];
    
    
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.toggleThumb
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.toggleBackground
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1
                                   constant:-4]];
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.toggleThumb
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.toggleThumb
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1
                                   constant:0]];
    
    NSLayoutConstraint *thumbCenterXConstraint =
    [NSLayoutConstraint constraintWithItem:self.toggleThumb
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:0
                                    toItem:self.toggleBackground
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0];
    
    [self addConstraint:thumbCenterXConstraint];
    self.thumbCenterXConstraint = thumbCenterXConstraint;
    
    [self addConstraint:
     [NSLayoutConstraint constraintWithItem:self.toggleThumb
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:0
                                     toItem:self.toggleBackground
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    
    [self setState:MZTriStateToggleStateUnknown animated:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	self.toggleBackground.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	self.toggleBackground.layer.cornerRadius = self.bounds.size.height * 0.5;
    self.toggleThumb.layer.cornerRadius = self.toggleThumb.frame.size.height * 0.5;
    //self.thumbImageView.layer.cornerRadius = self.toggleThumb.layer.cornerRadius;
    
    CALayer *switchThumbLayer = self.toggleThumb.layer;
    switchThumbLayer.shadowOffset = CGSizeMake(0, 1);
    switchThumbLayer.shadowOpacity = 0.35;
    switchThumbLayer.shadowColor = [[UIColor blackColor] CGColor];
    switchThumbLayer.shadowRadius = 0.7;
    switchThumbLayer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.toggleThumb.bounds cornerRadius:self.toggleThumb.layer.cornerRadius] CGPath];
}

- (void)setState:(MZTriStateToggleState)state animated:(BOOL)animated {
    
    self.state = state;
    
    UIColor *stateColor = [self _stateColorForState:self.state];
    self.thumbCenterXConstraint.constant = [self _thumbCenterXForState:self.state];
    
    __typeof__(self) __weak weakSelf = self;
    if (animated) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.toggleBackground.backgroundColor = stateColor;
			
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [weakSelf layoutIfNeeded];
        } completion:nil];
        
    } else {
        weakSelf.toggleBackground.backgroundColor = stateColor;
    }
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    _thumbTintColor = thumbTintColor;
    self.toggleThumb.backgroundColor = _thumbTintColor;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    [self.thumbImageView setImage:thumbImage];
}

#pragma mark - Gesture handlers
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    [self setState:[self nextStateUsingGesture:tapGesture] animated:YES];
    [self _delegateStateChange];
}

- (void)handleSlideToRightGesture:(UISwipeGestureRecognizer *)swipeGesture {
    [self setState:[self nextStateUsingGesture:swipeGesture] animated:YES];
    [self _delegateStateChange];
}

- (void)handleSlideToLeftGesture:(UISwipeGestureRecognizer *)swipeGesture {
    [self setState:[self nextStateUsingGesture:swipeGesture] animated:YES];
    [self _delegateStateChange];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.tapGesture ||
        gestureRecognizer == self.swipeLeftGesture ||
        gestureRecognizer == self.swipeRightGesture ) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - Private Methods
- (CGFloat)_thumbCenterXForState:(MZTriStateToggleState)state {
    CGFloat centerX = 0;
    if (state == MZTriStateToggleStateUnknown) {
        centerX = 0;
    } else if (state == MZTriStateToggleStateOn) {
        centerX = 10;
    } else if (state == MZTriStateToggleStateOff) {
        centerX = -10;
    }
    return centerX;
}

- (UIColor *)_stateColorForState:(MZTriStateToggleState)state {
    
    UIColor *stateColor = self.unknownTintColor;
    if (state == MZTriStateToggleStateUnknown) {
        stateColor = self.unknownTintColor;
    } else if (state == MZTriStateToggleStateOn) {
        stateColor = self.onTintColor;
    } else if (state == MZTriStateToggleStateOff) {
        stateColor = self.offTintColor;
    }
    return stateColor;
}

- (MZTriStateToggleState )nextStateUsingGesture:(UIGestureRecognizer *)gesture {
    MZTriStateToggleState state = MZTriStateToggleStateUnknown;
    
    if (self.state == MZTriStateToggleStateUnknown) {
        
        if (gesture == self.tapGesture) state = MZTriStateToggleStateOn;
        if (gesture == self.swipeLeftGesture) state = MZTriStateToggleStateOff;
        if (gesture == self.swipeRightGesture) state = MZTriStateToggleStateOn;
        
    } else if (self.state == MZTriStateToggleStateOn) {
        
        if (gesture == self.tapGesture) state = MZTriStateToggleStateOff;
        if (gesture == self.swipeLeftGesture) state = MZTriStateToggleStateOff;
        if (gesture == self.swipeRightGesture) state = MZTriStateToggleStateOn;
        
    } else if (self.state == MZTriStateToggleStateOff) {
        
        if (gesture == self.tapGesture) state = MZTriStateToggleStateOn;
        if (gesture == self.swipeLeftGesture) state = MZTriStateToggleStateOff;
        if (gesture == self.swipeRightGesture) state = MZTriStateToggleStateOn;
    }
    return state;
}

- (void)_delegateStateChange {
    if ([self.delegate respondsToSelector:@selector(toggle:didChangetoState:)]) {
        [self.delegate toggle:self didChangetoState:self.state];
    }
}
@end
