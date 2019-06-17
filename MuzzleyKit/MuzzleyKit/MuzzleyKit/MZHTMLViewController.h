//
//  MZHTMLViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 06/06/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZWidget.h"

@class MZHTMLViewController;
@protocol MZHTMLViewControllerDelegate <MZWidgetDelegate>
@optional
- (void)htmlViewController:(MZHTMLViewController *)htmlViewController onMessage:(NSDictionary *)message;
- (void)htmlViewControllerDidStartLoad:(MZHTMLViewController *)htmlViewController;
- (void)htmlViewController:(MZHTMLViewController *)htmlViewController didFailLoadWithError:(NSError *)error;
- (void)htmlViewControllerDidFinishLoad:(MZHTMLViewController *)htmlViewController;
@end

@interface MZHTMLViewController : MZWidget

@property (nonatomic, weak) id<MZHTMLViewControllerDelegate>delegate;

- (void)loadWithURLRequest:(NSURLRequest *)urlRequest withOptions:(NSDictionary*)options;
- (void)loadWithHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL withOptions:(NSDictionary*)options;

- (void)enableActivityIndicator:(BOOL)enabled;
@end
