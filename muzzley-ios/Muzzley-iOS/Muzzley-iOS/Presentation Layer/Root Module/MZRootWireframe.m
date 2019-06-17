
//
//  MZRootWireframe.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 29/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZRootWireframe.h"

#import "MZAppDelegate.h"

#import "MZModuleFactory.h"

#import "JLRoutes.h"
#import "NavigationRouteCommand.h"

#import "UINavigationControllerPortrait.h"

#import "DeviceTilesViewController.h"

#import "UserProfileWireframe.h"
#import "UserAuthViewController.h"
#import "UserAuthWireframe.h"
#import "UserAuthInteractor.h"

#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define INVALID_VERSION @"invalidVersion"

typedef NS_ENUM(NSUInteger, NavigationStackState) {
    NavigationStackStateIdle = 0,
    NavigationStackStatePoping,
    NavigationStackStatePushing,
    NavigationStackStatePresenting
};


@interface MZRootWireframe ()
<UINavigationControllerDelegate,
UserAuthDelegate,
DeviceTilesViewControllerDelegate,
MZTilesViewControllerDelegate,
MZUserProfileDelegate,
//MZFlowControllerChannelAddDelegate,
PopupContentViewDelegate,
MZAddTilesViewControllerDelegate>
{
	KLCPopup * _popupView;
}
@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic, assign) NavigationStackState navigationStackState;

@property (nonatomic, readwrite) UIWindow *window;
@property (nonatomic, readwrite) UIViewController *mainViewController;

@property (nonatomic, readwrite) MZCardsTabViewController *cardsTabViewController;
@property (nonatomic, readwrite) MZWorkersViewController *workersViewController;
@property (nonatomic, readwrite) MZTilesViewController *tilesViewController;

//@property (nonatomic, readwrite) DeviceTilesViewController *deviceTilesViewController;
@property (nonatomic, readwrite) MZUserProfileViewController *userProfileViewController;

@end

@implementation MZRootWireframe

- (void)dealloc
{
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_ROOT];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_TIMELINE];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_WORKERS];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_CHANNELS];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_NOTIFICATIONS];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_USER_PROFILE];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_INTERFACES_SELECT];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_WIDGET_SELECT];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_PROFILES];
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_USER_AUTH];
}

- (instancetype)init {
    if (self = [super init]) {
        __typeof__(self) __weak weakSelf = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanUpAndGoToStart) name:@"cleanUpAndGoToStart" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessfulLogin) name:@"UserAuthModuleDidAuthenticateNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCardsScreenAnimated:) name:@"appOpenedViaNotification" object:nil];

		
        // Routes
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_ROOT handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf popToRootViewControllerAnimated:YES]; }
            return YES;
        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_TIMELINE handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf showCardsScreenAnimated:YES]; }
            return YES;
        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_WORKERS handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf showWorkersScreenAnimated:YES]; }
            return YES;
        }];

        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_CHANNELS handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf showDevicesScreenAnimated:YES]; }
            return YES;
        }];
        
//        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_NOTIFICATIONS handler:^BOOL(NSDictionary *parameters) {
//            if (weakSelf) { [weakSelf showNotificationsScreenAnimated:YES]; }
//            return YES;
//        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_USER_PROFILE handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf showUserProfileScreenAnimated:YES]; }
            return YES;
        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_INTERFACES_SELECT handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) {
                
                NSString *baseURL = [MZEndpoints apiHost];
                NSString *interfaceId = [parameters objectForKey:@"id"];
                NSString *queryParameters = [parameters objectForKey:@"query"];
                NSString *urlString = [NSString stringWithFormat:@"%@/interfaces/%@",baseURL, interfaceId];
                if ([queryParameters isKindOfClass:[NSString class]]) {
                    urlString = [NSString stringWithFormat:@"%@?%@", urlString, queryParameters];
                }
                NSURL *url = [NSURL URLWithString:urlString];
                [weakSelf showThingInteractionScreenWithControlInterfaceURL:url categoryMode:NO animated:YES];
            }
            return YES;
        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_WIDGET_SELECT handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) {
                NSString *activityId = [parameters objectForKey:@"activityId"];
                NSString *userAuthToken = [[[MZSession sharedInstance] authInfo] accessToken];
                NSString *userId = [[[MZSession sharedInstance] authInfo] userId];
                
                [self showMuzzleyInteractionScreenWithActivityId:activityId
                                                          userId:userId
                                                       userToken:userAuthToken
                                                        animated:YES];
            }
            return YES;
        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_PROFILES handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf showChannelProfilesScreenAnimated:YES]; }
            return YES;
        }];
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_USER_AUTH handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) { [weakSelf showUserAuthenticationScreenAnimated:YES]; }
            return YES;
        }];
        
        self.rootInteractor = [MZRootInteractor new];
    }
    return self;
}



