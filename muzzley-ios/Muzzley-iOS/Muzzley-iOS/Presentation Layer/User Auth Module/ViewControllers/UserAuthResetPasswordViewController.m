//
//  UserAuthResetPasswordViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "UserAuthResetPasswordViewController.h"
//#import "AFHTTPRequestOperationManager.h"
#import "MZColorButton.h"

@interface UserAuthResetPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *uiLoadingView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet MZColorButton *passwordRecoveryButton;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic, copy) NSString *email;


@property (nonatomic) MZOAuthWebService *oAuthWebService;
@end

@implementation UserAuthResetPasswordViewController

- (void)dealloc
{
 //   [self.HTTPClient.operationQueue cancelAllOperations];
    self.alertView.delegate = nil;
    [self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithEmail:(NSString *)email
{
    if (self = [super init]) {
        self.email = email;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.title = NSLocalizedString(@"mobile_reset_pass", @"");

    
    self.label.text = NSLocalizedString(@"mobile_reset_pass_description", @"");
    self.label.textColor = [UIColor muzzleyBlackColorWithAlpha:1];
    
    self.emailTextField.text = self.email;
    
    NSAttributedString *emailAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_email", @"") attributes:@{ NSForegroundColorAttributeName : [UIColor muzzleyBlackColorWithAlpha:1] }];
    self.emailTextField.attributedPlaceholder = emailAttributedString;
    self.emailTextField.delegate = self;
    
    // Send Email button configuration
    self.uiLoadingView.backgroundColor = [UIColor muzzleyBlackColorWithAlpha:0.2];
    [self.uiLoadingView setHidden:true];
    
    [self.passwordRecoveryButton addTarget:self action:@selector(_didPressPasswordRecoveryButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordRecoveryButton setTitle:NSLocalizedString(@"mobile_reset_pass", @"") forState:UIControlStateNormal];
    
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.passwordRecoveryButton.enabled = NO;
    } else {
        self.passwordRecoveryButton.enabled = YES;
    }
    self.passwordRecoveryButton.exclusiveTouch = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    

	
    [MZAnalyticsInteractor forgotPasswordStartEvent];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
}


- (void)_didPressPasswordRecoveryButton:(id)sender
{
    __typeof__(self) __weak weakSelf = self;
	
    [self.passwordRecoveryButton setTitle:NSLocalizedString(@"mobile_send_mail_loading", @"") forState:UIControlStateNormal];

    [self.uiLoadingView setHidden:false];
    self.passwordRecoveryButton.enabled = NO;
    
    [self.view endEditing:YES];
    
    NSString *email = self.emailTextField.text;
    if (email == nil || [email  isEqual: @""] )
    {
        return;
    }
    
    [[MZOAuthWebService sharedInstance] resetPasswordWithEmail:email completion:^(id responseObject, NSError * error) {
        if(error == nil)
        {
            if (!weakSelf) return;
            [weakSelf _enablePasswordRecoveryButtonIfNeeded];

            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_success", @"") message:NSLocalizedString(@"mobile_reset_pass_confirm", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"") otherButtonTitles:nil, nil];
    
                [weakSelf.alertView show];
    
                if ([weakSelf.delegate respondsToSelector:@selector(userAuthResetPasswordViewControllerDidSendPasswordRecoveryEmail:)]) {
                    [weakSelf.delegate userAuthResetPasswordViewControllerDidSendPasswordRecoveryEmail:weakSelf];
                }
            
            [MZAnalyticsInteractor forgotPasswordRequestFinishEvent];
        }
        else
        {
            if (!weakSelf) return;
            
            [weakSelf _enablePasswordRecoveryButtonIfNeeded];
            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_error_title", @"") message:NSLocalizedString(@"mobile_error_text", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"") otherButtonTitles:nil, nil];
                [weakSelf.alertView show];
                return;
            }
    }];
}

- (void)_textFieldDidChange:(NSNotification *)notification
{
    [self _enablePasswordRecoveryButtonIfNeeded];
}

- (void)_enablePasswordRecoveryButtonIfNeeded
{
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.passwordRecoveryButton.enabled = NO;
        return;
    }
    
    [self.passwordRecoveryButton setTitle:NSLocalizedString(@"mobile_reset_pass", @"") forState:UIControlStateNormal];
    [self.uiLoadingView setHidden:true];
    self.passwordRecoveryButton.enabled = YES;
    
    return;
}

@end
