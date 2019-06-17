//
//  MZHTMLViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 24/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//


#import "MZHTMLViewController.h"

#import "WebViewJavascriptBridge.h"
#import "NSDictionary+JSON.h"

#import "Muzzley-iOS-Bridging-Header.h"

//#import "MZError.h"

@interface MZHTMLViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>

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

@property (nonatomic, strong) NSArray * nativeComponents;

@property (nonatomic, strong) WVJBResponseCallback nativeResponseCallback;
@property (nonatomic, strong) NSString * nativeResponseAction;

@property NSUInteger * cid;

@end

@implementation MZHTMLViewController
@dynamic delegate, parameters;

- (void)dealloc
{
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

- (instancetype)initWithParameters:(NSDictionary*)parameters
{
    if (self = [super initWithNibName:NSStringFromClass([MZHTMLViewController class]) bundle:[NSBundle mainBundle]])
	{
		self.cid = 1;
        // Custom initialization
        self.parameters = parameters;
		self.nativeResponseCallback = nil;
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
        
        NSURL *url = self.parameters[@"url"];
        if (url)
		{
            self.urlHost = url;
        }
        
        // webview javascript bridge options
		//[self.parameters[@"options"] setValue:MZSessionDataManager.sharedInstance.session.userProfile.getPreferencesAsDictionary forKey:@"preferences"];
        self.bridgeOptions = self.parameters[@"options"];
    }
    return self;
}

#pragma mark - View Rotation
-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return _interfaceOrientationMask;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webview.scrollView.bounces = NO;
    self.webview.allowsInlineMediaPlayback = YES;
    self.webview.mediaPlaybackRequiresUserAction = NO;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.webview addGestureRecognizer:tapGesture];
    
    [self _initializeJavascriptBridge];
    
    DLog(@"urlHost %@", self.urlHost);
    
    if (self.urlHost) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlHost];
        [self loadWithURLRequest:request withOptions:self.bridgeOptions];
		
    }
}