- (void)handleNavigationRoute:(NavigationRouteCommand *)route {
    if ([route isKindOfClass:[NavigationRouteCommand class]]) {
        [JLRoutes routeURL:route.url];
    }
}

- (void)cleanUpAndGoToStart
{
	[MZLocalStorageHelper removeLocationChannelIdFromNSUserDefaults];
	[self.rootViewController.interactor deactivateRemoteNotificationsService];
	[self.rootViewController.interactor stopLocation];
	
	[self showRootViewControllerWithParameters:nil];

}

- (void)handleSuccessfulLogin
{
	[self showRootViewControllerWithParameters:nil];
}

#pragma mark - Public Methods
- (void)showRootViewControllerWithParameters:(NSDictionary *)parameters {
    
   
    __typeof__(self) __weak weakSelf = self;
    if (!self.window)
	{
		self.window = [UIWindow new];
	}
	
//    if ([parameters[KEY_FORCE_LOGOUT] boolValue])
//    {
//        [weakSelf showUserAuthenticationScreenAnimated:NO];
//        [weakSelf setWindowFor:weakSelf];
//    }
//	else
//	{
//        [[MZSession sharedInstance] loadFromCacheWithCompletion:^(BOOL cachedSessionFound) {
		
		
		if([[MZSession sharedInstance] authInfo] != nil)
		{
			if ( ![[[MZSession sharedInstance] authInfo].userId isEqualToString:@""])
					 {

                         [weakSelf showMainScreenWithParameters:parameters];
				
			}
		}
		else
		{
                [weakSelf showUserAuthenticationScreenAnimated:NO];
		}
		[weakSelf setWindowFor:weakSelf];
//        }];
//    }
}




- (void) setWindowFor:(MZRootWireframe*)rootWF
{
    rootWF.window.rootViewController = rootWF.mainViewController;
    rootWF.window.frame = [[UIScreen mainScreen] bounds];
    [rootWF.window makeKeyAndVisible];
    MZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.window = rootWF.window;
}



- (void)showMainScreenWithParameters:(NSDictionary *)parameters {
    
    self.navigationController = [UINavigationControllerPortrait new];
    self.navigationController.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.rootInteractor.remoteNotification = parameters;
    MZRootViewController *rootViewController = [[MZRootViewController alloc] initWithRootInteractor:self.rootInteractor wireframe:self];
    [self.navigationController pushViewController:rootViewController animated:NO];
	
    if ([MZThemeManager sharedInstance].features.cards == YES)
    {
        MZCardsTabViewController * cardsTabViewController = [MZModuleFactory cardsViewControllerWithRootWireframe:self];
        //cardsViewController.delegate = self;
        self.cardsTabViewController = cardsTabViewController;
        self.cardsTabViewController.cardsDelegate = rootViewController.self;
    }
	
    MZWorkersViewController *workersViewController = [MZModuleFactory workersViewControllerWithRootWireframe:self];
	//workersViewController.delegate = self
	self.workersViewController = workersViewController;
	
	MZTilesViewController * tilesViewController = [MZModuleFactory tilesViewControllerWithRootWireframe: self];
	tilesViewController.delegate = self;
	self.tilesViewController = tilesViewController;

    MZUserProfileViewController *userProfileViewController = [MZModuleFactory userProfileViewControllerWithRootWireframe:self];
    userProfileViewController.delegate = self;
    self.userProfileViewController = userProfileViewController;
    
    // Attach to rootViewController
    self.rootViewController = rootViewController;
    self.mainViewController = self.navigationController;
}


