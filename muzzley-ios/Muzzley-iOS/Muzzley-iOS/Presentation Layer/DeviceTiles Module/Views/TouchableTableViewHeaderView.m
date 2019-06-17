//
//  TouchableTableViewHeaderView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/5/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "TouchableTableViewHeaderView.h"

@interface TouchableTableViewHeaderView ()

@end

@implementation TouchableTableViewHeaderView
- (void)dealloc
{

}
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self _setupInterface];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self applyUIStyle];
}

- (void)applyUIStyle
{
    self.textLabel.textColor = [UIColor muzzleyRedColorWithAlpha:1.0];
    self.textLabel.font = [UIFont systemFontOfSize:14.0];
    self.backgroundView.backgroundColor = [UIColor muzzleyDarkWhiteColorWithAlpha:0.9];
}

- (void)_setupInterface
{
    // Add any optional custom views of your own
    UIButton *touchableArea = [UIButton buttonWithType:UIButtonTypeSystem];
    touchableArea.exclusiveTouch = YES;
    
    [touchableArea addTarget:self action:@selector(_didPressDown) forControlEvents:UIControlEventTouchDown];
    
    [touchableArea addTarget:self action:@selector(_didPressUp) forControlEvents:UIControlEventTouchUpInside];
    
    [touchableArea addTarget:self action:@selector(_didAbort) forControlEvents:UIControlEventTouchCancel];
    [touchableArea addTarget:self action:@selector(_didAbort) forControlEvents:UIControlEventTouchUpOutside];
    [touchableArea addTarget:self action:@selector(_didAbort) forControlEvents:UIControlEventTouchDragExit];
    [touchableArea addTarget:self action:@selector(_didAbort) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.contentView addSubview:touchableArea];
    
    // Add constraints to inner view to match self bounds
    [touchableArea setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(touchableArea);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[touchableArea]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[touchableArea]|" options:0 metrics:nil views:views]];
    [touchableArea setNeedsUpdateConstraints];
    
    [self applyUIStyle];
}

- (void)_didPressUp
{
    [self _didAbort];
    
    if ([self.delegate respondsToSelector:@selector(tableViewHeaderWasTapped:)]) {
        [self.delegate tableViewHeaderWasTapped:self];
    }
}

- (void)_didAbort
{
    /*CGFloat alpha = 1.0;
    self.textLabel.alpha = alpha;
    self.detailTextLabel.alpha = alpha;*/
}

- (void)_didPressDown
{
    /*CGFloat alpha = 0.3;
    self.textLabel.alpha = alpha;
    self.detailTextLabel.alpha = alpha;*/
}
@end
