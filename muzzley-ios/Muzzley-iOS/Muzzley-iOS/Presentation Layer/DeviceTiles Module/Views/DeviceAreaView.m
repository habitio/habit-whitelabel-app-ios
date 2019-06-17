//
//  DeviceCardSectionHeader.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "DeviceAreaView.h"
@interface DeviceAreaView ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation DeviceAreaView

- (void)awakeFromNib {
    self.titleLabel.text = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    self.titleLabel.text = @"";
}

- (void)setModel:(MZTileAreaViewModel *)model {
    NSAssert([model isKindOfClass:[MZTileAreaViewModel class]], @"Must use %@ with %@", NSStringFromClass([MZTileAreaViewModel class]), NSStringFromClass([self class]));
    self.titleLabel.text = model.title;
}
@end
