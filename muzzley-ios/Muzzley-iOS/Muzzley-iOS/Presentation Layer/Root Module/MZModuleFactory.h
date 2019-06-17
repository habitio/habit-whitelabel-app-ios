//
//  MZModuleFactory.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 4/8/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

@class MZRootWireframe;
@class DeviceTilesViewController;
//@class MZUserProfileViewController;
@class MZWorkersViewController;
@class MZCardsViewController;

@protocol MZBaseClient;

@interface MZModuleFactory : NSObject

+ (DeviceTilesViewController *) tilesViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe;

+ (MZUserProfileViewController *) userProfileViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe;

+ (MZWorkersViewController *) workersViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe;

+ (MZCardsTabViewController *) cardsViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe;

@end
