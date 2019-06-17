//
//  MZUDPClient.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

typedef void (^MZUDPClientResponseCallback) (NSArray *responses, NSError *error);

@interface MZUDPClient : NSObject

@property (nonatomic, copy) MZUDPClientResponseCallback onCompletion;

- (void)sendData:(id)dataObject toHost:(NSString *)host port:(NSUInteger)port withTimeout:(NSTimeInterval)milliseconds expectResponse:(BOOL)expectResponse;

- (void)stopRequestTimeout;

@end
