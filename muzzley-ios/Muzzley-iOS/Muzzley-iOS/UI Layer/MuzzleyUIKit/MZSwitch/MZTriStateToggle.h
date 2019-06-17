//
//  MZSwitch.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MZTriStateToggleState) {
    MZTriStateToggleStateUnknown,
    MZTriStateToggleStateOn,
    MZTriStateToggleStateOff
};


@protocol MZTriStateToggleDelegate;

IB_DESIGNABLE
@interface MZTriStateToggle : UIView
@property (nonatomic) IBInspectable UIColor *unknownTintColor;
@property (nonatomic) IBInspectable UIColor *onTintColor;
@property (nonatomic) IBInspectable UIColor *offTintColor;
@property (nonatomic) IBInspectable UIColor *thumbTintColor;
@property (nonatomic) IBInspectable UIImage *thumbImage;

@property (nonatomic, assign, readonly) MZTriStateToggleState state;

// does not send delegate events
- (void)setState:(MZTriStateToggleState)state animated:(BOOL)animated;

@property (nonatomic, weak) id<MZTriStateToggleDelegate> delegate;
@end

@protocol MZTriStateToggleDelegate <NSObject>
- (void)toggle:(MZTriStateToggle *)toggle didChangetoState:(MZTriStateToggleState)state;
@end