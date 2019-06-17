//
//  ChannelProfileTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZTableViewCellChannelProfile : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *channelProfileImageView;
@property (nonatomic, weak) IBOutlet UILabel *channelProfileLabel;
@property (nonatomic, weak) IBOutlet UIView *channelSelectionView;
@end
