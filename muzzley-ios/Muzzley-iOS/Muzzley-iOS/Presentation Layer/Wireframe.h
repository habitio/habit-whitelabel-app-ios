//
//  Wireframe.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 9/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

@class NavigationRouteCommand;

@interface Wireframe : NSObject

@property (nonatomic, weak) Wireframe *parentWireframe;

- (instancetype)initWithParentWireframe:(Wireframe *)parentWireframe;

/**
 Navigation Routing Interface
 */
- (void)handleNavigationRoute:(NavigationRouteCommand *)route;


/**
 Modal Navigation Interface
 */
- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated
                   completion:(void (^)(void))completion;

- (void) presentViewControllerWithoutClean:(UIViewController *)viewController animated:(BOOL)animated
                                completion:(void (^)(void))completion;

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

/**
 Stack Navigation Interface
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewControllerToEnd:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

@end
