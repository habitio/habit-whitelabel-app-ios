//
//  MZPhotoAssetCell.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 21/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZPhotoAssetCell.h"
#import "MZThumbnailView.h"

#import <QuartzCore/QuartzCore.h>

@interface MZPhotoAssetCell ()

@property (nonatomic, strong, readwrite) IBOutlet MZThumbnailView *thumb1;
@property (nonatomic, strong, readwrite) IBOutlet MZThumbnailView *thumb2;
@property (nonatomic, strong, readwrite) IBOutlet MZThumbnailView *thumb3;

@end

@implementation MZPhotoAssetCell

@synthesize thumb1;
@synthesize thumb2;
@synthesize thumb3;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.thumb1.delegate = self;
    self.thumb2.delegate = self;
    self.thumb3.delegate = self;

}

- (void)clearSelection {
    
    [self.thumb1 setSelected:NO animated:NO];
    [self.thumb2 setSelected:NO animated:NO];
    [self.thumb3 setSelected:NO animated:NO];
}

- (void)resetThumbnails {
    
    self.thumb1.hidden = YES;
    self.thumb2.hidden = YES;
    self.thumb3.hidden = YES;
    
    [self.thumb1 reset];
    [self.thumb2 reset];
    [self.thumb3 reset];

}

-(void)thumbnail:(MZThumbnailView *)thumbnailView didChangeState:(MZThumbnailViewState)state
{
    NSUInteger selectedPhotoIndex = 0;
    
    if (thumbnailView == self.thumb1) {
        selectedPhotoIndex = 0;
    } else if (thumbnailView == self.thumb2) {
        selectedPhotoIndex = 1;
    } else if (thumbnailView == self.thumb3) {
        selectedPhotoIndex = 2;
    }
    
    if ([self.selectionDelegate respondsToSelector:@selector(photoAssetCell:selectedPhotoAtIndex:didChangedState:)]) {
        
        [self.selectionDelegate photoAssetCell:self
                          selectedPhotoAtIndex:selectedPhotoIndex
                               didChangedState:state];
    }
}


@end
