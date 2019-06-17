//
//  MZViewControllerLogIn.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UserAuthViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MZWebViewController.h"
#import "TTTAttributedLabel.h"

#import "AppManager.h"


#import <MessageUI/MessageUI.h>
#import "MZColorButton.h"

#import "UserAuthSignInViewController.h"

@interface UserAuthViewController () </*GIDSignInUIDelegate,*/PopupContentViewDelegate, TTTAttributedLabelDelegate,MFMailComposeViewControllerDelegate, AppManagerLoadUserFromCacheDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *uiLbVersion;


@property (nonatomic, weak) IBOutlet UIView *signInViewArea;
//@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
//@property (nonatomic, weak) IBOutlet UIButton *googlePlusButton;
@property (nonatomic, weak) IBOutlet MZColorButton *signInButton;
@property (nonatomic, weak) IBOutlet MZColorButton *signUpButton;
@property (weak, nonatomic) IBOutlet MZColorButton *signInCustomButton;
@property (weak, nonatomic) IBOutlet MZCheckBox *uiTermsCheckBox;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInCustomButtonHeightConstraint;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *uiImage;
@property (weak, nonatomic) IBOutlet UILabel *uiTitle;
@property (weak, nonatomic) IBOutlet UITextView *uiTextView;
//@property (weak, nonatomic) IBOutlet TTTAttributedLabel *uiLabelTerms;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *uiLabelTerms;


@property (nonatomic, readwrite) UserAuthInteractor *interactor;
//@property (nonatomic, readwrite) MZUserProfileInteractor *profileInteractor;
@property (nonatomic, readwrite) UserAuthWireframe *wireframe;


@end

KLCPopup * _popupView;

@implementation UserAuthViewController

MZLoadingView * _loadingView;

- (void)dealloc
{
    _interactor = nil;
    _wireframe = nil;
}

- (IBAction)uiTermsCheckBox_TouchUpInside:(id)sender
{

}

- (instancetype)initWithWireframe:(UserAuthWireframe *)wireframe interactor:(UserAuthInteractor *)interactor
{
    self = [super initWithNibName:SCREEN_ID_USER_AUTH bundle:[NSBundle mainBundle]];
    if (self) {
        self.wireframe = wireframe;
        self.wireframe.userAuthViewController = self;
        self.interactor = interactor;
        self.interactor.output = self;
		_loadingView = [MZLoadingView new];

		[AppManager sharedManager].loadFromCacheDelegate = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader) name:@"cleanUpAndGoToStart" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoader) name:@"showStartLoader" object:nil];
    }
    return self;
}

