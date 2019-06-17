//
//  WebViewJavascriptBridge.m
//  ExampleApp-iOS
//
//  Created by Filipe Pinheiro on 6/14/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "WebViewJavascriptBridge.h"

#import <Foundation/Foundation.h>
@import JavaScriptCore;


#if __has_feature(objc_arc_weak)
    #define WVJB_WEAK __weak
#else
    #define WVJB_WEAK __unsafe_unretained
#endif


@implementation WebViewJavascriptBridge {
    WVJB_WEAK WVJB_WEBVIEW_TYPE* _webView;
    WVJB_WEAK id _webViewDelegate;
    NSMutableArray* _startupMessageQueue;
    NSMutableDictionary* _responseCallbacks;
    NSMutableDictionary* _messageHandlers;
    long _uniqueId;
    WVJBHandler _messageHandler;
    
#if defined WVJB_PLATFORM_IOS
    NSUInteger _numRequestsLoading;
#endif
}

/* API
 *****/

static bool logging = false;
+ (void)enableLogging { logging = true; }

+ (instancetype)bridgeForWebView:(WVJB_WEBVIEW_TYPE*)webView handler:(WVJBHandler)handler {
    return [self bridgeForWebView:webView
                  webViewDelegate:nil
                          options:nil
                          handler:handler];
}

+ (instancetype)bridgeForWebView:(WVJB_WEBVIEW_TYPE*)webView
                 webViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE*)webViewDelegate
                         options:(NSDictionary *)options
                         handler:(WVJBHandler)messageHandler {

    WebViewJavascriptBridge* bridge = [[WebViewJavascriptBridge alloc] init];
    [bridge _platformSpecificSetup:webView
                   webViewDelegate:webViewDelegate
                           options:options
                           handler:messageHandler];
    [bridge reset];
    return bridge;
}

- (void)send:(NSDictionary *)data {
    [self send:data responseCallback:nil];
}

- (void)send:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self _sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _messageHandlers[handlerName] = [handler copy];
}

- (void)reset {
    _startupMessageQueue = [NSMutableArray array];
    _responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

/* Platform agnostic internals
 *****************************/

- (void)dealloc {
    [self _platformSpecificDealloc];
    
    _webView = nil;
    _webViewDelegate = nil;
    _startupMessageQueue = nil;
    _responseCallbacks = nil;
    _messageHandlers = nil;
    _messageHandler = nil;
    _options = nil;
}

- (void)_sendData:(NSDictionary *)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithObject:data forKey:@"data"];
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        _responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self _queueMessage:message];
}

- (void)_queueMessage:(NSDictionary *)message {
    if (_startupMessageQueue) {
        [_startupMessageQueue addObject:message];
    } else {
        [self _dispatchMessage:message];
    }
}

- (NSString *)_stringJSONFromDictionary:(NSDictionary *)dictionary
{
    NSString *messageJSON = [self _serializeMessage:dictionary];
    
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    
    return messageJSON;
}
- (void)_dispatchMessage:(NSDictionary *)message {
    
    NSString *messageJSON = [self _serializeMessage:message];
    [self _log:@"sending" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];

    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [_webView stringByEvaluatingJavaScriptFromString:javascriptCommand];
    } else {
        __strong WVJB_WEBVIEW_TYPE* strongWebView = _webView;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [strongWebView stringByEvaluatingJavaScriptFromString:javascriptCommand];
        });
    }
}

- (void)_flushMessageQueue
{
    NSString *messageQueueString = [_webView stringByEvaluatingJavaScriptFromString:@"WebViewJavascriptBridge._fetchQueue();"];
    
    NSArray* messages = [messageQueueString componentsSeparatedByString:kMessageSeparator];
    for (NSString *messageJSON in messages) {
        [self _log:@"receivd" json:messageJSON];
        
        NSDictionary* message = [self _deserializeMessageJSON:messageJSON];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
            if (responseCallback) {
                responseCallback(message[@"responseData"]);
            }
            [_responseCallbacks removeObjectForKey:responseId];
            
        } else {
            WVJBResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    if (!responseData) {
                        return;
                    }
                    NSDictionary* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self _queueMessage:msg];
                };
            } /*else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }*/
            
            WVJBHandler handler;
            if (message[@"handlerName"])
			{
                handler = _messageHandlers[message[@"handlerName"]];
                if (!handler) {
                    DLog(@"WVJB Warning: No handler for %@", message[@"handlerName"]);
                    return responseCallback(@{});
                }
            }
			else
			{
                handler = _messageHandler;
            }
            
            @try
			{
                NSDictionary* data = message[@"data"];
                if (!data || ((id)data) == [NSNull null]) { data = [NSDictionary dictionary]; }
                handler(data, responseCallback);
            }
            @catch (NSException *exception) {
                DLog(@"WebViewJavascriptBridge: WARNING: objc handler threw. %@ %@", message, exception);
            }
        }
    }
}

- (NSString *)_serializeMessage:(NSDictionary *)message {
#if defined _JSONKIT_H_
    return [message JSONString];
#else
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
#endif
}

