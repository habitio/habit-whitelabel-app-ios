//
//  MZUserEventsListWireframe.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZCardsWireframe.h"

#import "JLRoutes.h"
#import "NavigationRouteCommand.h"

#import "UINavigationControllerPortrait.h"
//#import "MZCardsViewController.h"
#import "MZWebViewController.h"
#import "MZRootWireframe.h"


@interface MZCardsWireframe () <UIActionSheetDelegate>

@end

@implementation MZCardsWireframe

- (void)dealloc
{
    [JLRoutes removeRoute:URL_NAVIGATION_ROUTE_PATTERN_TIMELINE_EVENT];
}

- (instancetype)initWithParentWireframe:(Wireframe *)parentWireframe
{
    if (self = [super initWithParentWireframe:parentWireframe]) {
        __typeof__(self) __weak weakSelf = self;
        
        [JLRoutes addRoute:URL_NAVIGATION_ROUTE_PATTERN_TIMELINE_EVENT handler:^BOOL(NSDictionary *parameters) {
            if (weakSelf) {
                //NSString *timelineEventId = [parameters objectForKey:@"id"];
            }
            return YES;
        }];
    }
    return self;
}

- (void)handleNavigationRoute:(NavigationRouteCommand *)route
{
    if ([route isKindOfClass:[NavigationRouteCommand class]]) {
        [JLRoutes routeURL:route.url];
    }
}

- (void)showWebpageWithURL:(NSURL *)url animated:(BOOL)animated
{
    //removed internal webview till issue with incorrect page view fixed
//    MZWebViewController *vc = [MZWebViewController new];
//    vc.url = url;
//    [self.parentWireframe pushViewControllerToEnd:vc animated:YES];
    
    [[UIApplication sharedApplication] openURL:url];
}


- (void) showDevicesScreen
{
    [((MZRootWireframe*)self.parentWireframe) showDevicesScreenAnimated:NO];
}

@end
