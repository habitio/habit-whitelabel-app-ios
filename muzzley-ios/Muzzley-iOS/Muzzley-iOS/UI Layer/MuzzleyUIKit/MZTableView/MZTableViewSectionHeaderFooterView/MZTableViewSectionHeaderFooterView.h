//
//  MZTableViewSectionHeaderFooterView.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MZTableViewSectionHeaderFooterPosition) {
  MZTableViewSectionHeaderFooterPositionUndefined,
  MZTableViewSectionHeaderFooterPositionHeader, // Any header but the first one in the table view
  MZTableViewSectionHeaderFooterPositionFirstHeader, // The first header in the table view
  MZTableViewSectionHeaderFooterPositionFooter, // Any footer but the last on one in the table view
  MZTableViewSectionHeaderFooterPositionLastFooter, // The last footer in the table view
};

@interface MZTableViewSectionHeaderFooterView : UITableViewHeaderFooterView

//! Position of this header/footer in the table view
@property (readonly, assign, nonatomic) MZTableViewSectionHeaderFooterPosition position;

//! If YES, this instance is being used as a sizing header/footer and won't actually be displayed on screen.
@property (readonly, assign, nonatomic, getter=isSizingView) BOOL sizingView;

@end
