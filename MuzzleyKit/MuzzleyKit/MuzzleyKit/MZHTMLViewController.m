//
//  MZHTMLViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 06/06/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZHTMLViewController.h"

#import "MZActivityIndicatorView.h"

#import "WebViewJavascriptBridge.h"

#import "MZUserClient.h"
#import "MZSettings.h"
#import "NSDictionary+JSON.h"
#import "MZError.h"

@interface MZHTMLViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIWebView *webview;

@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;

@property (nonatomic, strong) NSURL *urlHost;
@property (nonatomic, strong) NSMutableDictionary *subChannels;

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *bridgeOptions;

@property (nonatomic, strong) NSMutableArray*parentChannelSignalQueue;

@end

@implementation MZHTMLViewController
@dynamic delegate, parameters;

- (void)dealloc
{
    // Removes cache information stored from uiwebviews responses
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    _parentChannelSignalQueue = nil;
    
    [_javascriptBridge reset];
    _javascriptBridge = nil;
    
    _webview.delegate = nil;
    [_webview stopLoading];
    [_webview removeFromSuperview];
    _webview = nil;
    
    _bridgeOptions = nil;
    [self _unsubscribeSubChannels];
}

#pragma mark - Initializers
-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZHTMLViewController *HTMLViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZHTMLViewController"];
    self = HTMLViewController;
    
    if (self) {
        // Custom initialization
        self.parameters = parameters;
        // Subchannels creation
        _subChannels = [NSMutableDictionary new];
        // Parent Channel Signal Queue creation
        _parentChannelSignalQueue = [NSMutableArray new];
        // Default parameters
        // orientation parameter
        _interfaceOrientation = UIInterfaceOrientationPortrait;
        _interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
        
        if ([self.parameters objectForKey:@"orientation"]) {
            
            NSString *orientationString = self.parameters[@"orientation"];
            
            if ([orientationString isEqualToString:@"landscape"]) {
                
                _interfaceOrientationMask = UIInterfaceOrientationMaskLandscape;
                _interfaceOrientation = UIInterfaceOrientationLandscapeRight;
                
            } else if ([orientationString isEqualToString:@"portrait"]) {
                
                _interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
                _interfaceOrientation = UIInterfaceOrientationPortrait;
            }
        }
        
        // webview content host url
        NSString *muzzleyWebviewContentHost = [MZSettings sharedSettings].muzzleyWebviewContentURL;

        //uuid parameter
        NSString *uuid = self.parameters[@"uuid"];
        if (uuid) {
            NSString *fullURL = [muzzleyWebviewContentHost stringByReplacingOccurrencesOfString:@"{uuid}" withString:uuid];
            self.urlHost = [NSURL URLWithString:fullURL];
        }
        
        NSURL *url = self.parameters[@"url"];
        if (url) {
            self.urlHost = url;
        }
        
        // webview javascript bridge options
        self.bridgeOptions = self.parameters[@"options"];
    }
    return self;
}

#pragma mark - View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return _interfaceOrientationMask;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webview.scrollView.bounces = NO;
    self.webview.allowsInlineMediaPlayback = YES;
    self.webview.mediaPlaybackRequiresUserAction = NO;
    
    [self _initializeJavascriptBridge];
    
    if (self.urlHost) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlHost];
        [self loadWithURLRequest:request withOptions:self.bridgeOptions];
    }
}

- (void)loadWithURLRequest:(NSURLRequest *)urlRequest withOptions:(NSDictionary*)options
{
    if ([urlRequest isKindOfClass:[NSURLRequest class]]) {
        
        [self _resetConfigurations];
        
        self.urlHost = urlRequest.URL;
        // webview javascript bridge options
        self.bridgeOptions = options;
        self.javascriptBridge.options = self.bridgeOptions;
        
        // Load url request on webview
        [self.webview stopLoading];
        [self.webview loadRequest:urlRequest];
    }
}


