//
//  MZAppFeatures.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/03/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZAppFeaturesInfo.h"

NSString *const APP_FEATURE_CONFIG_FILENAME = @"AppFeatureConfig";

@implementation MZAppFeaturesInfo

#pragma mark - App Features Activation Info

+ (BOOL)isFeatureMixpanelEnabled
{
    NSDictionary *configuration = [self _appFeatureConfigDictionary];
    return [configuration[@"MZ_FEATURE_MIXPANEL_ENABLED"] boolValue];
}

+ (BOOL)isFeatureSplashScreenAnimationEnabled
{
    NSDictionary *configuration = [self _appFeatureConfigDictionary];
    return [configuration[@"MZ_FEATURE_SPLASH_SCREEN_ANIMATION"] boolValue];
}

+ (BOOL)isFeatureMockDataEnabled
{
    NSDictionary *configuration = [self _appFeatureConfigDictionary];
    return [configuration[@"MZ_FEATURE_MOCK_DATA"] boolValue];
}

+ (NSDictionary *)_appFeatureConfigDictionary
{
    NSString *file = [[NSBundle mainBundle] pathForResource:APP_FEATURE_CONFIG_FILENAME ofType:@"plist"];
    NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:file];
    return configuration ? configuration : [NSDictionary new];
}

@end
