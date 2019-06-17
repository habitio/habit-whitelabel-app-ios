//
//  MZUDPClient.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZUDPClient.h"

#import "GCDAsyncUdpSocket.h"

@interface MZUDPClient () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *ssdpSocket;
//@property (nonatomic, strong, readwrite) NSURL *multicastGroupURL;
@property (nonatomic, copy, readwrite) NSString *discoverProtocolString;

@property (nonatomic, strong) NSMutableArray *udpResponses;
@property (nonatomic, strong) NSTimer *requestTimer;
@property (nonatomic, assign) BOOL expectResponse;

@end

@implementation MZUDPClient

- (void)dealloc
{
    [_requestTimer invalidate];
    _requestTimer = nil;
    _onCompletion = nil;
    _ssdpSocket.delegate = nil;
    [_ssdpSocket close];
    _ssdpSocket = nil;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    _udpResponses = [NSMutableArray new];
    return self;
}

- (void)sendData:(id)dataObject toHost:(NSString *)host port:(NSUInteger)port withTimeout:(NSTimeInterval)milliseconds expectResponse:(BOOL)expectResponse
{
    [self _invalidateRequestTimer];
    
    self.ssdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *socketError = nil;
    
    if (![self.ssdpSocket enableBroadcast:YES error:&socketError]){
        DLog(@"Failed enabling broadcast: %@", [socketError localizedDescription]);
        if (self.onCompletion) {
            self.onCompletion(nil, socketError);
            self.onCompletion = nil;
            return;
        }
    }
    
    [self.ssdpSocket beginReceiving:&socketError];
    
    self.expectResponse = expectResponse;
    NSUInteger timeout = 5.0;
    if (self.expectResponse) { timeout = milliseconds / 1000; }
    
    self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                         target:self
                                                       selector:@selector(_completeSearch:)
                                                       userInfo:self
                                                        repeats:NO];
    
    NSData *data = dataObject;
    if ([dataObject isKindOfClass:[NSString class]])
        data = [dataObject dataUsingEncoding:NSUTF8StringEncoding];
        
    [self.ssdpSocket sendData:data toHost:host port:port withTimeout:-1 tag:1];
}

- (void)stopRequestTimeout
{
    [self _invalidateRequestTimer];
}

#pragma mark - Udp Socket Delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    if (!self.expectResponse) {
        
        [self.requestTimer invalidate];
        [self.udpResponses addObject:@""];
        
        [self _completeSearch:self.requestTimer];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [self.requestTimer invalidate];    
    [self _completeSearch:self.requestTimer];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (self.expectResponse) {

        //removed this so this decision is from the receiver
        //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        [self.udpResponses addObject:data];
    }
}

#pragma mark - Private Methods
- (void)_completeSearch:(NSTimer *)t
{
    [self.ssdpSocket close];
    self.ssdpSocket = nil;
    
    NSArray *udpResponses = [NSArray arrayWithArray:self.udpResponses];
    
    if (self.onCompletion) {
        self.onCompletion(udpResponses,nil);
        self.onCompletion = nil;
        return;
    }
}

- (void)_invalidateRequestTimer
{
    [self.requestTimer invalidate];
    self.requestTimer = nil;
    
    self.expectResponse = NO;
    
    [self.ssdpSocket close];
    self.ssdpSocket = nil;
    self.udpResponses = [NSMutableArray new];
}

@end
