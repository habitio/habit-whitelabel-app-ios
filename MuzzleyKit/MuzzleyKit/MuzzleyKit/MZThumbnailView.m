//
//  MZThumbnailView.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 21/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZThumbnailView.h"

#import <QuartzCore/QuartzCore.h>

@interface MZThumbnailView()

@property (nonatomic, strong, readwrite) UIView *highlightView;
@property (nonatomic, strong, readwrite) UIImageView *checkImageView;
@property (nonatomic, strong, readwrite) UIImageView *mediaTypeImageInternalView;
@property (nonatomic, strong, readwrite) UIImageView *mediaTypeVideoInternalView;

@end

@implementation MZThumbnailView

- (void)dealloc
{
    self.highlightView = nil;
    self.mediaTypeImageInternalView = nil;
    self.mediaTypeVideoInternalView = nil;
    self.checkImageView = nil;
    
    self.state = 0;
    self.type = 0;
    
    self.delegate = nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
      
        self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
        self.highlightView.backgroundColor = [UIColor blackColor];
        [self addSubview: self.highlightView];
        
        [self initSubComponents];
        
    }
    return self;
}

-(id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
       
        self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
        self.highlightView.backgroundColor = [UIColor blackColor];
        [self addSubview: self.highlightView];
        
        [self initSubComponents];
    
    }
    return self;
}

-(id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        
        self.highlightView = nil;
        
        [self initSubComponents];
      
    }
    return self;
}

- (void)initSubComponents
{
    
    /// selection component
    self.checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assetsPicker_check"]];
    
    self.state = MZThumbnailViewStateDeselected;
    self.highlightView.alpha = 0;
    self.checkImageView.hidden = YES;
    [self addSubview: self.checkImageView];
    
    /// media type component
    self.mediaTypeImageInternalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assetsPicker_icon_image"]];
    self.mediaTypeVideoInternalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assetsPicker_icon_video"]];
    
    self.mediaTypeImageInternalView.hidden = YES;
    self.mediaTypeVideoInternalView.hidden = YES;
    
    [self addSubview: self.mediaTypeImageInternalView];
    [self addSubview: self.mediaTypeVideoInternalView];
    
    
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowOpacity = 0.5;

    //** self.layer.shadowPath = [UIBezierPath bezierPathWithRect: self.bounds].CGPath;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.checkImageView.center = CGPointMake(self.bounds.size.width - self.checkImageView.frame.size.width *0.5 - 2,
                                             self.bounds.size.height - self.checkImageView.frame.size.height *0.5 - 2);
    
    self.mediaTypeImageInternalView.center = CGPointMake(self.mediaTypeImageInternalView.center.x +2,
                                                         self.mediaTypeImageInternalView.center.y +2);
    
    self.mediaTypeVideoInternalView.center = self.mediaTypeImageInternalView.center;
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect: self.bounds].CGPath;
}

- (void)reset
{
    self.userInteractionEnabled = NO;
    self.mediaTypeImageInternalView.hidden = YES;
    self.mediaTypeVideoInternalView.hidden = YES;
    [self setSelected:NO animated:NO];
}

#pragma mark -
#pragma mark Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.highlightView.alpha = 0.35;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.state == MZThumbnailViewStateDeselected) {
        
        [self setSelected:YES animated:NO];
        
    } else if (self.state == MZThumbnailViewStateSelected) {
        
        [self setSelected:NO animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(thumbnail:didChangeState:)]) {
             
        [self.delegate thumbnail:self didChangeState:self.state];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.state == MZThumbnailViewStateDeselected) {
        
        //[self setState:MZThumbnailViewStateDeselected];
        [self setSelected:NO animated:YES];
        
    } else if (self.state == MZThumbnailViewStateSelected) {
        
        //[self setState:MZThumbnailViewStateSelected];
        [self setSelected:YES animated:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    if (selected) {
        
        self.state = MZThumbnailViewStateSelected;
        self.checkImageView.hidden = NO;
        
        if (animated) {
            [UIView animateWithDuration:0.15 animations:^{
                self.highlightView.alpha = 0.35;
            }];
        } else {
            self.highlightView.alpha = 0.35;
        }
    } else {
    
        self.state = MZThumbnailViewStateDeselected;
        self.checkImageView.hidden = YES;
        
        if(animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.highlightView.alpha = 0;
            }];
        } else {
            self.highlightView.alpha = 0;
        }
    }
}

- (void)setType:(MZThumbnailViewType)type
{
    _type = type;
    
    if (_type == MZThumbnailViewTypeImage) {
        
        self.mediaTypeImageInternalView.hidden = NO;
        self.mediaTypeVideoInternalView.hidden = YES;
        
    } else if(self.type == MZThumbnailViewTypeVideo){
        
        self.mediaTypeImageInternalView.hidden = YES;
        self.mediaTypeVideoInternalView.hidden = NO;

    }
}


@end
