//
//  MZTableViewCellPrivate.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewCell.h"

@interface MZTableViewCell ()

@property (assign, nonatomic, getter=isSizingCell) BOOL sizingCell;

/*!
 * Returns contentView's computed height based upon Auto Layout constraints if non-0. Otherwise, it
 * returns UITableViewAutomaticDimension (which, pre-OS8, when returned from UITableViewDelegate's
 * heightForRowAtIndexPath:, will size the cell at 44pts tall)
 *
 * @param width Width of the contentView to assume when determining height
 *
 * @result Height of cell calculated assuming its contentView is of the specified width
 */
- (CGFloat)heightForWidth:(CGFloat)width separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;

@end
