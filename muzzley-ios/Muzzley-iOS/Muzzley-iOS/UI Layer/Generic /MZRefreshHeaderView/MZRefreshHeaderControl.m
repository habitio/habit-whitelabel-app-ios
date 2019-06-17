//
//  MZRefreshHeaderControl.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 9/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZRefreshHeaderControl.h"
#import "MZRefreshHeaderViewSubclass.h"

@interface MZRefreshHeaderControl ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) SpinnerView *spinnerView;
@end

@implementation MZRefreshHeaderControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blueColor];
        /*
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        */
        _spinnerView = [[SpinnerView alloc] init];
        _spinnerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_spinnerView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_spinnerView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_spinnerView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_spinnerView(30)]-10-|" options:0 metrics:nil views:views]];
        
        [self setRefreshState:MZRefreshHeaderViewStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

}
#pragma mark YLRefreshHeader subclass methods

- (void)setRefreshState:(MZRefreshHeaderViewState)refreshState animated:(BOOL)animated {
    [super setRefreshState:refreshState animated:animated];
    
    switch (refreshState) {
        case MZRefreshHeaderViewStateNormal:
            //self.label.text = @"Pull to refresh...";
            //self.label.textColor = [UIColor redColor];
            
            self.backgroundColor = [UIColor redColor];
            [self.spinnerView stopAnimation];
            break;
        case MZRefreshHeaderViewStateClosing:
            break;
        case MZRefreshHeaderViewStateRefreshing:
            //self.label.text = @"Refreshing...";
            //self.label.textColor = [UIColor blackColor];
            self.backgroundColor = [UIColor darkGrayColor];
            [self.spinnerView startAnimation];
            break;
        case MZRefreshHeaderViewStateReadyToRefresh:
            //self.label.text = @"Release to refresh";
            //self.label.textColor = [UIColor greenColor];
            self.backgroundColor = [UIColor greenColor];
            [self.spinnerView stopAnimation];
            break;
    }
}

- (CGFloat)pullAmountToRefresh {
    return 44.0;
}

@end
