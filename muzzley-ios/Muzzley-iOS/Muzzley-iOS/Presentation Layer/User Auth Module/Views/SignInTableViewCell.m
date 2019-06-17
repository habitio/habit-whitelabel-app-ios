//
//  SignInTableViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "SignInTableViewCell.h"

#import "MZColorButton.h"

@interface SignInTableViewCell () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, weak) IBOutlet MZColorButton *signInButton;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation SignInTableViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
	
    NSAttributedString *emailAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_email", @"") attributes:@{ NSForegroundColorAttributeName : [UIColor muzzleyBlackColorWithAlpha:1] }];
    self.emailTextField.attributedPlaceholder = emailAttributedString;
    self.emailTextField.delegate = self;
    
    NSAttributedString *passwordAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_password", @"") attributes:@{ NSForegroundColorAttributeName : [UIColor muzzleyBlackColorWithAlpha:1] }];
    self.passwordTextField.attributedPlaceholder = passwordAttributedString;
    self.passwordTextField.delegate = self;
    
    // Sign In button configuration
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.color = [UIColor lightGrayColor];
    [self.signInButton addSubview:indicator];
    self.activityIndicatorView = indicator;
    [indicator stopAnimating];
    
    [self.signInButton addTarget:self action:@selector(_didPressSignInButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.signInButton setTitle:NSLocalizedString(@"mobile_signin", @"") forState:UIControlStateNormal];
    self.signInButton.enabled = NO;
    self.signInButton.exclusiveTouch = YES;
	
	[self.forgotPasswordButton setAttributedTitle:nil forState:UIControlStateNormal];
	[self.forgotPasswordButton setTitle: NSLocalizedString(@"mobile_forgot_password", @"") forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:[UIColor muzzleyBlueColorWithAlpha:1] forState:UIControlStateNormal];
    self.forgotPasswordButton.tintColor = [UIColor muzzleyBlueColorWithAlpha:1];
    [self.forgotPasswordButton addTarget:self action:@selector(_didPressForgotPasswordButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton.titleLabel setFont:[UIFont mediumFontOfSize:14]];
    self.forgotPasswordButton.exclusiveTouch = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = self.activityIndicatorView.superview.bounds.size.width - 20;
    CGFloat y = self.activityIndicatorView.superview.bounds.size.height * 0.5;
    self.activityIndicatorView.center = CGPointMake(x, y);
}

- (void)enableUserInteractionIfNeeded
{
    [self _enableSignInButtonIfNeeded];
}

- (NSString *)email
{
    return self.emailTextField.text;
}

#pragma mark - Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.emailTextField.isFirstResponder) {
        [self.passwordTextField becomeFirstResponder];
    } else if (self.passwordTextField.isFirstResponder) {
        [self endEditing:YES];
    }
    return YES;
}

#pragma mark - Private Methods
- (void)_didPressSignInButton:(id)sender
{
//    [self.signInButton setTitle:NSLocalizedString(@"mobile_signin_loading", @"") forState:UIControlStateNormal];
//    [self.activityIndicatorView startAnimating];
//    self.signInButton.enabled = NO;
    
    [self endEditing:YES];
    self.forgotPasswordButton.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(signInTableViewCell:didSelectSignInActionWithEmail:password:)]) {
            
        NSString *email = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
        
        [self.delegate signInTableViewCell:self didSelectSignInActionWithEmail:email password:password];
    }
}

- (void)_didPressForgotPasswordButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(signInTableViewCell:didSelectForgotPasswordActionWithEmail:)]) {
        
         NSString *email = self.emailTextField.text;
        [self.delegate signInTableViewCell:self didSelectForgotPasswordActionWithEmail:email];
    }
}

- (void)_textFieldDidChange:(NSNotification *)notification {
    [self _enableSignInButtonIfNeeded];
}

- (void)_enableSignInButtonIfNeeded
{
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.signInButton.enabled = NO;
        return;
    }
    
    if ([self.passwordTextField.text isEqualToString:@""]) {
        self.signInButton.enabled = NO;
        return;
    }
    
    
    [self.signInButton setTitle:NSLocalizedString(@"mobile_signin", @"") forState:UIControlStateNormal];
    [self.activityIndicatorView stopAnimating];
    self.signInButton.enabled = YES;
    
    self.forgotPasswordButton.enabled = YES;
    
    return;
}

@end
