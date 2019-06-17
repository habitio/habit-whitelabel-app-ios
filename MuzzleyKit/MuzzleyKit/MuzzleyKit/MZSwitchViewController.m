//
//  MZSwitchViewController.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 11/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZSwitchViewController.h"

#import "MZUserClient.h"

@interface MZSwitchViewController ()

@property (nonatomic, strong, readwrite) IBOutlet UIButton *buttonSwitch;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *imageSwitchBox;

@property (nonatomic, assign) BOOL isOn;

/// private signaling mzmessage for communication with activity
@property (nonatomic, strong) MZMessage *messageSignaling;

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation MZSwitchViewController

@synthesize buttonSwitch;
@synthesize imageSwitchBox;

- (void)dealloc
{    
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
}


#pragma mark - Initializers
-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZSwitchViewController *switchViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZSwitchViewController"];
    self = switchViewController;
    
    if (self) {
        self.parameters = parameters;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isOn = false;
    
    if ([self.parameters valueForKey:@"isOn"]) {
        self.isOn = [[self.parameters valueForKey:@"isOn"] boolValue];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateState];
}

#pragma mark - View Rotation
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
#pragma mark - Login in muzzley flow
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)])
            [self.delegate widgetNeedsToDismiss:self];
    }
}

- (IBAction)switchPressedDown:(UIButton*)sender
{
    if ([sender isEqual:self.buttonSwitch]) {
        
        sender.highlighted = NO;
    }
}

- (IBAction)switchPressedUpInside:(id)sender
{
    if ([sender isEqual:self.buttonSwitch]) {
        
        self.isOn = !self.isOn;
        [self updateState];
       
        [self _didSwitchState:self.isOn];    
    }
}

-(void)updateState
{
    self.buttonSwitch.highlighted = NO;
    
    if (self.isOn) {
        self.buttonSwitch.selected = true;
        self.imageSwitchBox.highlighted = true;
        
    } else {
        self.buttonSwitch.selected = false;
        self.imageSwitchBox.highlighted = false;
    }
}

//////////////////////////////////////////////////////////////////////////
/// Switch Widget Communication Methods
//////////////////////////////////////////////////////////////////////////

- (void)_didSwitchState:(BOOL)isOn
{
    NSString *widget = @"switch";
    NSString *component = @"switch";
    NSNumber *value = [NSNumber numberWithInteger:0];
    
    if (isOn) {
        value = [NSNumber numberWithInteger:1];
    } else {
        value = [NSNumber numberWithInteger:0];
    }
    
    NSString *event = @"press";
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:nil];
}

@end