- (void)loadWithURLRequest:(NSURLRequest *)urlRequest withOptions:(NSDictionary*)options {
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


- (void)loadWithURLRequest:(NSURLRequest *)urlRequest withOptions:(NSDictionary*)options andNativeComponents:(NSArray *)components{
    if ([urlRequest isKindOfClass:[NSURLRequest class]]) {
        
        [self _resetConfigurations];
        
        _nativeComponents = components;
        self.urlHost = urlRequest.URL;
        // webview javascript bridge options
        self.bridgeOptions = options;
        self.javascriptBridge.options = self.bridgeOptions;
        
        // Load url request on webview
        [self.webview stopLoading];
        [self.webview loadRequest:urlRequest];
    }
}


- (void)loadWithHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL withOptions:(NSDictionary *)options {
    [self _resetConfigurations];
    
    // webview javascript bridge options
    self.bridgeOptions = options;
    self.javascriptBridge.options = self.bridgeOptions;
    
    // Load url request on webview
    [self.webview stopLoading];
    [self.webview loadHTMLString:htmlString baseURL:baseURL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.javascriptBridge reset];
    self.javascriptBridge = nil;
    
    self.webview.delegate = nil;
    [self.webview stopLoading];
    [self.webview removeFromSuperview];
    self.webview = nil;
}

- (void)enableActivityIndicator:(BOOL)enabled {
    CGFloat alpha = enabled ? 1 : 0;
    self.activityIndicator.alpha = alpha;
}


- (void)_initializeJavascriptBridge
{
	[[MZMQTTConnection sharedInstance] listenToDidReceiveMessage: ^(MZMQTTMessage * mqttMessage) {
		
		if (self.javascriptBridge)
		{
			if(![[MZMQTTWebviewMessageHelper isMessageValid: mqttMessage] isEqual: @""])
			{
				MZMQTTMessage * messageWithHeader = [MZMQTTWebviewMessageHelper createMessageWithHeader: mqttMessage];
				//DLog(@"\n message i: %@", messageWithHeader.message);
				[self.javascriptBridge send:messageWithHeader.message responseCallback:nil];
				return;
			}
		}
	}];
	
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
//								 DLog(@"action");
//								 DLog(@"%@", action);
								 if ([action isEqualToString:@"bridgeReady"]) {
                                     [welf _onBridgeReady];
                                 } else if ([action isEqualToString:@"saveRule"]) {
                                     [welf _onBridgeSaveRuleActionWithDictionary:messageDict responseCallback:responseCallback];
								 } else if ([action isEqualToString:@"openUrl"]) {
									 [welf _onBridgeOpenUrlActionWithDictionary:messageDict responseCallback:responseCallback];
//								 } else if ([action isEqualToString:@"getCurrencySpec"]) { // Commented until the currency feature is finished
//									 [welf _onBridgeGetCurrencySpecActionWithDictionary:messageDict responseCallback:responseCallback];
								 }else if ([action isEqualToString:@"getUnitsSpec"]) {
									 [welf _onBridgeGetUnitsSpecActionWithDictionary:messageDict responseCallback:responseCallback];
								 }else if ([action isEqualToString:@"getWhiteLabelConfig"]) {
									 [welf _onBridgeGetWhiteLabelConfigActionWithDictionary:messageDict responseCallback:responseCallback];
								 }else if ([action isEqualToString:@"publish"]) {
                                     [welf _onBridgePublishActionWithDictionary:messageDict responseCallback:responseCallback];
                                 } else if ([action isEqualToString:@"subscribe"]) {
                                     [welf _onBridgeSubscribeActionWithDictionary:messageDict responseCallback:responseCallback];
                                 } else if ([action isEqualToString:@"unsubscribe"]) {
                                     [welf _onBridgeUnsubscribeActionWithDictionary:messageDict responseCallback:responseCallback];
//                                 } else if ([action isEqualToString:@"signal"]) {
//                                     [welf _onBridgeChannelSignalActionWithDictionary:messageDict responseCallback:responseCallback];
                                 } else if ([action isEqualToString:@"getAllComponents"]) {
                                     [welf _onGetAllComponentsWithCallback:responseCallback];
                                 } else if ([action isEqualToString:@"onComponent"]) {
                                     [welf _onComponentEvent:messageDict WithCallback:responseCallback];
								 } else if ([action isEqualToString:@"getGrammar"]) {
									 [welf _onGetGrammarWithCallback:messageDict WithCallback:responseCallback];
                                 } else if ([action isEqualToString:@"sendComponent"]) {
                                     [welf _sendComponentMessage:messageDict WithCallback:responseCallback];
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

- (void)_resetConfigurations {
    [self.javascriptBridge reset];
    
    _nativeComponents = nil;
    
    [self _unsubscribeSubChannels];
}

#pragma mark - Private Methods
- (void)_onBridgeReady {
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

- (void)_onBridgeSaveRuleActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback {
    NSDictionary *responseDictionary = @{ @"s" : @YES, @"m": @"Action received." };
    if (responseCallback) responseCallback(responseDictionary);
    
    if ([self.delegate respondsToSelector:@selector(htmlViewController:onMessage:)]) {
        [self.delegate htmlViewController:self onMessage:message];
    }
}

- (void)_onBridgeGetUnitsSpecActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
	NSDictionary *responseDictionary = @{ @"s" : @YES, @"m": @"Action received.", @"d" : MZSessionDataManager.sharedInstance.session.unitsSpec.unitsDictionary };
	if (responseCallback) responseCallback(responseDictionary);
}

- (void)_onBridgeOpenUrlActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
	DLog(@"%@", message[@"d"]);
	
	NSDictionary *responseDictionary = @{ @"s" : @YES, @"m": @"Url received."};
	if (responseCallback) responseCallback(responseDictionary);
	
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:message[@"d"]];

	// TODO: Handle case where the url is an app scheme and the app is not installed !

	if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
	{
		
		if ([application respondsToSelector:@selector(openURL:options:completionHandler:)])
		{
			[application openURL:URL options:@{} completionHandler:^(BOOL success) {
			}];
		}
		else
		{
			BOOL success = [application openURL:URL];
		}
	}
	else
	{
		bool can = [application canOpenURL:URL];
		
		if(can)
		{
			[application openURL:URL];
		}
		else
		{
		
		}
	}
	
}

- (void)_onBridgeGetWhiteLabelConfigActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
	NSDictionary *responseDictionary = @{ @"s" : @YES, @"m": @"Action received.", @"d" : [MZThemeManager sharedInstance].sharedInterface };

	if (responseCallback) responseCallback(responseDictionary);
}

- (void)_onBridgeGetCurrencySpecActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback {
	NSDictionary *responseDictionary = @{ @"s" : @YES, @"m": @"Action received.", @"d" : MZSessionDataManager.sharedInstance.session.currencySpec.currencyDictionary };
	if (responseCallback) responseCallback(responseDictionary);
}


- (void)_onBridgePublishActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
	[MZMQTTWebviewMessageHelper sendMQTTPublish: message completion:^(BOOL success, NSString * topic, NSError * error) {
		
		NSDictionary *responseDictionary;
		if(success)
		{
			responseDictionary = @{@"s": @YES, @"m": @"" };
		}
		else
		{
			responseDictionary = @{@"s": @NO,  @"m": @"" };
		}
		
		if (responseCallback) responseCallback(responseDictionary);
		
	}];
}
	
- (void)_onBridgeSubscribeActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback
{
	DLog(@"%@", message);
	
	[MZMQTTWebviewMessageHelper sendMQTTSubscribe: message completion:^(BOOL success, NSString * subscribedChannel, NSError * error) {
		NSDictionary *responseDictionary;
		if(success)
		{
			responseDictionary = @{@"s": @YES, @"m": @"",  @"d" : @{ @"channel": @{@"id" : subscribedChannel}}};
		}
		else
		{
			responseDictionary = @{@"s": @NO,  @"m": @"" };
		}

		NSLog(@"\n Native response to webviewRequest: %@", responseDictionary);

		if (responseCallback) responseCallback(responseDictionary);
	}];
	
}

- (void)_onBridgeUnsubscribeActionWithDictionary:(NSDictionary *)message responseCallback:(WVJBResponseCallback)responseCallback {
	
	[MZMQTTWebviewMessageHelper unsubscribeAll];
}

//- (void)_onNativeChannelSignal:(MZMessage *)message response:(MZResponseBlock)response {
//    //NSLog(@"onNativeChannelSignal");
//    NSDictionary *messageDictionary = [message toDictionary];
//    
//    WVJBResponseCallback responseCallback = ^(id responseData) {
//        
//        //NSLog(@"Webview response to activityRequest:%@", responseData);
//        id data =    [responseData objectForKey:@"d"];
//        NSString *description = [responseData objectForKey:@"m"];
//        NSNumber *s =           [responseData objectForKey:@"s"];
//        BOOL success = NO;
//        if (s) success = s.boolValue;
//        
//        if(response) response(data,description,success);
//    };
//    
//    // Don't need response
//    if (!response) {
//        responseCallback = nil;
//    }
//    
//    // If the widget view loaded and the bridge is ready the message is sent directly to the bridge
//    if (self.javascriptBridge) {
//        [self.javascriptBridge send:messageDictionary responseCallback:responseCallback];
//        return;
//    }
//    // Otherwise messages that arrive before the bridge is ready are stored in the queue for later processing.
//    NSMutableDictionary *storedSignalMessage = [NSMutableDictionary new];
//    storedSignalMessage[@"message"] = messageDictionary;
//    if (responseCallback){
//        storedSignalMessage[@"responseCallback"] = [responseCallback copy];
//    }
//    if (self.parentChannelSignalQueue) {
//        [self.parentChannelSignalQueue addObject:storedSignalMessage];
//        return;
//    }
//}


#pragma mark Components

- (void)_onGetAllComponentsWithCallback:(WVJBResponseCallback)responseCallback {
    if (_nativeComponents) {
        NSMutableArray * components = [NSMutableArray new];
        for (MZTileNativeComponentViewModel * native in _nativeComponents) {
            [components addObject:[native toJsonDictionary]];
        }
        
        NSDictionary *responseDictionary = @{ @"s" : @YES,
                                              @"d": @{@"nativeComponents": components}};
		
		
		DLog(@"%@", responseDictionary);

        if (responseCallback) responseCallback(responseDictionary);
    }
}


- (void)_onComponentEvent:(NSDictionary *)message WithCallback:(WVJBResponseCallback)responseCallback {
    if (_nativeComponents)
	{
		
	NSDictionary *responseDictionary = @{@"s": @YES,
										 @"m": @"",
									     @"d": message[@"d"]};
		
		self.nativeResponseAction = message[@"d"];
		self.nativeResponseCallback = responseCallback;
		
		if (responseCallback)
			responseCallback(responseDictionary);
    }
}

