    //
//  MZAppManager.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 21/08/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "AppManager.h"
#import "AppConstants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
//#import <GoogleSignIn/GoogleSignIn.h>
//#import <Google/Core.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "XQueryComponents.h"
#import "MZAppFeaturesInfo.h"
#import "FileSystemCleaner.h"
#import "MZRootWireframe.h"
#import "UINavigationControllerPortrait.h"
#import <NeuraSDK/NeuraSDK.h>


//@class MZEmitLocationInteractor;
// App Manager Notification Keys
// -------------------------------------------------------------------------------------------
NSString *const AppManagerDidReceiveRemoteNotification = @"AppManagerDidReceiveRemoteNotification";
NSString *const AppManagerDidSelectRemoteNotification = @"AppManagerDidSelectRemoteNotification";
NSString *const AppManagerDidChangeStateNotification = @"AppManagerDidChangeStateNotification";
NSString *const AppManagerDidReceiveJoinActivityNotification = @"AppManagerDidReceiveJoinActivityNotification";

@interface AppManager () <PopupContentViewDelegate>
{
//    MZClientVersionWebService * _clientVersionWS;
    KLCPopup * _popupView;
}

@property (nonatomic, copy) NSArray *remoteNotificationTags;
@property (nonatomic) NSData *deviceToken;
@property (nonatomic) SBNotificationHub *azureNotificationHub;

@property (nonatomic) AppBehaviourType appBehaviourType;

@property (nonatomic) MZRootWireframe *rootWireframe;

@property (nonatomic) UIAlertView *alertView;

//@property (nonatomic) IJKMediaPlayback * backgroundAudioPlayer;

@end

@implementation AppManager

#pragma mark - Dealloc
-(void)dealloc
{
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
    self.alertView = nil;
}


#pragma mark - Singleton
+ (AppManager *)sharedManager
{
    static AppManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [AppManager new];
    });
    
    return sharedInstance;
}


#pragma mark - Initializer
- (id)init {
    self = [super init];
    if (!self) return nil;
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];

    MUZZLEY_PHILIPSHUE_PROFILEID = [infoDict objectForKey:@"MUZZLEY_PHILIPSHUE_PROFILEID"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:UIStatusBarAnimationFade];
	
    // NSURLCache
    /*NSURLCache *appURLCache = [[NSURLCache alloc] initWithMemoryCapacity:(2 * 1024 * 1024) diskCapacity:100 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:appURLCache];
    */
    [MZAnalyticsInteractor configure];
    
    DLog(@"name: %@", [[UIDevice currentDevice] name]);
    NSString * version = [NSString stringWithFormat:@"%@ %@",[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
    DLog(@"app version: %@",version);
    NSString * commit_hash = [[NSBundle mainBundle] infoDictionary][@"GIT_COMMIT_HASH"];
    DLog(@"commit_hash: %@",commit_hash);

    [Fabric with:@[[Crashlytics class]]];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    self.appStartMode = AppStartModeActive;
	
    // Shared DateFormatter configuration
    [[NSDate sharedDateFormatter] setAMSymbol:@"am"];
    [[NSDate sharedDateFormatter] setPMSymbol:@"pm"];
    [[NSDate sharedDateFormatter] setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    


    // Configuration for Remote Push Notification Service

    self.azureNotificationHub = [[SBNotificationHub alloc] initWithConnectionString:[MZThemeManager sharedInstance].azureNotifications.endpoint notificationHubPath:[MZThemeManager sharedInstance].azureNotifications.hubname];
    self.remoteNotificationTags = [NSArray new];
    self.deviceToken = [NSData new];
    
    // Clean File System Cache temporary files
    FileSystemCleaner *cleaner = [FileSystemCleaner new];
    [cleaner cleanTemporaryFiles];
    
//    _clientVersionWS = [[MZClientVersionWebService alloc] init];
	
    return self;
}


- (BOOL)application:(UIApplication *)application handleDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MZLoggingInteractor new];
    DDLogDebug(@"--------------------------------------------\nApp initialized");
    
    //NSError* configureError;
   // [[GGLContext sharedInstance] configureWithError: &configureError];
    //NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
            
   // [[GIDSignIn sharedInstance] signInSilently];
    
    if([MZThemeManager sharedInstance].neura != nil)
    {
        [NeuraSDK.shared setAppUID:[MZThemeManager sharedInstance].neura.appUID appSecret:[MZThemeManager sharedInstance].neura.appSecret];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}




- (void)_presentAlertInterfaceWithTitle:(NSString *)title message:(NSString *)message {
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"") otherButtonTitles:nil, nil];
    [self.alertView show];
}


