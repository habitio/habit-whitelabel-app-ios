//
//  WebViewJavascriptBridge.h
//  ExampleApp-iOS
//
//  Created by Filipe Pinheiro on 6/14/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMessageSeparator     @"__WVJB_MESSAGE_SEPERATOR__"
#define kCustomProtocolScheme @"wvjbscheme"
#define kQueueHasMessage      @"__WVJB_QUEUE_MESSAGE__"

#if defined __MAC_OS_X_VERSION_MAX_ALLOWED
    #import <WebKit/WebKit.h>
    #define WVJB_PLATFORM_OSX
    #define WVJB_WEBVIEW_TYPE WebView
    #define WVJB_WEBVIEW_DELEGATE_TYPE NSObject
#elif defined __IPHONE_OS_VERSION_MAX_ALLOWED
    #define WVJB_PLATFORM_IOS
    #define WVJB_WEBVIEW_TYPE UIWebView
    #define WVJB_WEBVIEW_DELEGATE_TYPE NSObject<UIWebViewDelegate>
#endif

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface WebViewJavascriptBridge : WVJB_WEBVIEW_DELEGATE_TYPE

@property (nonatomic, strong) NSDictionary *options;

+ (instancetype)bridgeForWebView:(WVJB_WEBVIEW_TYPE*)webView handler:(WVJBHandler)handler;
+ (instancetype)bridgeForWebView:(WVJB_WEBVIEW_TYPE*)webView webViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE*)webViewDelegate options:(NSDictionary *)options handler:(WVJBHandler)handler;
+ (void)enableLogging;

- (void)send:(id)message;
- (void)send:(id)message responseCallback:(WVJBResponseCallback)responseCallback;
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;

@end
