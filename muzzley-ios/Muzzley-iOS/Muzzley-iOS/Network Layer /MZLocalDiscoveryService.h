//
//  LocalDiscoveryService.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 11/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

extern NSString *const MULTICAST_GROUP_URL_STRING;

typedef void (^MZLocalDiscoverySearchCallback) (NSArray *localDeviceResponses, NSError *error);

@class MZLocalDiscoveryService;
@protocol MZLocalDiscoveryServiceDelegate <NSObject>

- (void)localDiscoveryServiceDidFinishSearchWithResult:(NSArray *)localDeviceResponses;
- (void)localDiscoveryServiceDidFailSearchWithError:(NSError *)error;

@end

@interface MZLocalDiscoveryService : NSObject

@property (nonatomic, weak) id<MZLocalDiscoveryServiceDelegate>delegate;

@property (nonatomic, strong, readonly) NSURL *multicastGroupURL;
@property (nonatomic, copy, readonly) NSString *discoverProtocolString;

- (instancetype)initWithST:(NSString *)searchTarget mx:(NSString *)maximumTime;

- (void)startLocalDeviceSearchWithTimeout:(NSTimeInterval)timeout;
- (void)startLocalDeviceSearchWithTimeout:(NSTimeInterval)timeout
                                 callback:(MZLocalDiscoverySearchCallback)callback;

- (void)stopLocalDeviceSearch;

@end
