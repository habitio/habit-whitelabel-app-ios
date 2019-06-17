//
//  : MZChannelsTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZChannelsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *channelImageView;
@property (nonatomic, weak) IBOutlet UILabel *channelLabel;
@property (nonatomic, weak) IBOutlet UIImageView *channelSelectedImageView;
@end
