//
//  NSAttributedString+Additions.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Additions)

// Provide a list of strings followed by attributes and returns a NSAttributedString for their combination.
//
//  Example:
//  [NSAttributedString attributedStringWithStringsAndAttributes:@"test",attributes,@"test2",attributes2,nil];
//
+ (NSAttributedString *)attributedStringWithStringsAndAttributes:(id)firstString, ... NS_REQUIRES_NIL_TERMINATION;
@end