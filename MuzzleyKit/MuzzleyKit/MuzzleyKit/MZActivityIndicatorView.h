//
//  MZActivityIndicatorView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 15/05/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZActivityIndicatorView : UIImageView

- (void) startRotating;
- (void) stopRotating;
- (void) tintToColor:(UIColor*)color;

@end
