//
//  MZResponseMessage.m
//  Moved from old muzzley-sdk-ios
//
//  Created by Hugo Sousa on 14/10/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

//#import "MZResponseMessage.h"

#import "MZResponseMessage_Private.h"

@interface MZResponseMessage ()

@property(nonatomic, strong, readwrite) id data;
@property(nonatomic, copy, readwrite) NSString *descriptionString;
@property(nonatomic, assign, readwrite) BOOL success;
@end

@implementation MZResponseMessage

+ (MZResponseMessage *)responseWithHeader:(NSMutableDictionary *)header
                                     data:(id)data
                              description:(NSString *)description
                                  success:(BOOL)success;
{
    MZResponseMessage *message = [[MZResponseMessage alloc] initWithChannelId:@"" data:data description:description success:success];
    message.header = header;
    
    return message;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.header = [NSMutableDictionary new];
        self.data = nil;
        self.descriptionString = @"";
        self.success = NO;
    }
    return self;
}

- (instancetype)initWithChannelId:(NSString *)channelId data:(id)data description:(NSString *)description success:(BOOL)success
{
    if (self = [super init]) {
        
        self.header = [NSMutableDictionary new];
        self.data = data;
        self.descriptionString = description;
        self.success = success;
        
        self.data = data;
        
        if (![self.descriptionString isKindOfClass:[NSString class]]) {
            self.descriptionString = @"";
        }
    }
    return self;
}

//- (NSData *)toJSONData
//{
//    NSMutableDictionary *messageDictionary = [NSMutableDictionary new];
//    [messageDictionary setObject:self.header forKey:@"h"];
//    
//    if (self.data) {
//        [messageDictionary setObject:self.data forKey:@"d"];
//    }
//    
//    if ([self.descriptionString isKindOfClass:[NSString class]]) {
//        [messageDictionary setObject:self.descriptionString forKey:@"m"];
//    }
//    [messageDictionary setObject:[NSNumber numberWithBool:self.success] forKey:@"s"];
//    
//    return [messageDictionary toJSONData];
//}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *messageDictionary = [NSMutableDictionary new];
    
    [messageDictionary setObject:self.header forKey:@"h"];
    [messageDictionary setObject:[NSNumber numberWithBool:self.success] forKey:@"s"];
    
    if ([self.descriptionString isKindOfClass:[NSString class]]) {
        [messageDictionary setObject:self.descriptionString forKey:@"m"];
    }
    if (self.data) {
        [messageDictionary setObject:self.data forKey:@"d"];
    }
    return messageDictionary;
}

- (void)setHeader:(NSMutableDictionary *)header
{
    _header = header;
}

@end
