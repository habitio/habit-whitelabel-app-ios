//
//  MZCollectionItemImgLabel.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/11/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "SSBaseCollectionCell.h"

@interface MZCollectionItemImgLabel : SSBaseCollectionCell

@property(nonatomic, weak) IBOutlet UILabel *label;
@property(nonatomic, weak) IBOutlet UIImageView *imageView;

- (void)setStateSelected:(BOOL)selected animated:(BOOL)animated;

@end
