//
//  MZRootWireframe.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 29/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "Wireframe.h"
//#import "RootInteractor.h"

//#import "MZCardsViewController.h"
@class MZRootViewController;

@class MZCardsTabViewController;
@class MZWorkersViewController;
@class TilesViewController;
@class MZUserProfileViewController;
@class MZRootInteractor;

@interface MZRootWireframe : Wireframe

@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) UIViewController *mainViewController;
@property (nonatomic) MZRootInteractor *rootInteractor;
@property (nonatomic, readonly) MZCardsTabViewController *cardsTabViewController;
@property (nonatomic, readonly) MZWorkersViewController *workersViewController;
@property (nonatomic, readonly) MZTilesViewController * tilesViewController;

@property (nonatomic, readonly) MZUserProfileViewController *userProfileViewController;
@property (nonatomic, weak) MZRootViewController *rootViewController;

- (void)showRootViewControllerWithParameters:(NSDictionary *)parameters;

- (void)scrollToItemIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)showMainScreenWithParameters:(NSDictionary *)parameters;
- (void)showRemoteNotificationScreenIfNeeded;
- (void)showCardsScreenAnimated:(BOOL)animated;
- (void)showWorkersScreenAnimated:(BOOL)animated;
- (void)showDevicesScreenAnimated:(BOOL)animated;
- (void)showUserProfileScreenAnimated:(BOOL)animated;
- (void)showUserAuthenticationScreenAnimated:(BOOL)animated;
- (void)showChannelProfilesScreenAnimated:(BOOL)animated;
- (void)showMuzzleyInteractionScreenWithActivityId:(NSString *)activityId
                                            userId:(NSString *)userId
                                         userToken:(NSString *)userToken
                                          animated:(BOOL)animated;
//- (id<MZBaseClient>)getMuzzleyClient;
- (void)showThingInteractionScreenWithControlInterfaceURL:(NSURL *)url
                                             categoryMode:(BOOL)categoryMode
                                                 animated:(BOOL)animated;
@end