- (void)handleApplicationDidBecomeActiveWithParameters:(NSDictionary *)parameters
{
    [FBSDKAppEvents activateApp];
    [MZAnalyticsInteractor startAppEvent];
    [self _setRootWireframeIfNeededWithParameters:parameters];
    [self _fowardDidBecomeActiveToFacebookSession];
    [self _clearNotificationsFromNotificationCenter];
}


- (void)handleApplicationWillResignActive
{
}


- (void)handleApplicationDidEnterBackground:(UIApplication *)application {
    [MZAnalyticsInteractor exitAppEvent];
}


- (void)handleApplicationWillTerminate:(UIApplication *)application {
    [MZAnalyticsInteractor exitAppEvent];
}


- (void)handleApplicationWillEnterForeground:(UIApplication *)application {
}


- (void)handleLaunchByLocationChanges
{
    [[MZEmitLocationInteractor sharedInstance] startMonitoringLocation];
    [MZActivityInteractor shared].queryForRecentActivityData;
}


- (void)_setRootWireframeIfNeededWithParameters:(NSDictionary *)parameters
{
    bool shouldShowRoot = NO;
	
    if (!self.rootWireframe) {
        self.rootWireframe = [MZRootWireframe new];
        shouldShowRoot = YES;
    }
 

//	[self validateClientVersion:^(BOOL validVersion, NSError* error) {
//		
//		//Temporary while has issues
//		// validVersion = YES;
//		
//		NSMutableDictionary* newParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
//		newParams[KEY_FORCE_LOGOUT] = [NSNumber numberWithBool:(!validVersion && error == nil)];
//		
//		if (shouldShowRoot) {
//			[self.rootWireframe showRootViewControllerWithParameters:newParams];
//		}
//		
//		if ([newParams[KEY_FORCE_LOGOUT] boolValue]) {
//			[self presentForceUpdateAlert];
//		}
//	}];
	
	[[MZSession sharedInstance] loadFromCacheWithCompletion:^(BOOL success)
	{	
		if(success)
		{
			if([MZLocalStorageHelper loadLocationPermissionsStatusFromNSUserDefaults] != [MZDeviceInfoHelper areLocationServicesEnabled] ||
			   [MZLocalStorageHelper loadPushNotificationsStatusFromNSUserDefaults] != [MZDeviceInfoHelper areNotificationsEnabled])
			{
				[MZLocalStorageHelper saveLocationPermissionsStatusToNSUserDefaults: [MZDeviceInfoHelper areLocationServicesEnabled]];
				[MZLocalStorageHelper savePushNotificationsStatusToNSUserDefaults: [MZDeviceInfoHelper areNotificationsEnabled]];

				[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAllTabs" object:nil];
			}

            Reachability *internetReachable = [Reachability reachabilityForInternetConnection];

            if([internetReachable currentReachabilityStatus] != NotReachable)
            {
                [[MZSessionDataManager sharedInstance] getSessionInfo:^(BOOL success)
                 {
                     if(!success)
                     {
                         NSString * message =  NSLocalizedString(@"mobile_error_text", @"");
                         
                         UIAlertView *alertView;
                         alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_signin_error", @"") message: message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_retry", @"") otherButtonTitles:nil, nil];
                         
                         alertView.delegate = self;
                         [alertView show];
                         
                         [[MZSession sharedInstance] signOut];
                         [self.rootWireframe showRootViewControllerWithParameters:nil];
                     }
                     else
                     {
                         if (shouldShowRoot)
                         {
                             [self.rootWireframe showRootViewControllerWithParameters:nil];
                             
                         }
                         
                         if ([self.loadFromCacheDelegate respondsToSelector:@selector(loadedUserCache)])
                         {
                             [self.loadFromCacheDelegate loadedUserCache];
                         }
                     }
                 }];
            }
            else
            {
                if (shouldShowRoot)
                {
                    [self.rootWireframe showRootViewControllerWithParameters:nil];
                }
                
                if ([self.loadFromCacheDelegate respondsToSelector:@selector(loadedUserCache)]) {
                    [self.loadFromCacheDelegate loadedUserCache];
                }
            }
        }
		else
		{
			[[MZSession sharedInstance] signOut];
			[self.rootWireframe showRootViewControllerWithParameters:nil];
		}
	}];
	

}