- (void)loadWithHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL withOptions:(NSDictionary *)options
{
    [self _resetConfigurations];
    
    // webview javascript bridge options
    self.bridgeOptions = options;
    self.javascriptBridge.options = self.bridgeOptions;
    
    // Load url request on webview
    [self.webview stopLoading];
    [self.webview loadHTMLString:htmlString baseURL:baseURL];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.javascriptBridge reset];
    self.javascriptBridge = nil;
    
    self.webview.delegate = nil;
    [self.webview stopLoading];
    [self.webview removeFromSuperview];
    self.webview = nil;
}

- (void)enableActivityIndicator:(BOOL)enabled
{
    CGFloat alpha = enabled ? 1 : 0;
    self.activityIndicator.alpha = alpha;
}

- (void)setMuzzleyChannel:(MZMuzzleyChannel *)muzzleyChannel
{
    [super setMuzzleyChannel:muzzleyChannel];
    
    __typeof__(self) __weak welf = self;
    [muzzleyChannel on:@"signal" callback:^(MZMessage *message, MZResponseBlock response) {
        [welf _onNativeChannelSignal:message response:response];
    }];
}

- (void)_initializeJavascriptBridge
{
    self.javascriptBridge = [WebViewJavascriptBridge
                             bridgeForWebView:self.webview webViewDelegate:self
                             options:self.bridgeOptions
                             handler:^(id data, WVJBResponseCallback responseCallback)
    {
        __typeof__(self) __weak welf = self;
        // ObjC Handler that receives messages from JS through (id)data parameter);
        // Check if it's a valid dictionary to parse business logic.
        NSDictionary *messageDict;
        if ([data isKindOfClass:[NSString class]]) {
            messageDict = [NSDictionary dictionaryFromContentsOfJSONString:data];
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            messageDict = data;
        } else {
            NSDictionary *responseDictionary = @{
                                                 @"s" : @NO,
                                                 @"m": @"The data sent from the bridge to the native environment must be a string or a JSON object."
                                                };
            
            if(responseCallback) responseCallback(responseDictionary);
            return;
        }
        //NSLog(@"\n webviewRequest: %@", messageDict);
        // Parse to define the specific business logic action
        NSString *action = messageDict[@"a"];
        
        if ([action isEqualToString:@"bridgeReady"]) {
            [welf _onBridgeReady];
        } else if ([action isEqualToString:@"saveRule"]) {
            [welf _onBridgeSaveRuleActionWithDictionary:messageDict responseCallback:responseCallback];
        } else if ([action isEqualToString:@"publish"]) {
            [welf _onBridgePublishActionWithDictionary:messageDict responseCallback:responseCallback];
        } else if ([action isEqualToString:@"subscribe"]) {
            [welf _onBridgeSubscribeActionWithDictionary:messageDict responseCallback:responseCallback];
        } else if ([action isEqualToString:@"unsubscribe"]) {
            [welf _onBridgeUnsubscribeActionWithDictionary:messageDict responseCallback:responseCallback];
        } else if ([action isEqualToString:@"signal"]) {
            [welf _onBridgeChannelSignalActionWithDictionary:messageDict responseCallback:responseCallback];
        } else {
            NSString *information = [NSString stringWithFormat:@"The native bridge environment only accepts the specific actions:[ publish | subscribe | unsubscribe | signal]. The action sent was:%@", action];
            NSDictionary *responseDictionary = @{
                                                 @"s" : @NO,
                                                 @"m": information
                                                };
            if (responseCallback) responseCallback(responseDictionary);
        }
    }];
}

- (void)_resetConfigurations
{
    [self.javascriptBridge reset];
    
    [self _unsubscribeSubChannels];
}

#pragma mark - Private Methods
- (void)_onBridgeReady
{
    //NSLog(@"_onBridgeReady");
    for (NSMutableDictionary *storedSignalMessage in self.parentChannelSignalQueue) {
    
        NSDictionary *messageDictionary = storedSignalMessage[@"message"];
        WVJBResponseCallback responseCallback = storedSignalMessage[@"responseCallback"];
        
        if (self.javascriptBridge) {
            [self.javascriptBridge send:messageDictionary responseCallback:responseCallback];
        }
    }
    // destroy the parentChannelSignalQueue
    self.parentChannelSignalQueue = nil;
}

