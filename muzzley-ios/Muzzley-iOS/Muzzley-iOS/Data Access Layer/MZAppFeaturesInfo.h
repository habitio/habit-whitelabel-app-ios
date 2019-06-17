//
//  MZAppFeatures.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 27/03/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZAppFeaturesInfo : NSObject

+ (BOOL)isFeatureMixpanelEnabled;
+ (BOOL)isFeatureSplashScreenAnimationEnabled;
+ (BOOL)isFeatureMockDataEnabled;

@end
