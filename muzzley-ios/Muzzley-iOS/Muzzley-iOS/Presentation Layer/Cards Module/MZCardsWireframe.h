//
//  MZUserEventsListWireframe.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "Wireframe.h"

@class MZCardsTabViewController;
@class ExecuteCommand;
@class MZFieldViewModel;

@interface MZCardsWireframe : Wireframe

@property (nonatomic, weak) MZCardsTabViewController *viewController;
@property (nonatomic, weak) MZFieldViewModel *field;

- (void)showWebpageWithURL:(NSURL *)url animated:(BOOL)animated;
- (void) showDevicesScreen;

@end
