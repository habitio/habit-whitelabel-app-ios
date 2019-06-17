//
//  LabelCollectionViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 28/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionViewCell.h"

@interface MZCollectionViewCellLabelViewModel : NSObject
@property (nonatomic, copy) NSAttributedString *attributedText;
@end

@interface MZCollectionViewCellLabel : MZCollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *label;
@end