- (NSDictionary *)_deserializeMessageJSON:(NSString *)messageJSON
{
#if defined _JSONKIT_H_
    return [messageJSON objectFromJSONString];
#else
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
#endif
}

- (void)_log:(NSString *)action json:(NSString *)json
{
    if (!logging) { return; }
    if (json.length > 500) {
        DLog(@"WVJB %@: %@", action, [[json substringToIndex:500] stringByAppendingString:@" [...]"]);
    } else {
        DLog(@"WVJB %@: %@", action, json);
    }
}



/* Platform specific internals: OSX
 **********************************/
#if defined WVJB_PLATFORM_OSX

- (void) _platformSpecificSetup:(WVJB_WEBVIEW_TYPE*)webView webViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE*)webViewDelegate handler:(WVJBHandler)messageHandler {
    _messageHandler = messageHandler;
    _webView = webView;
    _webViewDelegate = webViewDelegate;
    _messageHandlers = [NSMutableDictionary dictionary];
    
    _webView.frameLoadDelegate = self;
    _webView.resourceLoadDelegate = self;
    _webView.policyDelegate = self;
}

- (void) _platformSpecificDealloc {
    _webView.frameLoadDelegate = nil;
    _webView.resourceLoadDelegate = nil;
    _webView.policyDelegate = nil;
}

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    if (webView != _webView) { return; }
    
    if (![[webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"]) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        
        NSString *js = [NSString stringWithContentsOfFile:filePath
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
        
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    if (_startupMessageQueue) {
        for (id queuedMessage in _startupMessageQueue) {
            [self _dispatchMessage:queuedMessage];
        }
        _startupMessageQueue = nil;
    }
    
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)])
	{
        [_webViewDelegate webView:webView didFinishLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (webView != _webView) { return; }
    
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:forFrame:)])
	{
        [_webViewDelegate webView:webView didFailLoadWithError:error forFrame:frame];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if (webView != _webView) { return; }
    
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:kCustomProtocolScheme]) {
        if ([[url host] isEqualToString:kQueueHasMessage]) {
            [self _flushMessageQueue];
        } else {
            DLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
        }
        [listener ignore];
    } else if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)]) {
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    } else {
        [listener use];
    }
}

- (void)webView:(WebView *)webView didCommitLoadForFrame:(WebFrame *)frame {
    if (webView != _webView) { return; }
    
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:didCommitLoadForFrame:)]) {
        [_webViewDelegate webView:webView didCommitLoadForFrame:frame];
    }
}

- (NSURLRequest *)webView:(WebView *)webView resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    if (webView != _webView) { return request; }
    
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)])
	{
        return [_webViewDelegate webView:webView resource:identifier willSendRequest:request redirectResponse:redirectResponse fromDataSource:dataSource];
    }
    
    return request;
}



/* Platform specific internals: OSX
 **********************************/
#elif defined WVJB_PLATFORM_IOS

- (void) _platformSpecificSetup:(WVJB_WEBVIEW_TYPE*)webView
                webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate
                        options:(NSDictionary *)options
                        handler:(WVJBHandler)messageHandler {
    _messageHandler = messageHandler;
    _webView = webView;
    _webViewDelegate = webViewDelegate;
    _messageHandlers = [NSMutableDictionary dictionary];
    _webView.delegate = self;
    _options = options;
    
    // NOTE: Uncomment to see webview page console logs on xcode log console
    //    JSContext *ctx = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //    ctx[@"console"][@"log"] = ^(JSValue * msg) {
    //        NSLog(@"JS_LOG: %@", msg);
    //    };

}

- (void) _platformSpecificDealloc {
    _webView.delegate = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView != _webView) { return; }
    
    _numRequestsLoading--;
    
    if (_numRequestsLoading == 0 && ![[webView stringByEvaluatingJavaScriptFromString:@"typeof WebViewJavascriptBridge == 'object'"] isEqualToString:@"true"])
	{
        
        NSString *injectOptions = @"";
        if (![_options isKindOfClass:[NSDictionary class]]) {
            injectOptions = @"var options;";
        
        } else {
            NSString *options = [self _stringJSONFromDictionary:_options];
            injectOptions = [NSString stringWithFormat:@"var options = '%@';", options];
        }
        
        
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSString *newJS = [injectOptions stringByAppendingString:js];
        
        [webView stringByEvaluatingJavaScriptFromString:newJS];
    }
    
    if (_startupMessageQueue)
	{
        for (id queuedMessage in _startupMessageQueue)
		{
            [self _dispatchMessage:queuedMessage];
        }
        _startupMessageQueue = nil;
    }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [strongDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) { return; }
    
    _numRequestsLoading--;
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [strongDelegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (webView != _webView) { return YES; }
    NSURL *url = [request URL];
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if ([[url scheme] isEqualToString:kCustomProtocolScheme])
	{
        if ([[url host] isEqualToString:kQueueHasMessage])
		{
            [self _flushMessageQueue];
        } else {
            DLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
        }
		
        return NO;
    }
	else if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
	{
        return [strongDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
	else
	{
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (webView != _webView) { return; }
    
    _numRequestsLoading++;
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
	{
        [strongDelegate webViewDidStartLoad:webView];
    }
}

#endif

@end