- (void)validateClientVersion:(void (^)(BOOL, NSError *))completion
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"goodUntil"] != nil)
    {
        NSString * goodUntil = [[NSUserDefaults standardUserDefaults] stringForKey:@"goodUntil"];
        NSDate * goodUntilDate = [NSDate dateFromString:goodUntil withFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"];
        
        if (completion && goodUntilDate && [goodUntilDate compare:[NSDate new]] == NSOrderedDescending)
        {
            completion(YES, nil);
            completion = nil;
        }
    }
    
    NSDictionary * params = @{MZClientVersionWebService.key_version:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]};
    
    //TODO only call this if missing 2 days to end
	[[MZClientVersionWebService sharedInstance] getVersionSupport:params completion:^(id result, NSError * error) {
        if (error == nil)
        {
            if ([result isKindOfClass:[NSDictionary class]] && result[@"goodUntil"] != nil)
            {
                NSDate * goodUntilDate = [NSDate dateFromString:result[@"goodUntil"] withFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"];
                [[NSUserDefaults standardUserDefaults] setObject:result[@"goodUntil"] forKey:@"goodUntil"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (completion && goodUntilDate) { completion([goodUntilDate compare:[NSDate new]] == NSOrderedDescending, error); return; }
            }
        }
        
        if (completion) {
            completion(YES, error);
        }
    }];
}


- (void)presentForceUpdateAlert
{
    if (!_popupView)
    {
        PopupContentView* popupContentView = [PopupContentView loadFromNib];
        popupContentView.delegate = self;
        popupContentView.message = NSLocalizedString(@"mobile_update_app_warning", comment: @"");
        popupContentView.image = [UIImage appIcon];
        popupContentView.topColor = [UIColor muzzleyGray2ColorWithAlpha:1.0];
        popupContentView.textColor = [UIColor muzzleyWhiteColorWithAlpha:1.0];
        popupContentView.hasImage = YES;
        popupContentView.btnStrings = @[NSLocalizedString(@"mobile_update", comment: @"")];
        popupContentView.identifier = 1000;
        _popupView = [KLCPopup popupWithContentView:popupContentView
                                           showType:KLCPopupShowTypeSlideInFromTop
                                        dismissType:KLCPopupDismissTypeNone
                                           maskType:KLCPopupMaskTypeDimmed
                           dismissOnBackgroundTouch:NO
                              dismissOnContentTouch:NO];
        [_popupView show];
        [MZAnalyticsInteractor forceUpdateShowEvent];
    }
}


#pragma PopupContentViewDelegate

- (void)didTapOnPopupButtonAtIndex:(PopupContentView *)sender btnIndex:(NSInteger)btnIndex
{
    if (sender.identifier == 1000)
    {
        [MZAnalyticsInteractor forceUpdateRedirectStoreEvent];
        //TODO mudar para link com id
        NSString *iTunesLink = @"itms-apps://itunes.com/apps/muzzley";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        _popupView = nil;
    } else {
        [self _setRootWireframeIfNeededWithParameters:nil];
        _popupView = nil;
    }
}


- (void)_fowardDidBecomeActiveToFacebookSession {
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    /*if (FBSession.activeSession.state == FBSessionStateCreatedOpening ) {
        [FBSession.activeSession close];
        [[MZSession activeSession] closeAndClear];
    }
    [FBSession.activeSession handleDidBecomeActive];*/
}

#pragma mark - Handlers
// Handle taps on Custom URL Scheme for this unique app.
//
// Custom URL = muzzley://<action>?<params>
//
// Scheme: 'muzzley', it is registered in the Muzzley-iOS-Info.plist file.
// <action>:['play']
// <params>:[activityId=abc123]
//

- (BOOL)application:(UIApplication *)application handleOpenUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation launchedApp:(BOOL)launchedApp enterMode:(AppEnterType)enterMode
{
    if (enterMode == AppEnterModeFirstLaunchFromURLSchema) {
        //TODO review routes
        [[NSNotificationCenter defaultCenter] postNotificationName:AppManagerDidReceiveMuzzleyURLSchema object:url];
        return YES;
    } else if (enterMode == AppEnterModeBackgroundFromFacebook) {
        
        BOOL success = NO;
    
        [self _setRootWireframeIfNeededWithParameters:nil];
    
        success = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        [self _fowardDidBecomeActiveToFacebookSession];
        
        return success;
        
    } else if (enterMode == AppEnterModeBackgroundFromGoogle) {
        
//        BOOL success = NO;
//        
//        [self _setRootWireframeIfNeededWithParameters:nil];
//        success = [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
//        return success;
    }
	
    return NO;
}


- (void)handleRemoteNotification:(NSDictionary *)dictionary applicationStartMode:(AppStartMode)mode
{
	DLog(@"Did receive remote notification: %@",dictionary);
    

    
    if (mode == AppStartModeActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppManagerDidReceiveRemoteNotification object:dictionary];
    } else if(mode == AppStartModeInactive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appOpenedViaNotification" object:dictionary];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAllTabs" object:nil];
    }
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
//    if([MZThemeManager sharedInstance].neura != nil)
//    {
//        if ([NeuraSDKPushNotification handleNeuraPushWithInfo:userInfo fetchCompletionHandler:completionHandler]) {
//            // A Neura notification was consumed and handled.
//            // The SDK will call the completion handler.
//            return;
//        }
//    }
    
    // Handle your own remote notifications here.
    // . . .
    
    // Don't forget to call the completion handler!
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)activateRemoteNotificationsServiceWithTags:(NSArray *)tags
{
	
	if(tags.count > 0)
	{
		self.remoteNotificationTags = tags;
		
		UIApplication *application = [UIApplication sharedApplication];
		if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
			UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |
                                                UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
        
			[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
		}
	}
}


