//
//  MZWidgetNotSupported.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 16/04/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZWidgetNotSupported.h"

#import "MZUserClient.h"

@interface MZWidgetNotSupported ()

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation MZWidgetNotSupported

#pragma mark - Dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
    
}

#pragma mark - Initializers
- (id)initWithParameters:(NSDictionary*)parameters
{
    if (self = [super initWithNibName:@"MZWidgetNotSupported" bundle:[NSBundle mainBundle]]) {
        self.parameters = parameters;
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

#pragma mark View Lyfecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Quit Activity flow
#pragma mark - alertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)]) {
            [self.delegate widgetNeedsToDismiss:self];
        }
    }
}

@end
