//
//  SpinnerController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/2/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

@interface SpinnerControl : UIControl

@property (nonatomic , weak) UIScrollView *scrollView;

- (BOOL)isSpinning;
- (void)startSpinning;
- (void)stopSpinning;
//- (void)rotate:(NSInteger)angleDegree;
- (void)handleScrollViewDraggingEnd;
@end
