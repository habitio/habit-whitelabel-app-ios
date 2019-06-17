//
//  MZViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/04/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
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


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)reloadData
{

}

- (void)refreshData
{

}
@end
