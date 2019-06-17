//
//  MZKeyboardViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/12/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import "MZKeyboardViewController.h"

#import <QuartzCore/QuartzCore.h>

typedef enum {
    MZKeyboardStatePlaceholder  = 1,
    MZKeyboardStateWriting      = 2
} MZKeyboardState;

@interface MZKeyboardViewController ()

@property (nonatomic, strong, readwrite) IBOutlet UIButton *buttonSend;
@property (nonatomic, strong, readwrite) IBOutlet UITextView *textView;

@property (nonatomic, assign) MZKeyboardState state;

@property (nonatomic, copy) NSString *textToSend;

@property (nonatomic, assign) NSUInteger maxTextLenght;
@property (nonatomic, assign) bool placeholderVisible;

/// private signaling mzmessage for communication with activity
@property (nonatomic, strong) MZMessage *messageSignaling;

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation MZKeyboardViewController

@synthesize buttonSend;
@synthesize textView;

- (void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
}

#pragma mark Initializers

-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZKeyboardViewController *keyboardViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZKeyboardViewController"];
    self = keyboardViewController;
    
    if (self) {
        // Custom initialization
        self.parameters = parameters;
    }
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self.textFieldView becomeFirstResponder];
    //self.textFieldView.delegate = self;
    
    self.textToSend = [[NSMutableString alloc] init];
    
    [self.textView becomeFirstResponder];
    self.textView.delegate = self;
    
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.borderColor = [[UIColor colorWithRed:0.0
                                                       green:0.0
                                                        blue:0.0
                                                       alpha:0.2] CGColor];
    self.textView.layer.borderWidth = 1;
    
    
    self.titleLabel.text = @"";
    if ([self.parameters objectForKey:@"title"]) {
        
        self.titleLabel.text = [self.parameters objectForKey:@"title"] ;
    }
    
    self.placeholderVisible = NO;
    
    if ([self.parameters objectForKey:@"placeholder"]) {
        
        self.placeholderVisible = YES;
        self.placeholderLabel.text = [NSString stringWithFormat:@"  %@", [self.parameters objectForKey:@"placeholder"]];
    }
    
    self.maxTextLenght = 256;
    if ([self.parameters objectForKey:@"length"]) {
        
        self.maxTextLenght = [[self.parameters objectForKey:@"length"] unsignedIntValue];
        self.maxTextLenght = MAX(0, MIN(256, _maxTextLenght));
    }
    
    if ([self.parameters objectForKey:@"type"]) {
        
        NSString *keyboardType = [self.parameters objectForKey:@"type"];
        
        if ([keyboardType isEqualToString:@"default"]) {
            self.textView.keyboardType = UIKeyboardTypeASCIICapable;
        } else if ([keyboardType isEqualToString:@"numpad"]) {
            self.textView.keyboardType = UIKeyboardTypeNumberPad;
        }
    }
    
    [self.buttonSend setTitle:@"Send" forState:UIControlStateNormal];
    
    if ([self.parameters objectForKey:@"submitLabel"]) {
        
        NSString *buttonSendTitle = [self.parameters objectForKey:@"submitLabel"];
        
        if (![buttonSendTitle isEqualToString:@""]) {
            
            [self.buttonSend setTitle:buttonSendTitle forState:UIControlStateNormal];
        }
    }
    
    self.maxNumCharsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_maxTextLenght];
    self.buttonSend.enabled = NO;
}

#pragma mark View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark Private methods
#pragma mark - Quit Activity flow

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)])
            [self.delegate widgetNeedsToDismiss:self];
    }
}

#pragma mark -
#pragma mark TextView Delegate methods

-(void) textViewDidChange:(UITextView *)aTextView
{
    if( aTextView.text.length == 0 ) [self changeToState:MZKeyboardStatePlaceholder];
    else                             [self changeToState:MZKeyboardStateWriting];
    
    self.maxNumCharsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(_maxTextLenght - aTextView.text.length)];
    //string = [string substringToIndex:[string length] - 1];
}
#pragma mark TextView Delegate
-(BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length > 0 && [text isEqualToString:@""]) { ///backspace
        return YES; 
    }
       
    if (aTextView.text.length >= _maxTextLenght) {
        return NO;
    }
    //if([text isEqualToString:@"\n"]) {
    return YES;
}

- (IBAction)sendMessage:(id)sender
{
    if (![self.textView.text isEqualToString:@""]) {
        
        [self _didSendText:self.textView.text];
    }
    
    [self changeToState:MZKeyboardStatePlaceholder];
    
    self.textView.text = @"";
    self.maxNumCharsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_maxTextLenght];
}

- (void) changeToState:(MZKeyboardState) aState
{
    self.state = aState;
    if (_state ==  MZKeyboardStatePlaceholder) {
        
        self.placeholderVisible = YES;
        self.placeholderLabel.hidden = NO;
        self.buttonSend.enabled = NO;
        
    } else if (_state ==  MZKeyboardStateWriting) {
        
        self.placeholderVisible = NO;
        self.placeholderLabel.hidden = YES;
        self.buttonSend.enabled = YES;
    }
}

#pragma mark - Activity Communication Signaling 
- (void)_didSendText:(NSString *)text
{
    NSString *widget = @"keyboard";
    NSString *component = @"kb";
    NSString *value = text;
    NSString *event = @"send";
    
    NSDictionary *dataProtocol = [NSDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

@end
