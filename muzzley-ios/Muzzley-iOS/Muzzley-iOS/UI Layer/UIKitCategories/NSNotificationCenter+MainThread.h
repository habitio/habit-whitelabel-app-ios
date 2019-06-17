//
//  NSNotificationCenter+MainThread.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 10/6/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (MainThread)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject;
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