- (void)showRemoteNotificationScreenIfNeeded {
    MZRootInteractor *interactor = self.rootViewController.interactor;
    NSDictionary *remoteNotification = interactor.remoteNotification;
	
	
    if ([remoteNotification isKindOfClass:[NSDictionary class]]) {
        
        NSString *eventId = [remoteNotification objectForKey:@"eventId"];
        if (![eventId isKindOfClass:[NSString class]]) return;
        
        NSString *urlString = [NSString stringWithFormat:@"muzcommand://navigate/events/%@",eventId];
        NSURL *urlCommand = [NSURL URLWithString:urlString];
        
        NavigationRouteCommand *route = [[NavigationRouteCommand alloc] initWithUrl:urlCommand];
        [self handleNavigationRoute:route];
        interactor.remoteNotification = nil;
    }
}

- (void)showCardsScreenAnimated:(BOOL)animated {
    if(self.rootViewController != nil && self.rootViewController.tabsOrder != nil)
    {
        NSArray * array = [self.rootViewController tabsOrder];
        DLOG(@"%@", array)
        if([array containsObject: @(0)])
        {
            [self popToRootViewControllerAnimated:animated];
            [self.rootViewController slideToItem: [self.rootViewController timelineTabBarItem] animated:YES];
            //    [self scrollToItemIndex:0 animated:animated];
        }
    }
}

- (void)showWorkersScreenAnimated:(BOOL)animated {
    [self popToRootViewControllerAnimated:animated];
    [self.rootViewController slideToItem: [self.rootViewController workersTabBarItem] animated:YES];

//    [self scrollToItemIndex:1 animated:animated];
}


- (void)showDevicesScreenAnimated:(BOOL)animated {
    [self popToRootViewControllerAnimated:animated];
    [self.rootViewController slideToItem: [self.rootViewController tilesTabBarItem] animated:YES];

//    [self scrollToItemIndex:2 animated:animated];
}

//
//- (void)showNotificationsScreenAnimated:(BOOL)animated {
//    [self popToRootViewControllerAnimated:animated];
//    [self scrollToItemIndex:3 animated:animated];
//}

- (void)showUserProfileScreenAnimated:(BOOL)animated {
    [self popToRootViewControllerAnimated:animated];
    [self.rootViewController slideToItem: [self.rootViewController userProfileTabBarItem] animated:YES];

//    [self scrollToItemIndex:4 animated:animated];
}


- (void)showUserAuthenticationScreenAnimated:(BOOL)animated
{
    UserAuthInteractor *interactor = [[UserAuthInteractor alloc] init];
    UserAuthWireframe *wireframe = [[UserAuthWireframe alloc] init];
    UserAuthViewController *viewController = [[UserAuthViewController alloc] initWithWireframe:wireframe interactor:interactor];
    viewController.delegate = self;
    [wireframe setRootViewController:viewController];
    self.mainViewController = wireframe.navigationController;
}
 
- (void)showAddDevicesScreenAnimated:(NSString *) tileType animated:(BOOL)animated
{
	MZAddTilesViewController * vc = [[MZAddTilesViewController alloc] initWithNibName:@"MZAddTilesViewController" bundle:nil];
    vc.delegate = self;
	vc.initialSelectedTileType = tileType;
	[self pushViewControllerToEnd:vc animated:animated];
}


#pragma mark - Private Methods
- (void)_handleSubscribedChannelSelection:(MZChannel *)channel
{
    /*
     When a user taps a channel, it will only navigate to the thing interaction screen if the channel has a valid control interface
     */
    if ([channel.interface isKindOfClass:[MZControlInterface class]]) {
        [self showThingInteractionScreenWithControlInterfaceURL:channel.interface.url
                                                   categoryMode:NO
                                                       animated:YES];
        return;
    }
}

- (void)_cleanPreviousModalViewController:(UIViewController *)viewController
{
    if (!viewController) return;
}

- (void)_cleanAddChannelFlowControllerModule
{
}

#pragma mark

- (void) startAddTile: (NSString *) tileType
{
	[self showAddTilesScreen: tileType];
}


- (void) showAddTilesScreen: (NSString *) tileType
{
	if(![[MZOnboardingsInteractor sharedInstance] hasOnboardingBeenShown: [[MZOnboardingsInteractor sharedInstance] key_devices]])
	{
		[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_devices] shownStatus: YES];
	}
	
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [reachability currentReachabilityStatus];
	if (internetStatus == NotReachable)
	{
		[self.rootViewController presentNetworkUnavailableAlert];
		return;
	}
	
	// No root screen is being shown
	[self.rootViewController tabDisplayedEvent:-1];
	[self showAddDevicesScreenAnimated: tileType animated:YES];
}

