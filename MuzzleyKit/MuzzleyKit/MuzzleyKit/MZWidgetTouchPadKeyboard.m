//
//  MZWidgetTouchPadKeyboard.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 13/03/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZWidgetTouchPadKeyboard.h"

#import "MZUserClient.h"
#import "PulseView.h"

@interface MZWidgetTouchPadKeyboard () <UITextFieldDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, strong) UITextField *hiddenTextField;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) NSMutableArray *touchArray;
@end

@implementation MZWidgetTouchPadKeyboard

#pragma mark - Dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
   
}

#pragma mark - Initializers
-(id)initWithParameters:(NSDictionary*)parameters
{
    if (self = [super initWithNibName:@"MZWidgetTouchPadKeyboard" bundle:[NSBundle mainBundle]]) {
        self.parameters = parameters;
        self.touchArray = [NSMutableArray new];
    }
    return self;
}

#pragma mark View Rotation
/// iOS6
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self _showKeyboard];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

#pragma mark - Quit Activity flow
#pragma mark - alertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)]) {
            [self.delegate widgetNeedsToDismiss:self];
        }
    }
}

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textfield = notification.object;
    if ([textfield.text isEqualToString:@""]) {
        textfield.text = @" ";
    } else {
        self.label.text = textfield.text;
    }
}

- (void)keyboardFrameDidChange:(NSNotification *)notification {
    
    //NSValue *value = notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"];
    
}
#pragma mark Private methods
- (UIView *)touchVisualFeedbackWithRadius:(NSUInteger)radius
{
    UIView *touchView = [[UIView alloc] initWithFrame:CGRectMake(0,0,radius * 2,radius * 2)];
    touchView.alpha = 1;
    touchView.layer.cornerRadius = radius;
    touchView.backgroundColor = [UIColor redColor];
    touchView.layer.borderWidth = 5;
    touchView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    return touchView;
}

- (void)_showKeyboard {
    
    if (!_hiddenTextField) {
        self.hiddenTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, 200, 50)];
        [self.view addSubview:_hiddenTextField];
        _hiddenTextField.hidden = YES;
        _hiddenTextField.backgroundColor = [UIColor redColor];
        _hiddenTextField.text = @" ";
        _hiddenTextField.delegate = self;
        _hiddenTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _hiddenTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        [self.view addSubview:_label];
        _label.hidden = YES;
        _label.lineBreakMode = NSLineBreakByTruncatingHead;
        _label.userInteractionEnabled = NO;
        _label.backgroundColor = [UIColor lightGrayColor];
    }
    
    [_hiddenTextField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSLog(@"range lenght:%d", range.length);
    //NSLog(@"range lenght:%d", range.location);
    if (!string || [string isEqualToString:@". "]) {
        return NO;
    }
    
    if ([string isEqualToString:@""] && textField.text.length == 1) {
        [self _sendMessageWithComponent:@"kb" value:@"\b" event:@"chars"];
        return NO;
    }
    
    if ([string isEqualToString:@""]) {
        [self _sendMessageWithComponent:@"kb" value:@"\b" event:@"chars"];
    }
    else {
        [self _sendMessageWithComponent:@"kb" value:string event:@"chars"];
    }
    return YES;
}

// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}
// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [self _sendMessageWithComponent:@"kb" value:@"\n" event:@"chars"];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - Gesture Recognizers Handlers
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender
{
    //CGPoint location = [sender locationInView:self.view];
    //[self showPulseTouchWithLocation:location size:CGSizeMake(50, 50)];
    [self _sendMessageWithComponent:@"touchpad" value:@"" event:@"tap"];
}

- (IBAction)longPressDetected:(UILongPressGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
        //CGPoint location = [sender locationInView:self.view];
        //[self showPulseTouchWithLocation:location size:CGSizeMake(100, 100)];
            [self _sendMessageWithComponent:@"touchpad" value:@"" event:@"longPress"];
            break;
        }
        default:
            break;
    }
}
- (IBAction)panDetected:(UIPanGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
           
            break;
        case UIGestureRecognizerStateChanged:
        {
        //CGPoint velocity = [_panGestureRecognizer velocityInView:self.view];
            CGPoint translation = [_panGestureRecognizer translationInView:self.view];
            
        //translation.x = translation.x + 0.04 * velocity.x;
        //translation.y = translation.y + 0.04 * velocity.y;
        
            [self _sendTranslation:translation];
        
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
        //CGPoint velocity = [_panGestureRecognizer velocityInView:self.view];
            CGPoint translation = [_panGestureRecognizer translationInView:self.view];
        
        //translation.x = translation.x + 0.04 * velocity.x;
        //translation.y = translation.y + 0.04 * velocity.y;
        
            [self _sendTranslation:translation];
        
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    
    return YES;
}

- (void)showPulseTouchWithLocation:(CGPoint)location size:(CGSize)size
{
    NSUInteger radius = 25;
    PulseView *touch = [[PulseView alloc] initWithFrame:CGRectMake(0,0,radius * 2,radius * 2)];
    touch.center = CGPointMake(location.x, location.y);
    [touch pulseLongPress];
    [self.view addSubview:touch];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         touch.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [touch removeFromSuperview];
                     }];
}

#pragma mark - Activity Communication Signaling
- (void)_sendTranslation:(CGPoint)translation
{
    NSDictionary *value = @{
                            @"x": [NSNumber numberWithFloat:translation.x],
                            @"y": [NSNumber numberWithFloat:translation.y]
                          };
    [self _sendMessageWithComponent:@"touchpad" value:value event:@"touchMove"];
    
    // Reset translation
    [_panGestureRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)_sendMessageWithComponent:(NSString *)component
                            value:(id)value
                            event:(NSString *)event
{
    NSMutableDictionary *protocol = [NSMutableDictionary new];
    [protocol setObject:@"touchpadKeyboard" forKey:@"w"];
    [protocol setObject:component forKey:@"c"];
    
    if (value) {
        
        if ([component isEqualToString:@"kb"] &&
            [value isKindOfClass:[NSString class]] &&
            ![value isEqualToString:@""]) {
            
            [protocol setObject:[NSArray arrayWithObject:value] forKey:@"v"];
        }
        
        if ([component isEqualToString:@"touchpad"] &&
            [value isKindOfClass:[NSDictionary class]]) {
            
            [protocol setObject:value forKey:@"v"];
        }
    }
    [protocol setObject:event forKey:@"e"];

    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:protocol completion:nil];
   
}
@end
