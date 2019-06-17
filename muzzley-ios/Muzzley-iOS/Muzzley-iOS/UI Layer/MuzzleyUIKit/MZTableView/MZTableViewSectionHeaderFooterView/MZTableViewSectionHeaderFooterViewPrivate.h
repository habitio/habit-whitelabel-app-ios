//
//  MZTableViewSectionHeaderFooterViewPrivate.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableViewSectionHeaderFooterView.h"

@interface MZTableViewSectionHeaderFooterView ()

//! Position of this header/footer in the table view
@property (assign, nonatomic) MZTableViewSectionHeaderFooterPosition position;

/*!
 * Returns contentView's computed height based upon Auto Layout constraints if non-0. Otherwise, it
 * returns UITableViewAutomaticDimension (which, when returned from UITableViewDelegate's
 * heightForRowAtIndexPath:, will size the header/footer defaultEmptySectionHeaderFooterHeight tall)
 *
 * @param width Width of the contentView to assume when determining height
 *
 * @result Height of header/footer calculated assuming its contentView is of the specified width
 */
- (CGFloat)heightForWidth:(CGFloat)width;

//! If YES, this instance is being used as a sizing header/footer and won't actually be displayed on screen.
@property (assign, nonatomic, getter=isSizingView) BOOL sizingView;

@end
