//
//  MZProgressView.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 14/02/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface MZProgressView ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation MZProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        // clipsToBounds is important to stop the progressView from covering the original view and its round corners
        self.clipsToBounds = YES;
        
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:self.progressView];
    }
    
    return self;
}

- (void)setProgressColor:(UIColor *)theProgressColor {
    self.progressView.backgroundColor = theProgressColor;
    _progressColor = theProgressColor;
}

- (void)setTrackColor:(UIColor *)theTrackColor {
    self.backgroundColor = theTrackColor;
    _trackColor = theTrackColor;
}

- (void)setProgress:(CGFloat)theProgress {
    _progress = theProgress;
    CGRect theFrame = self.progressView.frame;
    theFrame.size.width = self.frame.size.width * theProgress;
    self.progressView.frame = theFrame;
}

@end
