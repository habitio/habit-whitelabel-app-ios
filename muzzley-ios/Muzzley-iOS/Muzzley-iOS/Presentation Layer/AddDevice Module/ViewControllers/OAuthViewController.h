//
//  OAuthViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/05/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

@class OAuthViewController;
@protocol OAuthViewControllerDelegate <NSObject>

- (void)OAuthViewControllerDidAuthenticate:(OAuthViewController *)oAuthViewController;
- (void)OAuthViewControllerDidFailAuthentication:(OAuthViewController *)oAuthViewController;
- (void)OAuthViewControllerDidCancelAuthentication:(OAuthViewController *)oAuthViewController;

@end

@interface OAuthViewController : BaseViewController

@property (nonatomic, weak) id <OAuthViewControllerDelegate> delegate;
@property (nonatomic, strong) NSURL *urlHost;
@property (nonatomic, strong) NSURL *shopUrl;
@property (nonatomic, strong) NSDictionary * customHeaders;

@end
