//
//  NSDictionary+JSON.h
//  Moved from muzzley-sdk-ios
//
//  Created by Hugo Sousa on 20/12/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (NSDictionary *)dictionaryFromContentsOfJSONString:(NSString *)jsonString;
+ (NSDictionary *)dictionaryFromContentsOfJSONData:(NSData *)jsonData;
- (NSData *)toJSONData;
@end
