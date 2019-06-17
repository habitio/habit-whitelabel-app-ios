//
//  MZResponseMessage.h
//  Moved from old  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 14/10/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MZResponseBlock)( id data, NSString *description, BOOL success);

@interface MZResponseMessage : NSObject

/** The response message data.
 
 Response message data will be a NSDictionary.
 */
@property(nonatomic, strong, readonly) id data;

/** The response message description.
 */
@property(nonatomic, copy, readonly) NSString *descriptionString;

/** The response message success.
 */
@property(nonatomic, assign, readonly) BOOL success;

- (instancetype)initWithChannelId:(NSString *)channelId data:(id)data description:(NSString *)description success:(BOOL)success;

//- (NSData *)toJSONData;
- (NSDictionary *)toDictionary;

// Response Message Construction
+ (MZResponseMessage *)responseWithHeader:(NSMutableDictionary *)header
                                     data:(id)data
                              description:(NSString *)description
                                  success:(BOOL)success;
@end
