//
//  MZFiveStateToggle.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MZFiveStateToggleState) {
    MZFiveStateToggleStateUnknown,
    MZFiveStateToggleStateOn,
    MZFiveStateToggleStateOff
};


@protocol MZFiveStateToggleDelegate;

IB_DESIGNABLE
@interface MZFiveStateToggle : UIView
@property (nonatomic) IBInspectable UIColor *unknownTintColor;
@property (nonatomic) IBInspectable UIColor *onTintColor;
@property (nonatomic) IBInspectable UIColor *offTintColor;
@property (nonatomic) IBInspectable UIColor *thumbTintColor;
@property (nonatomic) IBInspectable UIImage *thumbImage;

@property (nonatomic) UIView *toggleBackground;
@property (nonatomic, assign, readonly) MZFiveStateToggleState state;
@property (nonatomic) MZFiveStateToggleState previousState;
@property (nonatomic) BOOL isLoading;

// does not send delegate events
- (void)setState:(MZFiveStateToggleState)state animated:(BOOL)animated;
- (void)setLoading:(BOOL)loading;

@property (nonatomic, weak) id<MZFiveStateToggleDelegate> delegate;
@end

@protocol MZFiveStateToggleDelegate <NSObject>
- (void)toggle:(MZFiveStateToggle *)toggle didChangetoState:(MZFiveStateToggleState)state;
@end