//
//  MZAppDelegate.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 21/11/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import "MZAppDelegate.h"
#import "AppManager.h"
#import <NeuraSDK/NeuraSDK.h>

@import GoogleMaps;
@import GooglePlaces;

@interface MZAppDelegate ()

@property (nonatomic, assign) BOOL urlLauchedApp;
@property (nonatomic, assign) AppEnterType appEnterType;
@property (nonatomic, strong) NSDictionary *appLauchedRemoteNotification;
@end

@implementation MZAppDelegate

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_application_did_receive_memory_warning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options
{
    return [self application:application openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_background_fetch_triggered];
    if([MZThemeManager sharedInstance].neura != nil)
    {
        [NeuraSDK.shared collectDataForBGFetchWithResult:^(UIBackgroundFetchResult collectDataResult) {
            completionHandler(collectDataResult);
        }];
    }
    
    
    [MZEmitLocationInteractor sharedInstance].startMonitoringLocation;
    [MZActivityInteractor shared].queryForRecentActivityData;
    [[MZContextManager shared] sendWifiInfoWithUnknownStart:true completion:^(NSError * error) {
        
    }];
}

- (BOOL)doesMatchURLScheme:(NSString *)scheme {
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"]) {
        NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        for(NSDictionary *urlType in urlTypes)
        {
            if(urlType[@"CFBundleURLSchemes"])
            {
                NSArray *urlSchemes = urlType[@"CFBundleURLSchemes"];
                for(NSString *urlScheme in urlSchemes)
                    if([urlScheme caseInsensitiveCompare:scheme] == NSOrderedSame)
                        return YES;
            }
            
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    
    if ([self doesMatchURLScheme:url.scheme]) {
        
        BOOL success;
        success = [[AppManager sharedManager] application:application handleOpenUrl:url sourceApplication:sourceApplication annotation:annotation launchedApp:_urlLauchedApp enterMode:AppEnterModeFirstLaunchFromURLSchema];
        
        if (_urlLauchedApp) _urlLauchedApp = NO;
        return success;
        
    } else if ([[url.scheme lowercaseString] containsString:GOOGLE_URL_SCHEME]) {
    
        self.appEnterType = AppEnterModeBackgroundFromGoogle;
        return [[AppManager sharedManager] application:application handleOpenUrl:url sourceApplication:sourceApplication annotation:annotation launchedApp:NO enterMode:_appEnterType];

    } else if ([url.scheme isEqualToString:FACEBOOK_URL_SCHEME]) {
    
        // Facebook
        self.appEnterType = AppEnterModeBackgroundFromFacebook;
        return [[AppManager sharedManager] application:application handleOpenUrl:url sourceApplication:sourceApplication annotation:annotation launchedApp:NO enterMode:_appEnterType];
    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].minimumBackgroundFetchInterval = 1800;
    
	[GMSServices provideAPIKey: [MZThemeManager sharedInstance].appInfo.googleMapsAPIKey];
    // Initiaze the app manager
    [[AppManager sharedManager] application:application handleDidFinishLaunchingWithOptions:launchOptions];

    /* Application was launched by a URL */
    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        _urlLauchedApp = YES;
        return YES;
    }
    
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_application_launched_with_location_key];
        [[MZContextManager shared] sendWifiInfoWithUnknownStart:true completion:^(NSError * error) {
            
        }];

        
        [[AppManager sharedManager] handleLaunchByLocationChanges];
        return YES;
    }
    
    /* Application was launched by a remote notification */
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification) {
            self.appLauchedRemoteNotification = remoteNotification;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appOpenedViaNotification" object:self userInfo:nil];
        }
        
        return YES;
    }
    
    /* Application was launched by the user */
    self.appEnterType = AppEnterModeFirstLaunch;
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[AppManager sharedManager] handleApplicationDidEnterBackground:application];
    [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_application_did_enter_background];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.appEnterType = AppEnterModeBackground;
    [[AppManager sharedManager] handleApplicationWillEnterForeground:application];
    [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_application_will_enter_foreground];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.appEnterType = AppEnterModeInactive;
    [[AppManager sharedManager] handleApplicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_application_did_become_active];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (self.appEnterType == AppEnterModeInactive)
	{
        self.appEnterType = AppEnterModeBackground;
    }
    
    if (self.appEnterType != AppEnterModeBackgroundFromFacebook &&
        self.appEnterType != AppEnterModeBackgroundFromGoogle)
	{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AbortGoogleAuthNotification" object:nil];
        
        NSDictionary *remoteNotification = nil;
        if (self.appLauchedRemoteNotification) {
            remoteNotification = [NSDictionary dictionaryWithDictionary:self.appLauchedRemoteNotification];
            self.appLauchedRemoteNotification = nil;
        }
    
        [[AppManager sharedManager] handleApplicationDidBecomeActiveWithParameters:remoteNotification];
		return;
    }
	
	// Validate session
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MZAppStatsHelper.shared updateCounter:MZAppStatsHelper.key_application_will_terminate];
}

/*!
 *  APPLE Push Notification Delegate Methods
 */


- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken
{
    
    
    [[AppManager sharedManager] registerRemoteNotificationsServiceWithDeviceToken:deviceToken];
}




- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Did fail to register for remote notifications with error: %@", error);
    NSLog(@">>> Error with registering for remote notifications: %@", error);
    NSLog(@"Please check that you set everything right for supporting push notifications on iOS dev center");
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    /*
    {
        aps =     {
            alert =         {
                actions =             (
                );
                body = "sdfsdf \nsdfsdf";
                title = sdfsdf;
            };
            expiry = "2015-03-19T09:34:04+00:00";
            sound = default;
        };
        eventId = 54ecc7fc80be6014484f14f1;
        notification =     {
            message = sdfsdf;
            title = sdfsdf;
        };
    }*/
    
    AppStartMode appStartMode;
    if(application.applicationState == UIApplicationStateActive) {
        appStartMode = AppStartModeActive;
    } else if(application.applicationState == UIApplicationStateInactive) {
        appStartMode = AppStartModeInactive;
    } else if(application.applicationState == UIApplicationStateBackground)  {
        appStartMode = AppStartModeBackground;
    } else {
        appStartMode = AppStartModeAwake;
    }
    
    
    [[AppManager sharedManager] handleRemoteNotification:userInfo applicationStartMode:appStartMode];
}

@end
