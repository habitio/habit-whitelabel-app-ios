//
//  MZPressGestureRecognizer.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 10/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZPressGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) CGPoint firstScreenLocation;
@property (nonatomic, assign) CGPoint lastScreenLocation;

@end
