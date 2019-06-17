//
//  UserAuthSignInViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "UserAuthSignInViewController.h"

#import "SignInTableViewCell.h"

@interface UserAuthSignInViewController () <UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate,UITableViewDataSource, SignInTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) UIAlertView *alertView;
@property (weak, nonatomic) IBOutlet UIView *uiLoadingView;

@end

@implementation UserAuthSignInViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.alertView.delegate = nil;
    [self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
	
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.uiLoadingView.backgroundColor = [UIColor muzzleyBlackColorWithAlpha:0.2];
    [self.uiLoadingView setHidden:true];
    
    self.title = NSLocalizedString(@"mobile_signin", @"");
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
    // Register the create worker tableview cell
    UINib *signInCellNib = [UINib nibWithNibName:CELL_ID_SIGN_IN bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:signInCellNib forCellReuseIdentifier:CELL_ID_SIGN_IN];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _enableSignInCellUserInteractionIfNeeded];
    
    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.tableView.alpha = 1;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.tableView.alpha = 0;
    }];
}

- (void)fadeInUI
{
    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.13 animations:^{
        weakSelf.tableView.alpha = 0;
    }];
}

- (void)fadeOutUI
{
    __typeof__(self) __weak weakSelf = self;
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.tableView.alpha = 1;
    }];
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.bounds.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SIGN_IN forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - SignInTableViewCellDelegate

- (void)signInTableViewCell:(SignInTableViewCell *)cell didSelectSignInActionWithEmail:(NSString *)email password:(NSString *)password
{
	__typeof__(self) __weak weakSelf = self;
    [self.uiLoadingView setHidden:false];
	NSString * clientId = [MZThemeManager sharedInstance].appInfo.appId;
	
	[[MZOAuthWebService sharedInstance] signInClientId: clientId username:email password:password completion:^(id response, NSError * error)
	{
		if(response)
		{
			MZUserAuthInfo *authInfo = [[MZSession sharedInstance] authInfo];
			[MZAnalyticsInteractor configureIdentity:authInfo];
			[MZAnalyticsInteractor signInFinishEvent:@"email" errorMessage:nil];
			[MZAnalyticsInteractor flush];
		
			if ([weakSelf.delegate respondsToSelector:@selector(userAuthSignInViewControllerDidSignIn:)])
			{
				[weakSelf.delegate userAuthSignInViewControllerDidSignIn:weakSelf];
			}
		}
		else
		{
			// TODO:GETUSER Show popup error here for email signin/up!
			if (weakSelf)
			{
				NSString *errorMessage = error.localizedDescription ? error.localizedDescription : @"";
				[MZAnalyticsInteractor signInFinishEvent:@"email" errorMessage:errorMessage];
				[MZAnalyticsInteractor flush];
		
                NSString * errorCode = [MZErrorHandlingHelper getErrorCodeWithError:error];
                [weakSelf _enableSignInCellUserInteractionIfNeeded];
                
                if([errorCode  isEqual: @"1601"])
                {
                    weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signin_error", @"") message:NSLocalizedString(@"mobile_signin_invalid_text", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
                }
			
				// Show Error to User
				// Activate Recover Password
				else if (error.code == 409)
				{
					weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signin_error", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:NSLocalizedString(@"mobile_reset_pass", @""), nil];
				}
				else
				{
					weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signin_error", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
				}
                
				weakSelf.alertView.delegate = self;
				[weakSelf.alertView show];
			}
		}
        [self.uiLoadingView setHidden:true];

	}];
}

- (void)signInTableViewCell:(SignInTableViewCell *)cell didSelectForgotPasswordActionWithEmail:(NSString *)email
{
    if([self.delegate respondsToSelector:@selector(userAuthSignInViewController:didSelectPasswordRecoveryForEmail:)])
    {
        [self.delegate userAuthSignInViewController:self didSelectPasswordRecoveryForEmail:email];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if([self.delegate respondsToSelector:@selector(userAuthSignInViewController:didSelectPasswordRecoveryForEmail:)])
        {
            if (self.tableView.visibleCells.count == 1 ) {
                SignInTableViewCell *cell = [self.tableView.visibleCells objectAtIndex:0];
                [self.delegate userAuthSignInViewController:self didSelectPasswordRecoveryForEmail:cell.email];
            }
        }
    }
}

#pragma mark - Private Methods
- (void)_enableSignInCellUserInteractionIfNeeded
{
    if (self.tableView.visibleCells.count == 1 )
    {
        SignInTableViewCell *cell = [self.tableView.visibleCells objectAtIndex:0];
        [cell enableUserInteractionIfNeeded];
    }
}

@end
