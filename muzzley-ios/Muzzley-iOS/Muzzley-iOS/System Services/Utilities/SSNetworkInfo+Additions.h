//
//  SSNetworkInfo+Additions.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "SSNetworkInfo.h"

@interface SSNetworkInfo (Additions)

// Transform a Netmask Integer address representation into a bitmask, that is, the number of bits at 1.
// Ex: An integer representing 255.255.255.0 becomes 24.
+ (NSString *)bitmaskFromNetmaskAddress:(NSString *)netmaskAdress;

@end

