//
//  DeviceTileProblemView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/10/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "MZView.h"


@class DeviceTileProblemView;

@protocol DeviceTileProblemViewDelegate <NSObject>
- (void)deviceTileProblemViewDidPressTryAgainAction:(DeviceTileProblemView *)view;
- (void)deviceTileProblemViewDidPressCancelAction:(DeviceTileProblemView *)view;
@end

@interface DeviceTileProblemView : MZView
@property (nonatomic, weak) id<DeviceTileProblemViewDelegate> delegate;
@end