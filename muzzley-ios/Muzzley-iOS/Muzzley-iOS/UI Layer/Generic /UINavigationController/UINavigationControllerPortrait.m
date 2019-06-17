//
//  UINavigationControllerPortrait.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UINavigationControllerPortrait.h"

#import "UINavigationBar+Addition.h"

#import "Muzzley_iOS-Swift.h"
@interface UINavigationControllerPortrait ()

@end

@implementation UINavigationControllerPortrait

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    //return [self.visibleViewController shouldAutorotate];
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //return [self.visibleViewController  supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    if (self.navigationBarTransparentBackground) {
        
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsCompact];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.translucent = YES;
    } else {
		
        self.navigationBar.barTintColor = [MZThemeManager sharedInstance].colors.primaryColor;
        self.navigationBar.translucent = NO;
        [self.navigationBar showBottomHairline];
    }
    
    // Set NavigationBar Title color
    [self.navigationBar setTitleTextAttributes:@{
      NSFontAttributeName : [UIFont regularFontOfSize:20.0],
      NSForegroundColorAttributeName : [MZThemeManager sharedInstance].colors.primaryColorText
    }];
    
    // Set back button arrow color
	self.navigationBar.tintColor =  [MZThemeManager sharedInstance].colors.primaryColorText;
	
    // Set back button color
    NSDictionary *attributesStateNormal =
    @{
      NSFontAttributeName : [UIFont lightFontOfSize:18.0],
	  NSForegroundColorAttributeName : [MZThemeManager sharedInstance].colors.primaryColorText
    };
    
    
    NSDictionary *attributesStateHighlighted =
    @{
      NSFontAttributeName : [UIFont lightFontOfSize:18.0],
      NSForegroundColorAttributeName : [[MZThemeManager sharedInstance].colors.primaryColorText colorWithAlphaComponent: 0.3]
    };
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationControllerPortrait class], nil] setTitleTextAttributes:attributesStateNormal forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationControllerPortrait class], nil]setTitleTextAttributes:attributesStateHighlighted forState:UIControlStateHighlighted];
}

@end
