//
//  MZTableViewCellImg.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 9/12/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "SSBaseTableCell.h"

@interface MZTableViewCellImg : SSBaseTableCell

@property (nonatomic, weak) IBOutlet UIImageView *centralImageView;

- (void)setPlaceholderBackgroundColor:(UIColor *)color;
- (void)setupWithImageURL:(NSURL *)imageUrl;

@end
