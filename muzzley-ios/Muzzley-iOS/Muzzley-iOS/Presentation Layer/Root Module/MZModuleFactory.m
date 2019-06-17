//
//  MZModuleFactory.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 4/8/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZModuleFactory.h"

#import "MZRootWireframe.h"

#import "DeviceTilesWireframe.h"
#import "DeviceTilesViewController.h"

#import "UserProfileWireframe.h"


#import "MZCardsWireframe.h"
//#import "MZCardsViewController.h"




@implementation MZModuleFactory


+ (MZUserProfileViewController *) userProfileViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe
{
//    MZUserProfileInteractor *userProfileInteractor = [[MZUserProfileInteractor alloc] init];
    //TODO check why it doesn't need init with rootwf
    UserProfileWireframe *userProfileWireframe = [[UserProfileWireframe alloc] initWithParentWireframe:rootWireframe];
    MZUserProfileViewController *viewController = [[MZUserProfileViewController alloc] initWithWireframe:userProfileWireframe];
    
    return viewController;  
}


+ (MZTilesViewController *) tilesViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe
{
	//MZTilesDataManager * dataManager = [MZTilesDataManager sharedInstance];
	DeviceTilesWireframe * channelsWF = [[DeviceTilesWireframe alloc] initWithParentWireframe:rootWireframe];

	MZDeviceTilesInteractor * devicesInteractor = [[MZDeviceTilesInteractor alloc] init];
	
	DeviceTilesViewController *devicesViewController = [[DeviceTilesViewController alloc] initWithWireframe:channelsWF interactor:devicesInteractor];

	channelsWF.deviceTilesViewController = devicesViewController;

    MZTilesViewController *viewController = [[MZTilesViewController alloc] initWithWireframe: channelsWF parentWireframe: rootWireframe];
	
	if(viewController == nil)
	{
	
	}
	return viewController;
}

+ (MZWorkersViewController *) workersViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe
{
    MZWorkersInteractor * interactor = [[MZWorkersInteractor alloc] init];

    MZWorkersViewController *viewController = [[MZWorkersViewController alloc] initWithNibName:@"MZWorkersViewController" bundle:[NSBundle mainBundle] interactor:interactor parentWireframe:rootWireframe ];
    
    return viewController;
}

+ (MZCardsTabViewController *) cardsViewControllerWithRootWireframe:(MZRootWireframe *)rootWireframe
{
    MZCardsInteractor *interactor = [[MZCardsInteractor alloc] init];
    //TODO userClient for what? >>> I need it because shortcuts need it
    //    interactor.userClient = userClient;
	
    MZCardsWireframe *wireframe = [[MZCardsWireframe alloc] initWithParentWireframe:rootWireframe];
    
    MZCardsTabViewController *viewController = [[MZCardsTabViewController alloc] initWithWireframe:wireframe interactor:interactor];
    wireframe.viewController = viewController;
    
    return viewController;
}

@end
