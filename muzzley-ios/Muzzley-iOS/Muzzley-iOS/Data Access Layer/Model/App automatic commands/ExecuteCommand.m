//
//  ExecuteCommand.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "ExecuteCommand.h"

#import "XQueryComponents.h"

@interface ExecuteCommand ()
@property (nonatomic, readwrite) NSDictionary *payload;
@end

@implementation ExecuteCommand

- (instancetype)initWithUrl:(NSURL *)url
{
    if (self = [super init]) {
        if (![url isKindOfClass:[NSURL class]]) return nil;
        if (![url.scheme isEqualToString:MUZZLEY_URL_COMMAND_ID]) return nil;
        if (![url.host isEqualToString:MUZZLEY_URL_COMMAND_EXECUTE_ID]) return nil;
        
        NSMutableDictionary *queryComponents = url.queryComponents;
        NSMutableArray *messageQueryComponent = [queryComponents objectForKey:@"message"];
        
        if (messageQueryComponent.count == 0) { return nil; }
        NSString *messageString = [messageQueryComponent objectAtIndex:0];
        
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[messageString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (!error && [result isKindOfClass:[NSDictionary class]]) {
            self.payload = result;
        } else {
            return nil;
        }
    }
    return self;
}

@end
