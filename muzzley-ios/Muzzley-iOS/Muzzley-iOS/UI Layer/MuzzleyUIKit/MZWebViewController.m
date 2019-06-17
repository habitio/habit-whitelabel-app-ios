//
//  MZWebViewController.m
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 20/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "MZWebViewController.h"

@interface MZWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) NSString *backItemTitle;
@end

@implementation MZWebViewController


	
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    webView.delegate = self;
    self.view = webView;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    self.indicatorView.hidesWhenStopped = YES;
    [self.indicatorView startAnimating];
    [self.view addSubview:self.indicatorView];
    
    UIImage *image = [[UIImage imageNamed:@"Open_Browser"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.tintColor = [UIColor muzzleyWhiteColorWithAlpha:1.0];
    button.bounds = CGRectMake(0, 0, 20, 20);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openInBrowser) forControlEvents:UIControlEventTouchUpInside];

    if (@available(iOS 11, *))
    {
        button.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
	_backItemTitle = self.navigationController.navigationBar.topItem.title;
	self.navigationController.navigationBar.topItem.title = @"";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
}
	
- (void)willMoveToParentViewController:(UIViewController *)parent;
	{
		[super willMoveToParentViewController: parent];
		if (parent == nil) {
			
			//restore the orignal title
			self.navigationController.navigationBar.backItem.title = _backItemTitle;
		}
	}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}
	
	

- (void)openInBrowser {
    DLog(@"self.url %@", self.url);
    [[UIApplication sharedApplication] openURL:self.url];
}

@end
