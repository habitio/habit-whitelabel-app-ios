//
//  MZTableViewPrivate.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableView.h"

@interface MZTableView ()

//! Returns a cached cell for this reuse identifier. The cell should only be used for sizing purposes, not for display.
- (MZTableViewCell *)sizingCellForReuseIdentifier:(NSString *)reuseIdentifier;

//! Returns a cached section header/footer view for this reuse identifier. The view should only be used for sizing purposes, not for display.
- (MZTableViewSectionHeaderFooterView *)sizingHeaderFooterViewForReuseIdentifier:(NSString *)reuseIdentifier;

@end