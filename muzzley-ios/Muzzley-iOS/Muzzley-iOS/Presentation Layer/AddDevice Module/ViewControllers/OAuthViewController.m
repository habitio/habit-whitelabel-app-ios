//
//  OAuthViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/05/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "OAuthViewController.h"

@interface OAuthViewController () <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *uiShopView;
@property (weak, nonatomic) IBOutlet UILabel *uiLbShopLabel;
@property (weak, nonatomic) IBOutlet MZColorButton *uiBtBuyNow;
@property (weak, nonatomic) IBOutlet UIView *uiMainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *uiShopViewHeightConstraint;

@end

@implementation OAuthViewController

- (void)dealloc
{
    [_activityIndicator stopAnimating];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)uiBtBuyNow_TouchUpInside:(id)sender
{
	[[UIApplication sharedApplication] openURL : self.shopUrl];
}

- (void) goBack
{
    [self.delegate OAuthViewControllerDidCancelAuthentication:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.navigationItem setHidesBackButton:YES];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"icon_close"];
    
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithImage:backButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.urlHost) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlHost];
        
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        [self.webview loadRequest:request];
    }
	
	if(self.shopUrl)
	{
		self.uiShopView.backgroundColor = [UIColor muzzleyVeryLightBlueColorWithAlpha:1.0];
		self.uiLbShopLabel.text = [NSString stringWithFormat: NSLocalizedString(@"add_bundle_shop_label", ""), self.title];
		[self.uiBtBuyNow setTitle: NSLocalizedString(@"add_bundle_shop_button", "") forState: UIControlStateNormal];
		[self.uiLbShopLabel setFont: [UIFont fontWithName:@"SanFranciscoDisplay-Regular" size:14]];
		[self.uiLbShopLabel setTextColor: [UIColor muzzleyBlueColorWithAlpha:1.0]];
		CGRect aFrame = self.uiShopView.frame;
		aFrame.size.height = 54;//self.uiShopView.frame.size.height;
		self.uiShopView.frame = aFrame;

	
		[self.uiShopView setHidden:false];
		[self.uiShopViewHeightConstraint setConstant:54];
	}
	else
	{
		[self.uiShopView setHidden:true];
		[self.uiShopViewHeightConstraint setConstant:0];
	}
}

//TODO work in progress
//-(void) viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//	if(self.isMovingFromParentViewController)
//	{
//		[self.delegate OAuthViewControllerDidCancelAuthentication:self];
//	}
//}

#pragma mark - UIWebViewDelegate
// This is where we could, intercept HTML requests and route them through
// NSURLConnection, to see if the server responds successfully.

/* If session is not checked before, we prevent the request from loading by returning NO and start loading the same request using an NSURLConnection, otherwise we just return YES and the web view continues to load the request.
 */

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"%s should load? request=%@", __FUNCTION__, request);
    DLog(@"%s with headers=%@", __FUNCTION__, request.allHTTPHeaderFields);

    if ([request.URL.host isEqualToString:@"channels.muzzley.com"]
        || [request.URL.host isEqualToString:@"channel-api.develop.muzzley.com"]
        || [request.URL.host isEqualToString:@"channels.staging.muzzley.com"]
        || [request.URL.lastPathComponent isEqualToString:@"retrieve-devices-list"]
		|| [request.URL.lastPathComponent isEqualToString:@"services"]) {
        [self.activityIndicator startAnimating];
        
        if ([self.delegate respondsToSelector:@selector(OAuthViewControllerDidAuthenticate:)])
        {
            [self.delegate OAuthViewControllerDidAuthenticate:self];
        }
        return NO;
    } else {
        
        BOOL headerIsPresent = self.customHeaders == nil || [[request allHTTPHeaderFields] objectForKey:[self.customHeaders allKeys][0]]!=nil;
        if(headerIsPresent)
        {
            DLog(@"%s will load request=%@", __FUNCTION__, request);
            DLog(@"%s with headers=%@", __FUNCTION__, request.allHTTPHeaderFields);
            return YES;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *url = [request URL];
                NSDictionary * headers = [request allHTTPHeaderFields];
                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                request.allHTTPHeaderFields = headers;
                
                // set the new headers
                if (self.customHeaders)
                {
                    for(NSString *key in [self.customHeaders allKeys])
                    {
                        if([[request allHTTPHeaderFields] objectForKey:key] == nil)
                        {
                            [request addValue:[self.customHeaders objectForKey:key] forHTTPHeaderField:key];
                        }
                    }
                }
                
                // reload the request
                DLog(@"%s will load request=%@", __FUNCTION__, request);
                DLog(@"%s with headers=%@", __FUNCTION__, request.allHTTPHeaderFields);
                [aWebView loadRequest:request];
                
                self.customHeaders = nil;
            });
        });
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DLog(@"%s will load=%@", __FUNCTION__, webView.request.URL);
    [self.activityIndicator startAnimating];
}

// we will see this called for 404 errors
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"%s will load=%@", __FUNCTION__, webView.request.URL);
    [self.activityIndicator stopAnimating];
}

// we will not see this called for 404 errors
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"%s error=%@", __FUNCTION__, error);
    //[self.activityIndicator stopAnimating];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger httpStatus = [httpResponse statusCode];
        
        if (httpStatus == 200 || httpStatus == 303 || httpStatus == 307 || httpStatus == 204){
            if ([self.delegate respondsToSelector:@selector(OAuthViewControllerDidAuthenticate:)]) {
                [self.delegate OAuthViewControllerDidAuthenticate:self];
            }
            return;
        }
        
        UIAlertView *alertView =
            [[UIAlertView alloc]
                initWithTitle:[NSHTTPURLResponse localizedStringForStatusCode:httpStatus]
                message:@""
                delegate:nil
                cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"")
                otherButtonTitles:nil, nil];
        [alertView show];
        
        if ([self.delegate respondsToSelector:@selector(OAuthViewControllerDidFailAuthentication:)]) {
            [self.delegate OAuthViewControllerDidFailAuthentication:self];
        }
    }
}

@end
