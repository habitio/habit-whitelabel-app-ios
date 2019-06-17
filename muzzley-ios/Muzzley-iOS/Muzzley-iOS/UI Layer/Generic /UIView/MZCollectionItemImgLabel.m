//
//  MZCollectionItemImgLabel.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZCollectionItemImgLabel.h"

@interface  MZCollectionItemImgLabel ()

@property(nonatomic) CGSize initialSize;
@property(nonatomic) CGPoint initialCenter;
@property(nonatomic) CGFloat initialLabelFontSize;

@end

@implementation MZCollectionItemImgLabel

/*
- (void)awakeFromNib {
    // Initialization code
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5;
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.imageView.layer.shouldRasterize = YES;
    self.initialSize = self.imageView.frame.size;
    self.initialCenter = self.imageView.center;
    self.initialLabelFontSize = self.label.font.pointSize;
}*/

- (void)prepareForReuse
{
    self.label.text = @"";
    self.imageView.image = nil;
}
/*
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:COLLECTION_ITEM_ID_IMG_LABEL owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}*/

- (void)configureCell
{
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5;
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.imageView.layer.shouldRasterize = YES;
    self.initialSize = self.imageView.frame.size;
    self.initialCenter = self.imageView.center;
    self.initialLabelFontSize = self.label.font.pointSize;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (self.isSelected) {
        return;
    }
    
    CGFloat zoomHeight = 0.0;
    if (highlighted) { zoomHeight = _initialSize.height - 10; }
    else { zoomHeight = _initialSize.height; }
    
    __typeof__(self) __weak welf = self;
    void (^ChangeStateBlock)(void) = ^void(void) {
        welf.imageView.layer.cornerRadius = zoomHeight * 0.5;
        welf.imageView.bounds = CGRectMake(0, 0, zoomHeight, zoomHeight);
        welf.imageView.center = welf.initialCenter;
    };
    
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:0 animations:ChangeStateBlock completion:^(BOOL finished) {}];
}

- (void)setStateSelected:(BOOL)selected animated:(BOOL)animated
{
    // Highlight the label text color
    UIColor *textColor;

    if (selected) { textColor = [UIColor muzzleyRedColorWithAlpha:1.0]; }
    else { textColor = [UIColor muzzleyGray2ColorWithAlpha:1]; }
    
    self.label.textColor = textColor;
    
    // Zoom the Icon
    CGFloat zoomHeight = 0.0;
    if (selected) { zoomHeight = _initialSize.height + 10; }
    else { zoomHeight = _initialSize.height; }
    
    if (!animated) {
        self.imageView.layer.cornerRadius = zoomHeight * 0.5;
        self.imageView.bounds = CGRectMake(0, 0, zoomHeight, zoomHeight);
        self.imageView.center = self.initialCenter;
        return;
    }
    
    __typeof__(self) __weak welf = self;
    void (^ChangeStateBlock)(void) = ^void(void) {
        welf.imageView.layer.cornerRadius = zoomHeight * 0.5;
        welf.imageView.bounds = CGRectMake(0, 0, zoomHeight, zoomHeight);
        welf.imageView.center = welf.initialCenter;
    };
    [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.35
          initialSpringVelocity:0.35 options:nil animations:ChangeStateBlock completion:^(BOOL finished) {}];
}

@end