- (void)_onBridgeSaveRuleActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
    NSDictionary *responseDictionary = @{ @"s" : @YES, @"m": @"Action received." };
    if (responseCallback) responseCallback(responseDictionary);
    
    if ([self.delegate respondsToSelector:@selector(htmlViewController:onMessage:)]) {
        [self.delegate htmlViewController:self onMessage:message];
    }
}

- (void)_onBridgePublishActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
    NSString *ns = [message valueForKeyPath:@"d.ns"];
    NSDictionary *payload = [message valueForKeyPath:@"d.p"];
    
    void (^handler)(MZResponseMessage *response, NSError *error) = nil;
    if (responseCallback) {
        handler = ^(MZResponseMessage *response, NSError *error) {
            if (responseCallback) responseCallback([response toDictionary]);
        };
    }
    [self.muzzleyClient publishWithNamespace:ns payload:payload completion:handler];
}

- (void)_onBridgeSubscribeActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
    /** Subscribe Completion Handler
     
        When a channel is returned from subscribe, we must inform the bridge what is its channel id.
        If a response Callback is provided by the bridge, we save the new channel in this MZHTMLViewController context, so when this controller deallocs all channel unsubscribe.
        If a response Callback is not provided, we must abort the subscribe operation.
     */
    if (!responseCallback) {
        NSString *information = @"Subscribe operation was aborted. You must define a response callback so the native environment can respond to.";
        NSDictionary *responseDictionary = @{
                                             @"s" : @NO,
                                             @"m": information
                                             };
        responseCallback(responseDictionary);
        return;
    }
    
    NSString *ns = [message valueForKeyPath:@"d.ns"];
    NSDictionary *payload = [message valueForKeyPath:@"d.p"];
    __typeof__(self) __weak welf = self;
    
    void (^handler)(MZMuzzleyChannel *channel, NSError *error) = nil;
    handler = ^(MZMuzzleyChannel *channel, NSError *error) {
        
        //__typeof__(self) strongSelf = welf;
        
        if (error) {
            NSLog(@"Channel(%@) subscribe error:%@",channel.identifier, error.localizedDescription);
            if (responseCallback) {
                NSDictionary *responseDictionary = @{
                                                     @"s" : @NO,
                                                     @"m": error.localizedDescription
                                                    };
                responseCallback(responseDictionary);
            }
            return;
        }
        
        [channel on:@"signal" callback:^(MZMessage *message, MZResponseBlock response) {
            [welf _onNativeChannelSignal:message response:response];
        }];
        
        // The behaviour is similar to signal, so we call the same handler
        [channel on:@"publish" callback:^(MZMessage *message, MZResponseBlock response) {
            [welf _onNativeChannelSignal:message response:response];
        }];
        
        NSLog(@"Channel:%@ subscribed",channel.identifier);
        [welf.subChannels setObject:channel forKey:channel.identifier];
        
        if (responseCallback) {
            responseCallback(@{
                               @"s" : @YES,
                               @"d" : @{
                                        @"channel" : @{
                                                       @"id" : channel.identifier
                                                      }
                                       }
                               });
        }
    };
    
    [self.muzzleyClient subscribeWithNamespace:ns payload:payload completion:handler];
}

- (void)_onBridgeUnsubscribeActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
    NSString *channelIdentifier = [message valueForKeyPath:@"d.channelId"];
    MZMuzzleyChannel *channel = [self.subChannels objectForKey:channelIdentifier];
    
    NSString *information = [NSString stringWithFormat:@"The channel(%@) you request to unsubscribe is already unsubscribed.",channelIdentifier];
    if (!channel) {
        if (responseCallback) {
            responseCallback(@{ @"s" : @NO, @"m" : information });
        }
        return;
    }
    
    void (^handler)(BOOL success, NSError *error) = nil;
    if (responseCallback) {
        handler = ^(BOOL success, NSError *error) {
            if (error && responseCallback) {
                NSString *information = [NSString stringWithFormat:@"Channel(%@) unsubscribe error:%@",channel.identifier, error.localizedDescription];
                responseCallback(@{ @"s" : @NO, @"m" : error.localizedDescription });
                NSLog(@"%@",information);
                return;
            }
            if (responseCallback) {
                responseCallback(@{ @"s" : @YES });
            }
            NSLog(@"Channel(%@) unsubscribed",channel.identifier);
        };
    }
    
    [channel unsubscribeWithCompletion:handler];
}

- (void)_onBridgeChannelSignalActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
    NSDictionary *data = message[@"d"];
    
    void (^handler)(MZResponseMessage *response, MZError *error) = nil;
    if (responseCallback) {
        handler = ^(MZResponseMessage *response, MZError *error) {
            if (error) {
                responseCallback(@{ @"s" : @NO, @"m" : error.localizedDescription });
                NSLog(@"%@",error.localizedDescription);
                return;
            }
            if (responseCallback) {
                responseCallback([response toDictionary]);
            }
        };
    }
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:handler];
}

- (void)_onNativeChannelSignal:(MZMessage *)message response:(MZResponseBlock)response
{
    //NSLog(@"onNativeChannelSignal");
    NSDictionary *messageDictionary = [message toDictionary];
    
    WVJBResponseCallback responseCallback = ^(id responseData) {
        
        //NSLog(@"Webview response to activityRequest:%@", responseData);
        id data =    [responseData objectForKey:@"d"];
        NSString *description = [responseData objectForKey:@"m"];
        NSNumber *s =           [responseData objectForKey:@"s"];
        BOOL success = NO;
        if (s) success = s.boolValue;
        
        if(response) response(data,description,success);
    };
    
    // Don't need response
    if (!response) {
        responseCallback = nil;
    }
    
    // If the widget view loaded and the bridge is ready the message is sent directly to the bridge
    if (self.javascriptBridge) {
        [self.javascriptBridge send:messageDictionary responseCallback:responseCallback];
        return;
    }
    // Otherwise messages that arrive before the bridge is ready are stored in the queue for later processing.
    NSMutableDictionary *storedSignalMessage = [NSMutableDictionary new];
    storedSignalMessage[@"message"] = messageDictionary;
    if (responseCallback){
        storedSignalMessage[@"responseCallback"] = [responseCallback copy];
    }
    if (self.parentChannelSignalQueue) {
        [self.parentChannelSignalQueue addObject:storedSignalMessage];
        return;
    }
}

#pragma mark - Webview Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    
    if ([self.delegate respondsToSelector:@selector(htmlViewControllerDidStartLoad:)]) {
        [self.delegate htmlViewControllerDidStartLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(htmlViewController:didFailLoadWithError:)]) {
        [self.delegate htmlViewController:self didFailLoadWithError:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
                            UIViewAnimationCurveEaseIn
                     animations:^{
                         [weakSelf.activityIndicator stopAnimating];
                     } completion:^(BOOL finished) {
                         
                     }];
    if ([self.delegate respondsToSelector:@selector(htmlViewControllerDidFinishLoad:)]) {
        [self.delegate htmlViewControllerDidFinishLoad:self];
    }
}

/// This selector is called when something is loaded in our webview
/// By something I don't mean anything but just "some" :
///  - main html document
///  - sub iframes document

// But all images, xmlhttprequest, css, ... files/requests doesn't generate such events :/
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)_unsubscribeSubChannels
{
    NSArray *subChannelsArray = [_subChannels allValues];
    for (MZMuzzleyChannel *channel in subChannelsArray) {
        [channel unsubscribeWithCompletion:nil];
    }
    [self.subChannels removeAllObjects];
}

@end