- (void)registerRemoteNotificationsServiceWithDeviceToken:(NSData *)deviceToken
{
    self.deviceToken = deviceToken;
    
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    DLog(@"The generated device token string is : %@",deviceTokenString);
    
    NSSet *set = [NSSet setWithArray:self.remoteNotificationTags];
	
//    if ([MZThemeManager sharedInstance].neura != nil)
//    {
//        [NeuraSDKPushNotification registerDeviceToken:deviceToken];
//    }
    
    [self unregisterOldRemoteNotificationsIfNecessary];
    
	[self.azureNotificationHub registerNativeWithDeviceToken:deviceToken tags:set completion:^(NSError* error) {
        if (error)
		{
			DLog(@"Error registering for notifications: %@", error);
        } else {
            DLog(@"Did registering for notifications");
        }
    }];
}


- (void)unregisterOldRemoteNotificationsIfNecessary
{

}

- (void)deactivateRemoteNotificationsService
{
    [self _clearNotificationsFromNotificationCenter];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [self.azureNotificationHub unregisterNativeWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Error unregistering for notifications: %@", error);
        }else {
            DLog(@"Did unregistering for notifications");
        }
    }];
}


- (void)_clearNotificationsFromNotificationCenter
{
    /// Reset application's badge number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void) startBackgroundAudioPlayer : (NSString *) streamUrl
{
//	self.backgroundAudioPlayer = [[IJKMediaPlayback alloc] initWithFrame: CGRectMake(0.0, 0.0, 0.0, 0.0) andCameraPath: streamUrl];
//	//[self.backgroundAudioPlayer ]
//	[self.backgroundAudioPlayer play];
}

- (void) stopBackgroundAudioPlayer
{
//	[self.backgroundAudioPlayer audio_off];
}

@end
