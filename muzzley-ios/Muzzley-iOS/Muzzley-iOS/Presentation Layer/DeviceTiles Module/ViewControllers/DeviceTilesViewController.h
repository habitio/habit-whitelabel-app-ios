//
//  UserDevicesViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 02/05/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceTilesWireframe.h"

@class DeviceTilesViewController;
@class MZChannel;
@class EChannelCategory;
@class MZDeviceTilesInteractor;

@protocol DeviceTilesViewControllerDelegate <NSObject>

- (void)deviceTilesViewControllerDidSelectAddDevice:(DeviceTilesViewController *)viewController;
@end

@interface DeviceTilesViewController : UIViewController

@property(nonatomic, weak) id<DeviceTilesViewControllerDelegate> delegate;
@property (nonatomic, readonly) DeviceTilesWireframe *wireframe;
@property (nonatomic, readwrite) MZDeviceTilesInteractor * interactor;
@property (nonatomic) bool isDevicesViewVisible;
@property (nonatomic) bool hasGroupableDevices;


- (void)scrollToTop;
- (void)reloadData;
- (instancetype)initWithWireframe:(DeviceTilesWireframe *)wireframe
                       interactor:(MZDeviceTilesInteractor *)interactor;

@end
