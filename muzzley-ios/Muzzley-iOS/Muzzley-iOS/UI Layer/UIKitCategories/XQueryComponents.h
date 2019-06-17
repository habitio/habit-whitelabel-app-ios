//
//  XQueryComponents.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 21/02/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XQueryComponents)
- (NSString *)stringByDecodingURLFormat;
- (NSString *)stringByEncodingURLFormat;
- (NSMutableDictionary *)dictionaryFromQueryComponents;
@end

@interface NSURL (XQueryComponents)
- (NSMutableDictionary *)queryComponents;
@end

@interface NSDictionary (XQueryComponents)
- (NSString *)stringFromQueryComponents;
@end