- (void)_onGetGrammarWithCallback:(NSDictionary *)message WithCallback:(WVJBResponseCallback)responseCallback
{
	// TESTING PURPOSES
	NSArray * array = [NSArray arrayWithObjects:@"when weather station's temperature is lower than 23.3",@"set weather station's temperature to 25.5", nil];
	
	NSDictionary *responseDictionary = @{@"s": @YES,
										 @"m": @"",
										 @"d": array };
	if (responseCallback) responseCallback(responseDictionary);
	
//	MZTranslationsWebService * translationsWS = [MZTranslationsWebService init];
//	
//	[translationsWS getGrammar:message[@"d"] completion:^(NSDictionary *result, NSError *error)
//	{
//		if(error == nil)
//		{
//			NSDictionary *responseDictionary = @{@"s": @YES,
//												 @"m": @"",
//												 @"d": result };
//			if (responseCallback) responseCallback(responseDictionary);
//		}
//		else
//		{
//			NSDictionary *responseDictionary = @{@"s": @NO,
//												 @"m": @"",
//												 @"d": @""};
//			if (responseCallback) responseCallback(responseDictionary);
//		}
//	}];
}



//- (void)_sendMessageToWebview:(MZMessage * )message; {
//	
//	//NSDictionary *messageDictionary = [message toDictionary];
//	NSDictionary *messageDictionary = @{@"s": @YES,
//										 @"m": @"",
//										 @"d": message};
//	// If the widget view loaded and the bridge is ready the message is sent directly to the bridge
//	if (self.javascriptBridge)
//	{
//		[self.javascriptBridge send:messageDictionary responseCallback:self.nativeResponseCallback];
//		return;
//	}
//	// Otherwise messages that arrive before the bridge is ready are stored in the queue for later processing.
//	NSMutableDictionary *storedSignalMessage = [NSMutableDictionary new];
//	storedSignalMessage[@"message"] = messageDictionary;
//	if (self.nativeResponseAction)
//	{
//		storedSignalMessage[@"responseCallback"] = [self.nativeResponseCallback copy];
//	}
//	if (self.parentChannelSignalQueue)
//	{
//		[self.parentChannelSignalQueue addObject:storedSignalMessage];
//		return;
//	}
//}

- (void) _sendComponentMessage:(NSDictionary *)message WithCallback:(WVJBResponseCallback)responseCallback {
    if (_nativeComponents)
	{
		if (responseCallback) responseCallback(@{@"s": @YES,
												 @"m": @"",
												 @"d": message[@"d"]});
//												@{@"s": @NO,
//												  @"m": NSLocalizedString(@"mobile_background_audio_stream_error", @""),
//												  @"d": message[@"d"]});
//  

		
		if ([self.delegate respondsToSelector:@selector(htmlViewController:didReceiveComponentAction:withMessage:)])
		{
			[self.delegate htmlViewController:self didReceiveComponentAction:message[@"d"][@"type"] withMessage:message[@"d"]];
		}
    }
}

#pragma mark - Webview Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
    
    if ([self.delegate respondsToSelector:@selector(htmlViewControllerDidStartLoad:)]) {
        [self.delegate htmlViewControllerDidStartLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(htmlViewController:didFailLoadWithError:)]) {
        [self.delegate htmlViewController:self didFailLoadWithError:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    __typeof__(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.5 delay:1
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
     UIViewAnimationCurveEaseIn
                     animations:^{
                         [weakSelf.activityIndicator stopAnimating];
                     } completion:^(BOOL finished) {
                         
                     }];
    if ([self.delegate  respondsToSelector:@selector(htmlViewControllerDidFinishLoad:)]) {
        [self.delegate htmlViewControllerDidFinishLoad:self];
    }
}

/// This selector is called when something is loaded in our webview
/// By something I don't mean anything but just "some" :
///  - main html document
///  - sub iframes document

// But all images, xmlhttprequest, css, ... files/requests doesn't generate such events :/
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)_unsubscribeSubChannels
{
	[MZMQTTWebviewMessageHelper unsubscribeAll];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(htmlViewController:didTapAtLocation:)]) {
        [self.delegate htmlViewController:self didTapAtLocation:[sender locationInView:self.view]];
    }
}

@end
