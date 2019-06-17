//
//  MZHTMLViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 24/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZWidget.h"

@class MZHTMLViewController;
@protocol MZHTMLViewControllerDelegate <MZWidgetDelegate>
@optional
- (void)htmlViewController:(MZHTMLViewController *)htmlViewController onMessage:(NSDictionary *)message;
- (void)htmlViewControllerDidStartLoad:(MZHTMLViewController *)htmlViewController;
- (void)htmlViewController:(MZHTMLViewController *)htmlViewController didFailLoadWithError:(NSError *)error;
- (void)htmlViewControllerDidFinishLoad:(MZHTMLViewController *)htmlViewController;
- (void)htmlViewController:(MZHTMLViewController *)htmlViewController didTapAtLocation:(CGPoint)point;
- (void)htmlViewController:(MZHTMLViewController *)htmlViewController didReceiveComponentAction:(NSString *)action withMessage:(NSDictionary *)message;
@end

@interface MZHTMLViewController : MZWidget

@property (nonatomic, weak) id<MZHTMLViewControllerDelegate>delegate;
@property (nonatomic) BOOL isGroupView;
@property (nonatomic) NSNumber* tilesCount;


- (void)loadWithURLRequest:(NSURLRequest *)urlRequest withOptions:(NSDictionary*)options;
- (void)loadWithURLRequest:(NSURLRequest *)urlRequest withOptions:(NSDictionary*)options andNativeComponents:(NSArray *)components;
- (void)loadWithHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL withOptions:(NSDictionary*)options;

//- (void)_sendMessageToWebview:(MZMessage * )message;

- (void)enableActivityIndicator:(BOOL)enabled;

- (void)_unsubscribeSubChannels;


@end
