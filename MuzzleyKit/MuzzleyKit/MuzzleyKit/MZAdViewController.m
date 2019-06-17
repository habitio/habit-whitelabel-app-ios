//
//  MZAdWebview.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 11/02/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZAdViewController.h"

NSString *const MZAdViewContext = @"MZAdViewContext";

@interface MZAdViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic) CGSize ratioSize;
@property (nonatomic) MZAdViewGravity gravity;

@property (nonatomic, strong) NSTimer *durationTimer;

@end

@implementation MZAdViewController

#pragma mark - Dealloc
- (void)dealloc
{
    self.webview.delegate = nil;
    self.webview = nil;
    
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    
    [self.view removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
    self.view.alpha = 0;
    
    self.ratioSize = CGSizeMake(100, 100);
    self.gravity = MZAdViewGravityCenter;
    
    self.webview = [UIWebView new];
    _webview.delegate = self;
    _webview.scalesPageToFit = YES;
    _webview.scrollView.bounces = NO;
    _webview.dataDetectorTypes = UIDataDetectorTypeLink;
     
    [self.view addSubview:_webview];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(0, 0, 40, 40);
    _closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 5);
    
    [_closeButton addTarget:self
                     action:@selector(handleCloseButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [_closeButton setImage:[UIImage imageNamed:@"closeButton"]
                  forState:UIControlStateNormal];
    [self.view addSubview:_closeButton];
    
    // Added KVO for self.view.frame changes
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:(__bridge void *)(MZAdViewContext)];
    
}

- (void)showAdWithHTMLString:(NSString *)htmlString ratioSize:(CGSize)ratioSize gravity:(MZAdViewGravity)gravity duration:(NSTimeInterval)duration
{
    [self _showAdWithContent:htmlString ratioSize:ratioSize gravity:gravity duration:duration];
}

- (void)showAdWithURL:(NSURL *)url ratioSize:(CGSize)ratioSize gravity:(MZAdViewGravity)gravity duration:(NSTimeInterval)duration
{
    [self _showAdWithContent:url ratioSize:ratioSize gravity:gravity duration:duration];
}

- (void)_showAdWithContent:(id)content ratioSize:(CGSize)ratioSize gravity:(MZAdViewGravity)gravity duration:(NSTimeInterval)duration
{
    // Validate ratio
    // Values between 1 and 100
    if (ratioSize.width < 1) ratioSize.width = 1;
    else if (ratioSize.width > 100) ratioSize.width = 100;
    
    if (ratioSize.height < 1) ratioSize.height = 1;
    else if (ratioSize.height > 100) ratioSize.height = 100;
    
    self.ratioSize = ratioSize;
    
    
    CGSize relativeRatioSize = CGSizeMake(_ratioSize.width / 100.0, _ratioSize.height / 100.0);
    
    UIView *superview = self.view.superview;
    CGRect frame = CGRectMake(0, 0,
                              superview.bounds.size.width * relativeRatioSize.width,
                              superview.bounds.size.height * relativeRatioSize.height);
    
    // Validate gravity
    // Center position in the screen
    CGPoint center;
    if (gravity == MZAdViewGravityCenter) {
        center = CGPointMake(superview.bounds.size.width * 0.5,
                             superview.bounds.size.height * 0.5);
        self.gravity = gravity;
        
    } else if (gravity == MZAdViewGravityTop) {
        center = CGPointMake(superview.bounds.size.width * 0.5,
                             frame.size.height * 0.5);
        self.gravity = gravity;
    } else if (gravity == MZAdViewGravityBottom) {
        center = CGPointMake(superview.bounds.size.width * 0.5,
                             superview.bounds.size.height - frame.size.height * 0.5);
        self.gravity = gravity;
    } else {
        self.gravity = MZAdViewGravityCenter;
    }
    
    // Set ad visibility timer duration
    if (duration > 0) {
        [self scheduleTimerWithDuration:duration];
    }
    
    if (self.view.alpha > 0) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.view.alpha = 0;
                             _webview.alpha = 1;
                             _closeButton.alpha = 1;
                             
                         } completion:^(BOOL finished) {
                             [self _createWebviewContent:content frame:frame center:center];
                         }];
    } else {
        [self _createWebviewContent:content frame:frame center:center];
    }
}
- (void)_createWebviewContent:(id)content frame:(CGRect)frame center:(CGPoint)center
{
    self.view.frame = frame;
    self.view.center = center;
    
    BOOL success = NO;
    if ([content isKindOfClass:[NSString class]]) {
        [self.webview loadHTMLString:content baseURL:nil];
        success = YES;
    } else if ([content isKindOfClass:[NSURL class]]) {
        [self.webview loadRequest:[NSURLRequest requestWithURL:content]];
        success = YES;
    }
    
    if (success) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                self.view.alpha = 1;
            } completion:nil];
    }
}

-(void)_hideAd
{
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.view.alpha = 0;
        } completion:nil];
}

#pragma mark - KVO Self.view Frame
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == (__bridge void *)(MZAdViewContext)) {
        if([keyPath isEqualToString:@"frame"]) {
            
            //CGRect frame = [change[@"new"] CGRectValue];
            [self.webview setFrame:self.view.bounds];
            [self.closeButton setCenter:
                CGPointMake( self.view.bounds.size.width - _closeButton.frame.size.width * 0.5,
                            _closeButton.frame.size.height * 0.5)];
        }
    }
}

#pragma mark - Button Close
- (void)handleCloseButtonTouchUpInside:(id)sender
{
    [self _hideAd];
}

- (void)scheduleTimerWithDuration:(NSTimeInterval)duration
{
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    
    self.durationTimer =
    [NSTimer scheduledTimerWithTimeInterval:duration
                                     target:self
                                   selector:@selector(handleDurationTimer:)
                                   userInfo:nil repeats:NO];
}

- (void)handleDurationTimer:(NSTimer *)timer
{
    [self _hideAd];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}
@end
