//
//  LocalDiscoveryService.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 11/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZLocalDiscoveryService.h"

#import "AsyncUdpSocket.h"

NSString *const MULTICAST_GROUP_URL_STRING = @"http://239.255.255.250:1900";

@interface MZLocalDiscoveryService () <AsyncUdpSocketDelegate>

@property (nonatomic, strong) AsyncUdpSocket *ssdpSocket;
@property (nonatomic, strong, readwrite) NSURL *multicastGroupURL;
@property (nonatomic, copy, readwrite) NSString *discoverProtocolString;

@property (nonatomic, copy) MZLocalDiscoverySearchCallback localDiscoverySearchCallback;
@property (nonatomic, strong) NSMutableArray *localDeviceResponses;
@property (nonatomic, strong) NSTimer *localSearchTimer;

@end

@implementation MZLocalDiscoveryService

- (void)dealloc
{
    [self.localSearchTimer invalidate];
    self.localSearchTimer = nil;
    self.localDiscoverySearchCallback = nil;
    self.ssdpSocket.delegate = nil;
    [self.ssdpSocket close];
    self.ssdpSocket = nil;
    self.delegate = nil;
}

- (instancetype)initWithST:(NSString *)searchTarget mx:(NSString *)maximumTime
{
    self = [super init];
    if (!self) return nil;
    
    self.multicastGroupURL = [NSURL URLWithString:MULTICAST_GROUP_URL_STRING];
    self.discoverProtocolString =
     [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\nHOST: %@:%@\r\nST: %@\r\nMX: %@\r\nMAN: \"ssdp:discover\"\r\n\r\n",_multicastGroupURL.host, _multicastGroupURL.port, searchTarget, maximumTime];
    self.localDeviceResponses = [NSMutableArray new];
    
    return self;
}

- (void)startLocalDeviceSearchWithTimeout:(NSTimeInterval)timeout
{
    self.ssdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    
    NSError *socketError = nil;
    
    if (![self.ssdpSocket enableBroadcast:YES error:&socketError]){
        DLog(@"Failed enabling broadcast: %@", [socketError localizedDescription]);
        if (self.localDiscoverySearchCallback) {
            self.localDiscoverySearchCallback(nil, socketError);
            self.localDiscoverySearchCallback = nil;
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(localDiscoveryServiceDidFailSearchWithError:)]) {
            [self.delegate localDiscoveryServiceDidFailSearchWithError:socketError];
            return;
        }
    }
    
    if (![self.ssdpSocket bindToPort:0 error:&socketError]) {
        DLog(@"Failed binding socket: %@", [socketError localizedDescription]);
        if (self.localDiscoverySearchCallback) {
            self.localDiscoverySearchCallback(nil, socketError);
            self.localDiscoverySearchCallback = nil;
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(localDiscoveryServiceDidFailSearchWithError:)]) {
            [self.delegate localDiscoveryServiceDidFailSearchWithError:socketError];
            return;
        }
    }
    
    if (![self.ssdpSocket joinMulticastGroup:_multicastGroupURL.host error:&socketError]) {
        if (self.localDiscoverySearchCallback) {
            self.localDiscoverySearchCallback(nil, socketError);
            self.localDiscoverySearchCallback = nil;
            return;
        }
        
        DLog(@"Failed joining multicast group: %@", [socketError localizedDescription]);
        if ([self.delegate respondsToSelector:@selector(localDiscoveryServiceDidFailSearchWithError:)]) {
            [self.delegate localDiscoveryServiceDidFailSearchWithError:socketError];
            return;
        }
    }
    
    [self.ssdpSocket sendData:[_discoverProtocolString dataUsingEncoding:NSUTF8StringEncoding]
                       toHost:_multicastGroupURL.host
                         port:1900
                  withTimeout:-1
                          tag:1];
    
    [self.ssdpSocket receiveWithTimeout:-1 tag:1];
    
    self.localSearchTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                             target:self
                                                           selector:@selector(_completeSearch:)
                                                           userInfo:self
                                                            repeats:NO];
}

- (void)startLocalDeviceSearchWithTimeout:(NSTimeInterval)timeout
                                 callback:(MZLocalDiscoverySearchCallback)callback
{
    self.localDiscoverySearchCallback = callback;
    [self startLocalDeviceSearchWithTimeout:timeout];
}


- (void)stopLocalDeviceSearch
{
    [self _invalidateLocalSearchTimer];
}

#pragma mark - Udp Socket Delegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    DLog(@"%s %ld %@ %d",__FUNCTION__,tag,host,port);
    NSString *localDeviceResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    DLog(@"%@",localDeviceResponse);
    [self.localDeviceResponses addObject:localDeviceResponse];
    
    return NO;
}

#pragma mark - Private Methods
- (void)_completeSearch:(NSTimer *)t
{
    [self.ssdpSocket close];
    self.ssdpSocket = nil;
    
    NSArray *localDeviceResponses = [NSArray arrayWithArray:self.localDeviceResponses];
    
    if (self.localDiscoverySearchCallback) {
        self.localDiscoverySearchCallback(localDeviceResponses,nil);
        self.localDiscoverySearchCallback = nil;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(localDiscoveryServiceDidFinishSearchWithResult:)]) {
        [self.delegate localDiscoveryServiceDidFinishSearchWithResult:localDeviceResponses];
    }
}

- (void)_invalidateLocalSearchTimer
{
    [self.localSearchTimer invalidate];
    self.localSearchTimer = nil;
    self.localDiscoverySearchCallback = nil;
}

@end