- (void)stopLoader
{
	[_loadingView updateLoadingStatus:NO container:self.view];
}
- (void)startLoader
{
	[_loadingView updateLoadingStatus:YES container:self.view];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	[_loadingView updateLoadingStatus:YES container:self.view];


	/*NSString *fbButtonTitle = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"mobile_signin_with", ""), @"  \uE801"].uppercaseString;
	[self.facebookButton setTitle:fbButtonTitle forState:UIControlStateNormal];
	self.facebookButton.exclusiveTouch = YES;

	NSDictionary * fbLogin = [[MZThemeManager sharedInstance] appInfo:MZThemeAppInfo.facebookLogin];
	if(fbLogin != nil)
	{
		[self.facebookButton setHidden:false];
	}
	else
	{
		[self.facebookButton setHidden:true];
	}
	
	NSString *googleButtonTitle = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"mobile_signin_with", ""), @"  \uE802"].uppercaseString;
	[self.googlePlusButton setTitle:googleButtonTitle forState:UIControlStateNormal];
	self.googlePlusButton.exclusiveTouch = YES;
	
	NSDictionary * googleLogin = [[MZThemeManager sharedInstance] appInfo:MZThemeAppInfo.googleLogin];
	if(googleLogin != nil)
	{
		[self.googlePlusButton setHidden:false];
	}
	else
	{
		[self.googlePlusButton setHidden:true];
	}*/
	
   
  //  [GIDSignIn sharedInstance].uiDelegate = self;
	
    [self.uiLbVersion setText:[MZDeviceInfoHelper getAppVersion]];
    [self.uiLbVersion setTextColor: [UIColor muzzleyGray3ColorWithAlpha:1.0]];
    
    self.signUpButton.exclusiveTouch = YES;
    [self.signUpButton setTitle:NSLocalizedString(@"mobile_signup", @"") forState: UIControlStateNormal];
    
    self.signInButton.exclusiveTouch = YES;
    [self.signInButton setTitle:NSLocalizedString(@"mobile_signin", @"") forState: UIControlStateNormal];
    self.signInButton.defaultBackgroundColor = [UIColor clearColor];
    self.signInButton.highlightBackgroundColor = [UIColor clearColor];
    [self.signInButton setTitleColor:[UIColor muzzleyBlueColorWithAlpha:1] forState:UIControlStateNormal];
    self.signInButton.borderColor = [UIColor muzzleyBlueColorWithAlpha:1];
    self.signInButton.borderWidth = 1;
    
    
    self.signInCustomButton.hidden = YES;
    self.signInButton.hidden = NO;
    self.signUpButton.hidden = NO;
    
    [self.signInCustomButtonHeightConstraint setConstant:0];

	
	
	self.uiLabelTerms.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
	self.uiLabelTerms.delegate = self; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
	
	self.uiLabelTerms.text = [NSString stringWithFormat: NSLocalizedString(@"mobile_accept_terms_text", ""), NSLocalizedString(@"mobile_about_tc", @""), NSLocalizedString(@"mobile_about_pp", @"")];
	
	self.uiLabelTerms.linkAttributes = @{NSForegroundColorAttributeName: [UIColor muzzleyBlueColorWithAlpha:1],NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    self.uiLabelTerms.activeLinkAttributes = @{NSForegroundColorAttributeName: [UIColor muzzleyBlueColorWithAlpha:1],NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
	
	NSRange rangeTerms = [self.uiLabelTerms.text rangeOfString:NSLocalizedString(@"mobile_about_tc", @"")];
	[self.uiLabelTerms addLinkToURL:[NSURL URLWithString:@"action://show-terms"] withRange:rangeTerms];
	
	NSRange rangePrivacy = [self.uiLabelTerms.text rangeOfString:NSLocalizedString(@"mobile_about_pp", @"")];
	[self.uiLabelTerms addLinkToURL:[NSURL URLWithString:@"action://show-privacy"] withRange:rangePrivacy];

    
    NSString * titleHtml = [[MZThemeManager sharedInstance] getLocalizedCopyInCurrentLanguageWithKey:@"mobile_start_title_html"];
    NSAttributedString *titleAttributedString = [[NSAttributedString alloc]
                                            initWithData: [titleHtml dataUsingEncoding:NSUnicodeStringEncoding]
                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                            documentAttributes: nil
                                            error: nil
                                            ];

    self.uiTitle.attributedText = titleAttributedString;
    self.uiTitle.font = [UIFont semiboldFontOfSize:25];


    NSString * textHtml = [[MZThemeManager sharedInstance] getLocalizedCopyInCurrentLanguageWithKey:@"mobile_start_text_html"];
    NSAttributedString *textAttributedString = [[NSAttributedString alloc]
                                                 initWithData: [textHtml dataUsingEncoding:NSUnicodeStringEncoding]
                                                 options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                 documentAttributes: nil
                                                 error: nil
                                                 ];
    
    self.uiTextView.attributedText = textAttributedString;
    self.uiTextView.font = [UIFont lightFontOfSize:16];
	
    self.uiImage.image = [UIImage imageNamed:@"horizontal_logo_start"];
    if(self.uiImage.image == nil)
    {
        self.uiImage.backgroundColor = [UIColor muzzleyGray3ColorWithAlpha:1];
    }
}



- (void)loadedUserCache
{
	[_loadingView updateLoadingStatus:NO container:self.view];

}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	if ([[url scheme] hasPrefix:@"action"])
    {
		if ([[url host] hasPrefix:@"show-terms"])
		{
			MZWebViewController *vc = [MZWebViewController new];
			vc.url = [MZThemeManager sharedInstance].urls.termsServices;
			[self.wireframe.navigationController pushViewController:vc animated:NO];
		
			[self.wireframe.navigationController.navigationBar setBackgroundColor: [MZThemeManager sharedInstance].colors.primaryColor];
			[self.wireframe.navigationController.navigationBar setTintColor: [MZThemeManager sharedInstance].colors.primaryColorText];
		
			[self.wireframe.navigationController.navigationBar setBarTintColor: [MZThemeManager sharedInstance].colors.primaryColor];
		
		
			[[UIApplication sharedApplication] setStatusBarHidden:YES];
		}
		else if ([[url host] hasPrefix:@"show-privacy"])
		{
			MZWebViewController *vc = [MZWebViewController new];
			vc.url = [MZThemeManager sharedInstance].urls.privacyPolicy;
			[self.wireframe.navigationController pushViewController:vc animated:NO];
		
			[self.wireframe.navigationController.navigationBar setBackgroundColor: [MZThemeManager sharedInstance].colors.primaryColor];
			[self.wireframe.navigationController.navigationBar setTintColor: [MZThemeManager sharedInstance].colors.primaryColorText];
		
			[self.wireframe.navigationController.navigationBar setBarTintColor: [MZThemeManager sharedInstance].colors.primaryColor];
		
			[[UIApplication sharedApplication] setStatusBarHidden:YES];
		}
	}
    else
    {
		// Do nothing
		/* deal with http links here */
	}
}

-(void)viewDidLayoutSubviews {
	[self.uiTextView setContentOffset:CGPointZero animated:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.wireframe.navigationController.navigationBar setBackgroundColor: [UIColor clearColor]];
	[self.wireframe.navigationController.navigationBar setTintColor: [UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
	

	[super viewDidAppear:animated];
	
	[self fadeInUI];
	
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_loadingView updateLoadingStatus:NO container:self.view];

	[super viewWillDisappear:animated];

}

/*- (void)beginFacebookLoginAuthentication
{
    [MZAnalyticsInteractor signInStartEvent:MIXPANEL_VALUE_FACEBOOK];
    [self setLoginAttemptAnimationEnabled:YES];
    [self.interactor logInWithFacebook];
}

- (void)beginGooglePlusLoginAuthentication
{
    [MZAnalyticsInteractor signInStartEvent:MIXPANEL_VALUE_GOOGLE];
    [self setLoginAttemptAnimationEnabled:YES];
    [self.interactor logInWithGooglePlus];
}*/



#pragma mark - Interactor output
- (void)logInOperationDidComplete
{
	
	[_loadingView updateLoadingStatus:NO container:self.view];

    [self setLoginAttemptAnimationEnabled:YES];

	[[MZSessionDataManager sharedInstance] getSessionInfo:^(BOOL result) {
        [self setLoginAttemptAnimationEnabled:NO];

		if(result == true)
		{
			if ([self.delegate respondsToSelector:@selector(userAuthViewControllerDidAuthenticate:)]) {
				[self.delegate userAuthViewControllerDidAuthenticate:self];
			}
			
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:UserAuthModuleDidAuthenticateNotification
			 object:self
			 userInfo:nil];
		}
		else
		{
			[self presentGetUserError];
		}

	}];
}

- (void)logInOperationDidFailWithError:(NSError *)error
{
	[_loadingView updateLoadingStatus:NO container:self.view];

	
    NSString *title = error.localizedDescription;
    if (!title) {
        title = @"";
    }
    NSString *description = error.localizedFailureReason;
    if (!description) {
        description = @"";
    }
	
	// TODO:GETUSER Add popup error here for fb and google get user
    [self alertWithTitle:error.localizedDescription description:error.localizedFailureReason];
    [self setLoginAttemptAnimationEnabled:NO];
	[_loadingView updateLoadingStatus:NO container:self.view];

}




- (void)presentGetUserError
{
	[_loadingView updateLoadingStatus:NO container:self.view];

	if (!_popupView)
	{
		PopupContentView* popupContentView = [PopupContentView loadFromNib];
		popupContentView.delegate = self;
		popupContentView.message = NSLocalizedString(@"mobile_get_user_error_text", comment: @"");
		
		NSString * namespace = [MZThemeManager sharedInstance].appInfo.namespace;
		
		if([namespace  isEqual: @"muzzley"])
		{
            popupContentView.image = [UIImage appIcon];
		}
		
		popupContentView.topColor = [UIColor muzzleyWhiteColorWithAlpha:1.0];
		popupContentView.textColor = [UIColor muzzleyGray2ColorWithAlpha:1.0];
		popupContentView.hasImage = YES;
		popupContentView.btnStrings = @[NSLocalizedString(@"mobile_contact_us", comment: @""), NSLocalizedString(@"mobile_cancel", comment: @"")];
		popupContentView.identifier = 1001;
		_popupView = [KLCPopup popupWithContentView:popupContentView
										   showType:KLCPopupShowTypeSlideInFromTop
										dismissType:KLCPopupDismissTypeNone
										   maskType:KLCPopupMaskTypeDimmed
						   dismissOnBackgroundTouch:NO
							  dismissOnContentTouch:NO];
		
		[_popupView show];
	}
}

- (void)didTapOnPopupButtonAtIndex:(PopupContentView *)sender btnIndex:(NSInteger)btnIndex
{
	[[MZSessionDataManager sharedInstance] logout];
	[self setLoginAttemptAnimationEnabled:NO];
	[self fadeOutUI];


	if (sender.identifier == 1001)
	{
		switch(btnIndex)
		{
			case 0:
				if ([MFMailComposeViewController canSendMail])
				{
					MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
					mail.mailComposeDelegate = self;
					[mail setSubject:NSLocalizedString(@"mobile_feedback_subject", @"")];
					[mail setToRecipients:@[@"support@muzzley.com"]];
					NSString * message = [NSString stringWithFormat:@"%@ %@ %@", @"App version: iOS ",[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
					[mail setMessageBody:message isHTML:NO];
					[self presentViewController:mail animated:YES completion:NULL];
				}
				else
				{
					DLog(@"This device cannot send email");
				}
				
				break;
				
			default:
	
				break;
				
		}
		_popupView = nil;
	} else {
		_popupView = nil;
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result) {
		case MFMailComposeResultSent:
			DLog(@"You sent the email.");
			break;
		case MFMailComposeResultSaved:
			DLog(@"You saved a draft of this email");
			break;
		case MFMailComposeResultCancelled:
			DLog(@"You cancelled sending this email.");
			break;
		case MFMailComposeResultFailed:
			DLog(@"Mail failed:  An error occurred when trying to compose this email");
			break;
		default:
			DLog(@"An error occurred when trying to compose this email");
			break;
	}
 
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MZUserAuthViewInterface
- (void)setLoginAttemptAnimationEnabled:(BOOL)enabled
{
    if (enabled) {
        
     //   self.facebookButton.alpha = 0;
     //   self.googlePlusButton.alpha = 0;
        [self.activityIndicator startAnimating];
        
    } else {

        [self.activityIndicator stopAnimating];
    //    self.facebookButton.alpha = 1;
    //    self.googlePlusButton.alpha = 1;
    }
}

- (void)fadeInUI
{
    if(self.signInViewArea.alpha != 1)
    {
        __typeof__(self) __weak weakSelf = self;
        [UIView animateWithDuration:0.13 animations:^{
            weakSelf.signInViewArea.alpha = 1;
        }];
    }
}

- (void)fadeOutUI
{
    if(self.signInViewArea.alpha != 0)
    {
        __typeof__(self) __weak weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.signInViewArea.alpha = 0;
        }];
    }
}

- (void)alertWithTitle:(NSString *)title description:(NSString *)description
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Actions
/*- (IBAction)facebookButtonClicked:(id)sender
{
    [self beginFacebookLoginAuthentication];
}

- (IBAction)googlePlusButtonClicked:(id)sender
{
    [self beginGooglePlusLoginAuthentication];
    [[GIDSignIn sharedInstance] signIn];
}*/

- (IBAction)signInCustomButton_TouchUpInside:(id)sender
{
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    if([internetReachable currentReachabilityStatus] == NotReachable)
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"mobile_no_internet_title", @"")
                                              message:NSLocalizedString(@"mobile_no_internet_text", @"")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    if(![self.uiTermsCheckBox isChecked])
    {
        [self alertWithTitle:NSLocalizedString(@"mobile_must_accept_terms", @"") description:@""];
        return;
    }
    
    
	[_loadingView updateLoadingStatus:NO container:self.view];

	[self.wireframe showCustomSignInScreenAnimated:NO];
	[self fadeOutUI];
}

- (IBAction)signInButtonClicked:(id)sender
{
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    if([internetReachable currentReachabilityStatus] == NotReachable)
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"mobile_no_internet_title", @"")
                                              message:NSLocalizedString(@"mobile_no_internet_text", @"")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    if(![self.uiTermsCheckBox isChecked])
    {
        [self alertWithTitle:NSLocalizedString(@"mobile_must_accept_terms", @"") description:@""];

        return;
    }
    
	[_loadingView updateLoadingStatus:NO container:self.view];

    [MZAnalyticsInteractor signInStartEvent:MIXPANEL_VALUE_EMAIL];
    [self.wireframe showSignInScreenAnimated:NO];
    [self fadeOutUI];
}



- (IBAction)signUpButtonClicked:(id)sender
{
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    if([internetReachable currentReachabilityStatus] == NotReachable)
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"mobile_no_internet_title", @"")
                                              message:NSLocalizedString(@"mobile_no_internet_text", @"")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    if(![self.uiTermsCheckBox isChecked])
    {
        [self alertWithTitle:NSLocalizedString(@"mobile_must_accept_terms", @"") description:@""];

        return;
    }
    
	[_loadingView updateLoadingStatus:NO container:self.view];

    [MZAnalyticsInteractor signUpStartEvent:MIXPANEL_VALUE_EMAIL];
    [self.wireframe showSignUpScreenAnimated:NO];
    [self fadeOutUI];
}


#pragma mark - GIDSignInUIDelegate

/*- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    [self beginGooglePlusLoginAuthentication];
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/


@end