// Shows the add device page
- (void)deviceTilesViewControllerDidSelectAddDevice:(DeviceTilesViewController *)viewController
{
	[self showAddTilesScreen: @"device"];
	
//	if(![[MZOnboardingsInteractor sharedInstance] hasOnboardingBeenShown: [[MZOnboardingsInteractor sharedInstance] key_devices]])
//	{
//		[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_devices] shownStatus: YES];
//	}
//	
//	Reachability *reachability = [Reachability reachabilityForInternetConnection];
//	NetworkStatus internetStatus = [reachability currentReachabilityStatus];
//	if (internetStatus == NotReachable)
//	{
//        [self.rootViewController presentNetworkUnavailableAlert];
//        return;
//    }
//	
//	// No root screen is being shown
//	[self.rootViewController tabDisplayedEvent:-1];
//	[self showAddDevicesScreenAnimated:YES];
}


#pragma mark MZFlowControllerChannelAddDelegate
- (void)addChannelFlowControllerDidCancelFlow
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)addChannelFlowControllerDidAddChannel
{
    
    [self popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceAddedNotification" object:nil];
}

- (void)addChannelFlowControllerDidAbortWithAuthenticationRequired
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark UserAuthDelegate
- (void)userAuthViewControllerDidAuthenticate:(UserAuthViewController *)viewController
{
    [self showRootViewControllerWithParameters:nil];
}

#pragma mark UserProfileDelegate
- (void)userProfileDidLogOut:(MZUserProfileViewController *)userProfileViewController
{
	[[MZMQTTConnection sharedInstance] disconnect];
	// TODO: Disconnect from MQTT
    //[self.rootViewController.interactor disconnectMuzzleyClient];
    [self.rootViewController.interactor deactivateRemoteNotificationsService];
    [self.rootViewController.interactor stopLocation];
	
    [self showRootViewControllerWithParameters:nil];
}

#pragma mark - Navigation Methods
- (void)scrollToItemIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.rootViewController scrollToItemIndex:index animated:animated];
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    
    UIViewController *presentedViewController = self.navigationController.presentedViewController;
    if (presentedViewController) {
        __typeof__(self) __weak welf = self;
        [self _cleanPreviousModalViewController:presentedViewController];
        
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            
            [welf.navigationController presentViewController:viewController animated:animated completion:^{
                if (completion) completion();
            }];
        }];
    } else {
        
        [self.navigationController presentViewController:viewController animated:animated completion:^{
            if (completion) completion();
        }];
    }
}

- (void)presentViewControllerWithoutClean:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    self.navigationController.definesPresentationContext = true;
    [self.navigationController presentViewController:viewController animated:animated completion:^{
        if (completion) completion();
    }];
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    UIViewController *presentedViewController = self.navigationController.presentedViewController;
    
    [self _cleanPreviousModalViewController:presentedViewController];
    [self.navigationController dismissViewControllerAnimated:animated completion:^{
        if (completion) completion();
    }];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController.topViewController == self.mainViewController) {
        self.navigationStackState = NavigationStackStateIdle;
        return;
    }
    
    //if (self.navigationStackState == NavigationStackStateIdle) {
        //self.navigationStackState = NavigationStackStatePoping;
        [self.navigationController.navigationBar setHidden:NO];
        NSArray *viewControllers = @[self.rootViewController];
        [self.navigationController setViewControllers:viewControllers animated:animated];
    //}
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController.topViewController == self.mainViewController) {
        self.navigationStackState = NavigationStackStateIdle;
        return;
    }
    
    //if (self.navigationStackState == NavigationStackStateIdle) {
    //    self.navigationStackState = NavigationStackStatePoping;
        [self.navigationController popViewControllerAnimated:animated];
    //}
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.navigationStackState == NavigationStackStateIdle) {
        self.navigationStackState = NavigationStackStatePushing;
        NSArray *viewControllers = @[self.rootViewController, viewController];
        [self.navigationController setViewControllers:viewControllers animated:animated];
    }
}

- (void)pushViewControllerToEnd:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.navigationStackState == NavigationStackStateIdle) {
        self.navigationStackState = NavigationStackStatePushing;
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [viewControllers addObject:viewController];
        [self.navigationController setViewControllers:viewControllers.copy animated:animated];
    }
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.navigationStackState = NavigationStackStatePoping;
    if ([viewController isKindOfClass:[MZRootViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.navigationStackState = NavigationStackStateIdle;
}
@end
