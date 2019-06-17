//
//  SignUpTableViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 20/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "SignUpTableViewCell.h"

#import "MZColorButton.h"

@interface SignUpTableViewCell () <UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *btn_showPassword;
@property (nonatomic, weak) IBOutlet MZColorButton *signUpButton;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation SignUpTableViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

    NSAttributedString *nameAttributedString = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"mobile_username", @"") attributes:@{ NSForegroundColorAttributeName : [UIColor muzzleyBlackColorWithAlpha:1] }];
    self.nameTextField.attributedPlaceholder = nameAttributedString;
    self.nameTextField.delegate = self;
    [self.nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];

    
    NSAttributedString *emailAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_email", @"") attributes:@{ NSForegroundColorAttributeName : [UIColor muzzleyBlackColorWithAlpha:1] }];
    self.emailTextField.attributedPlaceholder = emailAttributedString;
    self.emailTextField.delegate = self;
    
    NSAttributedString *passwordAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_password", @"") attributes:@{ NSForegroundColorAttributeName : [UIColor muzzleyBlackColorWithAlpha:1] }];
    self.passwordTextField.attributedPlaceholder = passwordAttributedString;
    self.passwordTextField.delegate = self;
    
    // Sign In button configuration
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.color = [UIColor lightGrayColor];
    [self.signUpButton addSubview:indicator];
    self.activityIndicatorView = indicator;
    [indicator stopAnimating];
    
    [self.signUpButton addTarget:self action:@selector(_didPressSignUpButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton setTitle:NSLocalizedString(@"mobile_signup","") forState:UIControlStateNormal];
    self.signUpButton.enabled = NO;
    self.signUpButton.exclusiveTouch = YES;
    
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
    [self _enableSignUpButtonIfNeeded];
}

#pragma mark - Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.nameTextField.isFirstResponder) {
        [self.emailTextField becomeFirstResponder];
    } else if (self.emailTextField.isFirstResponder) {
        [self.passwordTextField becomeFirstResponder];
    } else if (self.passwordTextField.isFirstResponder) {
       [self endEditing:YES];
    }
    return YES;
}

#pragma mark - Private Methods
- (void)_didPressSignUpButton:(id)sender
{
//    [self.signUpButton setTitle:NSLocalizedString(@"mobile_signup_loading", @"") forState:UIControlStateNormal];
//    [self.activityIndicatorView startAnimating];
//    self.signUpButton.enabled = NO;
    
    [self endEditing:YES];
    
    if ([self.delegate respondsToSelector:@selector(signUpTableViewCell:didSelectSignUpActionWithName:email:password:)]) {
        
        NSString *name = self.nameTextField.text;
        NSString *email = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
		
		if([password length] < 6)
		{
			NSString * message = NSLocalizedString(@"mobile_pass_weak", @"");
						// Show Error to User
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signup_error", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
			alertView.delegate = self;
			[alertView show];
            [self.signUpButton setTitle:NSLocalizedString(@"mobile_signup","") forState:UIControlStateNormal];
            self.signUpButton.enabled = YES;

			return;
		}
        
        if([self validateEmailWithString:email] == false)
        {
            NSString * message = NSLocalizedString(@"mobile_email_invalid", @"");
            // Show Error to User
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signup_error", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
            alertView.delegate = self;
            [alertView show];
            [self.signUpButton setTitle:NSLocalizedString(@"mobile_signup","") forState:UIControlStateNormal];
            self.signUpButton.enabled = YES;
            
            return;
        }
        
        [self.delegate signUpTableViewCell:self didSelectSignUpActionWithName:name email:email
                                  password:password];
    }
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)_textFieldDidChange:(NSNotification *)notification {
    [self _enableSignUpButtonIfNeeded];
}

- (void)_enableSignUpButtonIfNeeded
{
    if ([self.nameTextField.text isEqualToString:@""]) {
        self.signUpButton.enabled = NO;
        return;
    }
    
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.signUpButton.enabled = NO;
        return;
    }
    
    if ([self.passwordTextField.text isEqualToString:@""]) {
        self.signUpButton.enabled = NO;
        return;
    }
    
    [self.signUpButton setTitle:NSLocalizedString(@"mobile_signup", @"") forState:UIControlStateNormal];
    [self.activityIndicatorView stopAnimating];
    self.signUpButton.enabled = YES;
    
    return;
}


- (IBAction)showPass:(UIButton *)sender
{
    if (self.passwordTextField.secureTextEntry == YES)
    {
        [self.btn_showPassword setImage:[UIImage imageNamed:@"invisible"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
    }
    
    else
    {
        [self.btn_showPassword setImage:[UIImage imageNamed:@"visible"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
    }
}

@end
