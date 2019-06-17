//
//  MZAdWebview.h
//  MuzzleyKit
//
//  Created by Hugo Sousa on 11/02/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MZAdViewGravityTop      = 1,
    MZAdViewGravityCenter   = 2,
    MZAdViewGravityBottom   = 3
} MZAdViewGravity;

@interface MZAdViewController : UIViewController

- (void)showAdWithHTMLString:(NSString *)htmlString
                   ratioSize:(CGSize)ratioSize
                     gravity:(MZAdViewGravity)gravity
                    duration:(NSTimeInterval)duration;

- (void)showAdWithURL:(NSURL *)url
            ratioSize:(CGSize)ratioSize
              gravity:(MZAdViewGravity)gravity
             duration:(NSTimeInterval)duration;

@end
