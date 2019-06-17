//
//  MZBezierDrawView.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 15/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZBezierDrawView;

@protocol MZBezierDrawDelegate <NSObject>

@optional
/** Sent to receiver after touch began. */
- (void) bezierDraw:(MZBezierDrawView *)drawpad touchBegan:(CGPoint)touch;
- (void) bezierDraw:(MZBezierDrawView *)drawpad touchMoved:(CGPoint)touch;
- (void) bezierDraw:(MZBezierDrawView *)drawpad touchEnded:(CGPoint)touch;

@end

@interface MZBezierDrawView : UIView

/** The receiver's delegate or 'nil' if it doesn't have a delegate. */
@property (nonatomic, weak) id <MZBezierDrawDelegate> delegate;
@property (nonatomic, assign) float pathHistoryDecay;

- (void)clean;

@end
