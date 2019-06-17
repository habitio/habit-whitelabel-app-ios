//
//  MZCollectionItemLabel.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 17/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZCollectionItemLabel.h"

@implementation MZCollectionItemLabel

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse
{
    self.label.text = @"";
    [self.label setHighlighted:NO];
}

- (void)setStateSelected:(BOOL)selected animated:(BOOL)animated
{
    // Highlight the label text color
    [self.label setHighlighted:selected];
}

@end
