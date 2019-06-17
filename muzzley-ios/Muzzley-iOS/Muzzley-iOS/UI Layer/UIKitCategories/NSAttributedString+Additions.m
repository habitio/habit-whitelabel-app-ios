//
//  NSAttributedString+Additions.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "NSAttributedString+Additions.h"

@implementation NSAttributedString (Additions)

+ (NSAttributedString *)attributedStringWithStringsAndAttributes:(id)firstString, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    id param;
    NSDictionary* attributes;
    NSString* content = firstString;
    va_list argumentList;
    if (content)
    {
        va_start(argumentList, firstString);
        while ((param = va_arg(argumentList, id)) != nil)
        {
            if ([param isKindOfClass:[NSString class]])
            {
                content = param;
            }
            else if ([param isKindOfClass:[NSDictionary class]])
            {
                attributes = param;
            }
            
            if ([content isKindOfClass:[NSString class]] && [attributes isKindOfClass:[NSDictionary class]] )
            {
                NSAttributedString* str = [[NSAttributedString alloc] initWithString:content attributes:attributes];
                [string appendAttributedString:str];
                content = nil;
                attributes = nil;
            }
        }
        va_end(argumentList);
    }
    return [[NSAttributedString alloc] initWithAttributedString:string];
}
@end
