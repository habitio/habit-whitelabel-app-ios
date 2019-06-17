//
//  MZAppManager.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 21/08/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

// App Manager Notification Keys
// -------------------------------------------------------------------------------------------
@protocol AppManagerLoadUserFromCacheDelegate <NSObject>

- (void)loadedUserCache;

@end

extern NSString *const AppManagerDidReceiveRemoteNotification;
extern NSString *const AppManagerDidReceiveMuzzleyURLSchema;
extern NSString *const AppManagerDidSelectRemoteNotification;
extern NSString *const AppManagerDidChangeStateNotification;
extern NSString *const AppManagerDidReceiveJoinActivityNotification;

typedef NS_ENUM(NSUInteger, AppStartMode) {
    AppStartModeAwake = 0,
    AppStartModeInactive,
    AppStartModeActive,
    AppStartModeBackground
};

typedef enum : NSUInteger {
    AppEnterModeInactive = 0,
    AppEnterModeFirstLaunch,
    AppEnterModeFirstLaunchFromURLSchema,
    AppEnterModeBackground,
    AppEnterModeBackgroundFromFacebook,
    AppEnterModeBackgroundFromGoogle
} AppEnterType;

typedef NS_ENUM(NSUInteger, AppBehaviourType) {
    AppBehaviourTypeStandard = 0,
    AppBehaviourTypeShowcase,
};

@interface AppManager : NSObject

@property (nonatomic, weak) id<AppManagerLoadUserFromCacheDelegate> loadFromCacheDelegate;
@property (nonatomic) AppStartMode appStartMode;

+ (AppManager *)sharedManager;

- (BOOL)application:(UIApplication *)application handleDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)application:(UIApplication *)application
      handleOpenUrl:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
        launchedApp:(BOOL)launchedApp
          enterMode:(AppEnterType)enterMode;

- (void)handleApplicationDidBecomeActiveWithParameters:(NSDictionary *)parameters;
- (void)handleApplicationWillResignActive;

- (void)handleApplicationDidEnterBackground:(UIApplication *)application;
- (void)handleApplicationWillEnterForeground:(UIApplication *)application;

- (void)handleLaunchByLocationChanges;
- (void)handleRemoteNotification:(NSDictionary *)dictionary applicationStartMode:(AppStartMode)mode;

// Push/Remote Notification Service
- (void)activateRemoteNotificationsServiceWithTags:(NSArray *)tags;
- (void)registerRemoteNotificationsServiceWithDeviceToken:(NSData *)deviceToken;
- (void)deactivateRemoteNotificationsService;

- (void) startBackgroundAudioPlayer : (NSString *) streamUrl;

- (void) stopBackgroundAudioPlayer;

@end
