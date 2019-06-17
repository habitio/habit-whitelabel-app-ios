//
//  MZDeviceVolumeViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZDeviceVolumeViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *volumeBackgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *volumeUpView;
@property (nonatomic, strong) IBOutlet UIImageView *volumeDownView;

- (void)startVolumeUpAnimation;
- (void)startVolumeDownAnimation;
@end
