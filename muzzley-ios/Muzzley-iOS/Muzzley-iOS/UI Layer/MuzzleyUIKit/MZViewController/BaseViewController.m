//
//  MZViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/04/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "BaseViewController.h"
@import Hex;

@interface BaseViewController ()
{
}

@end

@implementation BaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    self.isFirstTime = YES;

	float height = self.infoPlaceholderView.frame.size.height * 0.4;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.infoPlaceholderView.frame.size.width, height)];
	scrollView.userInteractionEnabled = YES;
	scrollView.scrollEnabled = YES;
	scrollView.backgroundColor = [UIColor muzzleyBlueColorWithAlpha:0];
	scrollView.contentSize = CGSizeMake(self.infoPlaceholderView.frame.size.width, 1000);
	[scrollView setShowsVerticalScrollIndicator:NO];
	[scrollView setShowsHorizontalScrollIndicator:NO];
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl setTintColor: [UIColor clearColor]];
	[refreshControl addTarget:self action:@selector(triggerRefreshDelegate:) forControlEvents:UIControlEventValueChanged];
	[scrollView addSubview:refreshControl];
	
	[self.infoPlaceholderView addSubview:scrollView];
}


- (void)triggerRefreshDelegate:(UIRefreshControl *)refreshControl
{
//	refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
//	
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//		
//		[NSThread sleepForTimeInterval:3];
//		
//		dispatch_async(dispatch_get_main_queue(), ^{
//			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//			[formatter setDateFormat:@"MMM d, h:mm a"];
//			NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
//			
//			refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];

	[refreshControl endRefreshing];
//			
//		});
//	});
	
	if ([self.refreshDelegate respondsToSelector:@selector(refreshTriggered)]) {
		[self.refreshDelegate refreshTriggered];
	}}

#pragma mark - View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)setInfoPlaceholderVisible:(BOOL)visible {
    if (visible) { self.infoPlaceholderView.alpha = 1; }
    else { self.infoPlaceholderView.alpha = 0; }
}

- (void)setEmptyResultsInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName  title:(NSString *)title message:(NSString *)message {
    [self resetPlaceholder];
    UIImage *image = [[UIImage imageNamed:placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.infoPlaceholderView.image = image;
    self.infoPlaceholderView.imageTintColor = [UIColor clearColor];
	self.infoPlaceholderView.title = title;
    self.infoPlaceholderView.message = message;
    [self.infoPlaceholderView.actionButton setTitle:NSLocalizedString(@"mobile_retry", @"")];
    [self.infoPlaceholderView.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.infoPlaceholderView.actionButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [self setInfoPlaceholderVisible:YES];

}

- (void)setEmptyResultsInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle andButtonAction:(SEL)action {
    [self resetPlaceholder];
    UIImage *image = [[UIImage imageNamed:placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.infoPlaceholderView.image = image;
    self.infoPlaceholderView.imageTintColor = [UIColor clearColor];
	self.infoPlaceholderView.title = title;
    self.infoPlaceholderView.message = message;
    [self.infoPlaceholderView.actionButton setTitle:buttonTitle];
    [self.infoPlaceholderView.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.infoPlaceholderView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self setInfoPlaceholderVisible:YES];
}

- (void)setErrorInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName {
    [self resetPlaceholder];
    UIImage *image = [[UIImage imageNamed:placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.infoPlaceholderView.image = image;
    self.infoPlaceholderView.imageTintColor = [UIColor clearColor];
    self.infoPlaceholderView.title = NSLocalizedString(@"mobile_error_title", @"");
    self.infoPlaceholderView.message = NSLocalizedString(@"mobile_retry_text", @"");
    [self.infoPlaceholderView.actionButton setTitle:NSLocalizedString(@"mobile_retry", @"")];
    [self.infoPlaceholderView.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.infoPlaceholderView.actionButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [self setInfoPlaceholderVisible:YES];
}

- (void)setGenericErrorInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName andDecription:(NSString *)description {
    [self resetPlaceholder];
    UIImage *image = [[UIImage imageNamed:placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.placeholder.image = image;
    self.placeholder.imageTintColor = [UIColor clearColor];
    self.placeholder.title = description;
    self.placeholder.message = @"";
    self.placeholder.actionButton.hidden = YES;
    self.placeholder.arcView.hidden = YES;
    self.placeholder.bodyBottomView.hidden = YES;
    self.placeholder.bodyView.backgroundColor = [UIColor muzzleyDarkWhiteColorWithAlpha:1];
    self.placeholder.footerView.backgroundColor = [UIColor muzzleyDarkWhiteColorWithAlpha:1];
    [self.infoPlaceholderView.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
}

- (void)setNoInternetInfoPlaceholder {
    [self resetPlaceholder];
    UIImage *image = [[UIImage imageNamed:@"IconNoWifi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.infoPlaceholderView.image = image;
    self.infoPlaceholderView.imageTintColor = [[UIColor alloc] initWithHex:@"BCCED2"];
    self.infoPlaceholderView.title = NSLocalizedString(@"mobile_no_internet_title", @"");
    self.infoPlaceholderView.message = NSLocalizedString(@"mobile_no_internet_text", @"");
    [self.infoPlaceholderView.actionButton setTitle:NSLocalizedString(@"mobile_retry", @"")];
    [self.infoPlaceholderView.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.infoPlaceholderView.actionButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    [self setInfoPlaceholderVisible:YES];
}

- (void)setLoadingResultsInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName title:(NSString *)title  message:(NSString *)message {
    [self resetPlaceholder];
    UIImage *image = [[UIImage imageNamed:placeholderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.infoPlaceholderView.image = image;
    self.infoPlaceholderView.imageTintColor = [UIColor clearColor];
	self.infoPlaceholderView.title = title;
    self.infoPlaceholderView.message = message;
    self.infoPlaceholderView.actionButton.hidden = YES;
    [self.infoPlaceholderView.loadingIndicator startAnimating];
    [self.infoPlaceholderView bringSubviewToFront:self.infoPlaceholderView.loadingIndicator];
    
    [self setInfoPlaceholderVisible:YES];
}

- (void)resetPlaceholder {
    self.infoPlaceholderView.actionButton.hidden = NO;
    [self.infoPlaceholderView.loadingIndicator stopAnimating];
    [self.infoPlaceholderView bringSubviewToFront:self.infoPlaceholderView.actionButton];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)reloadData
{
}

- (void)refreshData
{
}




@end
