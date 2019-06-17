//
//  MZCollectionItemLabel.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 17/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "SSBaseCollectionCell.h"

@interface MZCollectionItemLabel : SSBaseCollectionCell

@property(nonatomic, weak) IBOutlet UILabel *label;

- (void)setStateSelected:(BOOL)selected animated:(BOOL)animated;

@end
