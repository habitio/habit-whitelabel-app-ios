//
//  OngoingOperationView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/5/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OngoingOperationView : UIView

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
