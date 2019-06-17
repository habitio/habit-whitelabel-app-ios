//
//  SpinnerController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/2/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "SpinnerControl.h"

@interface SpinnerControl () 
@property (nonatomic) SpinnerView *spinner;
@end

@implementation SpinnerControl

- (void)dealloc
{
    //[self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    //[self.scrollView removeObserver:self forKeyPath:@"contentInset"];
    //self.scrollView = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }
    return self;
}

/*
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init]) {
        
        self.scrollView = scrollView;
        
        
        //[self _layoutSpinner];
        //[scrollView addSubview:self];
        
        
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentInset"]) {
        //UIEdgeInsets edgeInset = [[change objectForKey:@"new"] UIEdgeInsetsValue];
    } else if ([keyPath isEqualToString:@"contentOffset"]){
        CGPoint offset = [[change objectForKey:@"new"] CGPointValue];
        DLog(@"%.2f", offset.y);
        
        //CGFloat insetTop = 0;
        if (!self.isSpinning) {
        /*
            if (offset.y <= self.frame.origin.y ) {
                insetTop = self.frame.size.height;//MIN(offset.y * -1, self.frame.size.height);
            } else {
                insetTop = 0;
            }
                
            [self.scrollView setContentInset:UIEdgeInsetsMake(insetTop, 0, 0, 0)];
        */
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.spinner.frame = self.bounds;
}

- (BOOL)isSpinning
{
    return [self.spinner isSpinning];
}

- (void)startSpinning
{
    [self.spinner startAnimation];
}

-(void)stopSpinning
{
    [self.spinner stopAnimation];
    
    self.scrollView.panGestureRecognizer.enabled = NO;
    //[self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.scrollView setContentOffset: CGPointMake(0, 0) animated:YES];
    self.scrollView.panGestureRecognizer.enabled = YES;
}

- (void)handleScrollViewDraggingEnd
{
    /*if ([self isSpinning]) {
        return;
    }
    
    if (self.scrollView.contentOffset.y <= self.frame.origin.y) {
        
        [self.scrollView setContentInset:UIEdgeInsetsMake(self.frame.size.height, 0, 0, 0)];
        [self startSpinning];
        [self performSelector:@selector(stopSpinning) withObject:nil afterDelay:3];
    
    } else {
        
      [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }*/
}
#pragma mark - Private Methods
- (void)baseInit
{
    self.spinner = [[SpinnerView alloc] initWithFrame:self.bounds];
    [self addSubview:self.spinner];
}


@end
