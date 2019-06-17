//
//  UserAuthSignUpViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "UserAuthSignUpViewController.h"

//#import "MZSession.h"
#import "SignUpTableViewCell.h"

@interface UserAuthSignUpViewController () <UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate,UITableViewDataSource, SignUpTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) UIAlertView *alertView;
@property (weak, nonatomic) IBOutlet UIView *uiLoadingView;

@end

@implementation UserAuthSignUpViewController

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
    
    self.title = NSLocalizedString(@"mobile_signup", @"");
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    // Register the create worker tableview cell
    UINib *signInCellNib = [UINib nibWithNibName:CELL_ID_SIGN_UP bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:signInCellNib forCellReuseIdentifier:CELL_ID_SIGN_UP];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _enableSignUpCellUserInteractionIfNeeded];
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
    SignUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SIGN_UP forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - SignUpTableViewCellDelegate

- (void)signUpTableViewCell:(SignUpTableViewCell *)cell didSelectSignUpActionWithName:(NSString *)name email:(NSString *)email password:(NSString *)password
{
    [self.uiLoadingView setHidden:false];

    NSDictionary *parameters;
    NSString * namespace = [MZThemeManager sharedInstance].appInfo.namespace;
    if(namespace != nil)
        parameters = @{ @"name":name, @"email":email ,@"password":password, @"device":@"iphone", @"appId": namespace};
    else
        parameters = @{ @"name":name, @"email":email ,@"password":password, @"device":@"iphone"};
    
      [self didSelectSignUpActionWithParameters:parameters];
}


- (void)didSelectSignUpActionWithParameters:parameters
{
	__typeof__(self) __weak weakSelf = self;
	
    NSString * clientId = [MZThemeManager sharedInstance].appInfo.appId;
	
	NSString *email = parameters[@"email"];
	NSString *password = parameters[@"password"];
	NSString *name = parameters[@"name"];
	NSString *loginType = parameters[@"authType"];
	
	[[MZOAuthWebService sharedInstance]  signUpWithParameters: parameters completion:^(id response, NSError * error)
	{
		if(error == nil)
		{
            if (!weakSelf) return;

            // Sign in
            [[MZOAuthWebService sharedInstance] signInClientId: clientId username:email password:password completion:^(id response, NSError * error)
             {
                if(error == nil)
                {
                    // Get session info
                    [NSThread sleepForTimeInterval:2.0f];
                    [[MZSessionDataManager sharedInstance] getSessionInfo:^(BOOL result)
                    {
                        if(result)
                        {
                            [MZAnalyticsInteractor configureIdentity:[[MZSession sharedInstance] authInfo]];
                            [MZAnalyticsInteractor signUpFinishEvent:loginType errorMessage:nil];
                            [MZAnalyticsInteractor flush];
                    
                            [weakSelf _enableSignUpCellUserInteractionIfNeeded];
                    
                            if ([weakSelf.delegate respondsToSelector:@selector(userAuthSignUpViewControllerDidSignUp:)]) {
                                [weakSelf.delegate userAuthSignUpViewControllerDidSignUp:weakSelf];
                            }
    //                        [self.uiLoadingView setHidden:true];

                        }
                        else
                        {
    //						NSString * xcode = [[[[error userInfo] valueForKey:@"com.alamofire.serialization.response.error.response"] allHeaderFields] valueForKey:@"X-Error"];
    //
                            NSString * message =  NSLocalizedString(@"mobile_error_text", @"");
    //
                            
                            DLog("%@", error.userInfo);
                            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signin_error", @"") message: message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
                        
                            weakSelf.alertView.delegate = self;
                            [weakSelf.alertView show];
                            [self.uiLoadingView setHidden:true];

                        }

                    }];
                }
                else
                {
                    NSString * xcode = [[[[error userInfo] valueForKey:@"com.alamofire.serialization.response.error.response"] allHeaderFields] valueForKey:@"X-Error"];
                    
                    NSString * message = error.localizedDescription;
                    
                    if(xcode != nil)
                    {
                        if([xcode isEqual: @"1211"]) // It already exists
                        {
                            message = xcode;
                        }
                    }
                    else
                    {
                        message = [NSString stringWithFormat:@"%ld",(long) error.code];
                    }
                    
                    DLog("%@", error.userInfo);
                    weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signin_error", @"") message: message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
                    
                    weakSelf.alertView.delegate = self;
                    [weakSelf.alertView show];
                    
                    [self.uiLoadingView setHidden:true];
                }
             }];
		}
		else
		{
			// Show Error to User
			
			NSString * xcode = [[[[error userInfo] valueForKey:@"com.alamofire.serialization.response.error.response"] allHeaderFields] valueForKey:@"X-Error"];
			NSString * message = NSLocalizedString(@"mobile_signup_invalid_text", @"");
			
			if(xcode != nil)
			{
				if([xcode isEqual: @"1211"]) // It already exists
				{
					message = NSLocalizedString(@"mobile_signup_already_done", @"");
				}
			}
//
			weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signup_error", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
				weakSelf.alertView.delegate = self;
				[weakSelf.alertView show];
            
            [self.uiLoadingView setHidden:true];

		}
	}];

}

#pragma mark - Private Methods
- (void)_enableSignUpCellUserInteractionIfNeeded
{
    if (self.tableView.visibleCells.count == 1 ) {
        SignUpTableViewCell *cell = [self.tableView.visibleCells objectAtIndex:0];
        [cell enableUserInteractionIfNeeded];
    }
}


@end
