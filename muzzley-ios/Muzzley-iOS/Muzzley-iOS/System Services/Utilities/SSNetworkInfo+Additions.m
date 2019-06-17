//
//  SSNetworkInfo+Additions.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "SSNetworkInfo+Additions.h"
#include <arpa/inet.h>

@implementation SSNetworkInfo (Additions)

+ (NSString *)bitmaskFromNetmaskAddress:(NSString *)netmaskAdress
{
    @try {
        // Input validation
        if (![netmaskAdress isKindOfClass:[NSString class]]) {
            netmaskAdress = @"";
        }
        // Set up the variable
        struct in_addr sin_addr;
        
        const char *netmaskString = [netmaskAdress UTF8String];
        
        // Create a netmask from char
        NSUInteger success = inet_aton(netmaskString, &sin_addr);
        NSUInteger netmask = sin_addr.s_addr;
        
        // Not success
        if (success == 0) { return nil; }
        
        // Count the number of bits that are 1
        NSUInteger count = 0;
        while (netmask) {
            count += netmask & 0x1u;
            netmask >>= 1;
        }
        
        NSString *bitmaskString = [NSString stringWithFormat:@"%u", count];
        // Return successful
        return bitmaskString;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

@end

