//
//  UIDevice+ProcessInfoAdditions.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 2/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (SystemVersionAdditions)

- (BOOL)systemVersionEqualTo:(NSString *)version;
- (BOOL)systemVersionGreaterThan:(NSString *)version;
- (BOOL)systemVersionGreaterThanOrEqualTo:(NSString *)version;
- (BOOL)systemVersionLessThan:(NSString *)version;
- (BOOL)systemVersionLessThanOrEqualTo:(NSString *)version;

@end
