//
//  DeviceCardCollectionViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 11/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewCell.h"
#import "MZTriStateToggle.h"

@class DeviceTileCell;

@protocol DeviceTileCellDelegate <MZCollectionViewCellDelegate>
@optional
- (void)deviceTileCellToggleDidChangeValue:(DeviceTileCell *)cell;
@end


@interface DeviceTileCell : MZCollectionViewCell

@property (nonatomic, weak) IBOutlet MZTriStateToggle *toggle;
@property (nonatomic, weak) id<DeviceTileCellDelegate> delegate;

@end

