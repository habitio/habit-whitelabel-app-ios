//
//  MZExpandableTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewCell.h"

@interface MZExpandableTableViewCell : MZTableViewCell

@property (weak, nonatomic, readonly) UIView *headerContentView;
@property (weak, nonatomic, readonly) UIView *expandableContentView;
/*!
 * Expand the hidden area of the cell.
 * When calling MZTableViewCell's @selector(heightForWidth:separatorStyle:)
 *
 * If not expanded returns headerContentView's computed height based upon Auto Layout constraints if non-0.
 * Otherwise, it returns UITableViewAutomaticDimension (which, pre-OS8, when returned from UITableViewDelegate's heightForRowAtIndexPath:, will size the cell at 44pts tall)
 * 
 * If expanded returns headerContentView + expandableContentView's computed height.
 *
 * @param width Width of the contentView to assume when determining height
 *
 * @result Height of cell calculated assuming its contentView is of the specified width
 */
@property (assign, nonatomic, getter=isExpanded) BOOL expanded;

@end
