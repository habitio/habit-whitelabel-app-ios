//
//  MZImageViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/05/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"

#import <UIImageView+AFNetworking.h>
#import "MZActivityIndicatorView.h"

@interface MZImageViewController : MZWidget

/// UI Objects
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) IBOutlet MZActivityIndicatorView *activityIndicator;

@end
