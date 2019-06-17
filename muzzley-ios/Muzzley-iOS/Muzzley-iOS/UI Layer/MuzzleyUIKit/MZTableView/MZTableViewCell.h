//
//  MZTableViewCell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kUITableViewCellDefaultHeight;

@interface MZTableViewCell : UITableViewCell

//! Apply a cell model to a cell.  Subclasses should implement this to decide how they display a model's content.
- (void)setModel:(NSObject *)model;

/*! Set by MZTableView to indicate that this cell will be used solely for sizing and will never be displayed on screen.
 *
 *  For example, subclasses can use this information to optimize away unnecessary configuration.
 */
@property (readonly, assign, nonatomic, getter=isSizingCell) BOOL sizingCell;

@end
