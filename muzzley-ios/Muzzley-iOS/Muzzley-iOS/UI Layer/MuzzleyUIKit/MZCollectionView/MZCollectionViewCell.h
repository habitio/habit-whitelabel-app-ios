//
//  MZCollectionViewcell.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZCollectionViewCell;
@protocol MZCollectionViewCellDelegate <NSObject>
@end

@interface MZCollectionViewCell : UICollectionViewCell
//! Apply a cell model to a cell. Subclasses should implement this to decide how they display a model's content.
- (void)setModel:(NSObject *)model;

/*! Set by MZCollectionView to indicate that this cell will be used solely for sizing and will never be displayed on screen.
 *
 *  For example, subclasses can use this information to optimize away unnecessary configuration.
 */
@property (nonatomic, assign, readonly, getter=isSizingCell) BOOL sizingCell;

@property (nonatomic, weak) id<MZCollectionViewCellDelegate> delegate;
/* 
 * When overriding layoutSubviews subclass method you must call
 * setNeedsContentViewLayout to make a layout pass in contentView
 */
- (void)setNeedsContentViewLayout;
@end
