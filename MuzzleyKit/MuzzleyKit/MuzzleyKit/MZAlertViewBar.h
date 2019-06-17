//
//  MZAlertViewBar.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 04/06/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum AlertBarType : NSUInteger {
    AlertBarTypeInfo = 0,
    AlertBarTypeWarning,
    AlertBarTypeError,
    AlertBarTypeBlocking,
} AlertBarType;

@interface MZAlertViewBar : UIControl

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, readonly) AlertBarType type;

@property(nonatomic, readonly, getter = isAlerting) BOOL alerting;

- (void)animateWithAlert:(NSString*)message type:(AlertBarType)type;
- (void)dismiss;
@end
