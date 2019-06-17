//
//  MZUserAuthWireframe.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 29/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UserAuthWireframe.h"

#import "UserAuthViewController.h"
#import "UserAuthSignInViewController.h"
#import "UserAuthSignUpViewController.h"
#import "UserAuthResetPasswordViewController.h"


@interface UserAuthWireframe () <UserAuthSignInViewControllerDelegate, UserAuthResetPasswordViewControllerDelegate, UserAuthSignUpViewControllerDelegate>


@end


@implementation UserAuthWireframe

- (void)dealloc
{
    [self.navigationController removeFromParentViewController];
    self.navigationController = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        UINavigationControllerPortrait *navigationController = [UINavigationControllerPortrait new];
        navigationController.navigationBarTransparentBackground = YES;
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController = navigationController;
    }
    return self;
}

- (void) setRootViewController:(UIViewController*) viewController
{
    [self.navigationController pushViewController:viewController animated:NO];
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background_image"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.navigationController.view.frame;
    UIView * protectView = [[UIView alloc] initWithFrame:imageView.frame];
    protectView.backgroundColor = [UIColor whiteColor];
    protectView.alpha = 0.80;
    [imageView addSubview:protectView];
    
    [self.navigationController.view insertSubview:imageView atIndex:0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor muzzleyBlackColorWithAlpha:1]}];
    self.navigationController.navigationBar.tintColor =  [UIColor muzzleyBlackColorWithAlpha:1];
    
}

- (void)showSignInScreenAnimated:(BOOL)animated
{
    UserAuthSignInViewController *signInViewController = [UserAuthSignInViewController new];
    signInViewController.delegate = self;
    
    [self.navigationController pushViewController:signInViewController animated:animated];
}


- (void)showCustomSignInScreenAnimated:(BOOL)animated
{
	MZUserAuthCustomSignInViewController *customSignInViewController = [MZUserAuthCustomSignInViewController new];
	//customSignInViewController.delegate = self;
	[self.navigationController.navigationBar setBackgroundColor: [MZThemeManager sharedInstance].colors.primaryColor];
	[self.navigationController.navigationBar setTintColor: [MZThemeManager sharedInstance].colors.primaryColorText];
	
	[self.navigationController.navigationBar setBarTintColor: [MZThemeManager sharedInstance].colors.primaryColor];

	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [MZThemeManager sharedInstance].colors.primaryColorText}];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	[self.navigationController pushViewController:customSignInViewController animated:animated];
}

- (void)showResetPasswordScreenWithEmail:(NSString *)email animated:(BOOL)animated fromVC:(UIViewController*)viewController
{
    UserAuthResetPasswordViewController *resetPasswordViewController = [[UserAuthResetPasswordViewController alloc] initWithEmail:email];
    resetPasswordViewController.delegate = self;
    
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController pushViewController:resetPasswordViewController animated:animated];
}

- (void)showSignUpScreenAnimated:(BOOL)animated
{
    UserAuthSignUpViewController *signUpViewController = [UserAuthSignUpViewController new];
    signUpViewController.delegate = self;

    [self.navigationController pushViewController:signUpViewController animated:animated];
}

#pragma mark - UserAuthSignInViewController Delegate
- (void)userAuthSignInViewController:(UserAuthSignInViewController *)viewController didSelectPasswordRecoveryForEmail:(NSString *)email
{
    [self showResetPasswordScreenWithEmail:email animated:YES fromVC:viewController] ;
}

- (void)userAuthSignInViewControllerDidSignIn:(UserAuthSignInViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self.userAuthViewController logInOperationDidComplete];
}


#pragma mark - UserAuthResetPasswordViewController Delegate
- (void)userAuthResetPasswordViewControllerDidSendPasswordRecoveryEmail:(UserAuthResetPasswordViewController *)viewController
{
    //[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UserAuthSignUpViewController Delegate
- (void)userAuthSignUpViewControllerDidSignUp:(UserAuthSignUpViewController *)viewController
{
    [self.userAuthViewController logInOperationDidComplete];
}

@end
