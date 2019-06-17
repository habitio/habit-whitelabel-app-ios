//
//  MZDeviceVolumeViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZDeviceVolumeViewController.h"

@interface MZDeviceVolumeViewController ()

@end

@implementation MZDeviceVolumeViewController

#pragma mark -
#pragma mark Initializers
-(id)init
{
    UIStoryboard *muzzleyKitStoryboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    } else {
        /// IPAD VERSION
    }
    MZDeviceVolumeViewController *deviceVolumeViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZDeviceVolumeViewController"];
    self = deviceVolumeViewController;
    
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.alpha = 0;
}
#pragma mark -
#pragma mark View Rotation
/// iOS5 View Rotation Compatibility
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else {
        return YES;
    }*/
    return YES;
}
/// iOS6
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark Volume Animations

- (void)startVolumeUpAnimation{
    
    self.view.alpha = 1;
    self.volumeBackgroundView.alpha = 1;
    self.volumeDownView.alpha = 0;
    self.volumeUpView.alpha = 1;
    
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.volumeUpView.transform = CGAffineTransformMakeScale(1.25, 1.25);

                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              
                                              self.volumeUpView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              
                                          } completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.5
                                                                    delay:0.65
                                                                  options:0
                                                               animations:^{
                                                                   
                                                                   self.view.alpha = 0;
                                                                   
                                                               } completion:^(BOOL finished) {
                                                                   
                                                               }];
                                          }];
                     }];
}

- (void)startVolumeDownAnimation{
    
    self.view.alpha = 1;
    self.volumeBackgroundView.alpha = 1;
    self.volumeDownView.alpha = 1;
    self.volumeUpView.alpha = 0;
    
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.volumeDownView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                       
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              
                                              self.volumeDownView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                            
                                          } completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.5
                                                                    delay:0.65
                                                                  options:0
                                                               animations:^{
                                                                
                                                                    self.view.alpha = 0;
                                                                   
                                                               } completion:^(BOOL finished) {
                                                                   
                                                               }];
                                          }];
                     }];
}
@end
