//
//  MZComponent.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 23/07/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MZComponentActionType) {
    MZComponentActionTypeDisable  = 1,
    MZComponentActionTypeEnable   = 2,
    MZComponentActionTypeUpdate   = 3
};

@class MZMuzzleyChannel;
@class MZComponent;

@protocol MZComponentDelegate <NSObject>
@optional

@end

@interface MZComponent : NSObject

@property (nonatomic, weak) id <MZComponentDelegate> delegate;

@property (nonatomic, readonly, getter = isActive) BOOL active;
@property (nonatomic, weak) MZMuzzleyChannel *muzzleyChannel;

- (void)activate:(BOOL)yesOrNo;

- (void)configure:(NSDictionary *)parameters;

- (void)handleProtocolData:(NSDictionary *)protocolData;

@end
