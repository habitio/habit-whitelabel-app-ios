//
//  MZTableView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZTableView.h"
#import "MZTableViewPrivate.h"

#import "MZTableViewCell.h"
#import "MZTableViewCellPrivate.h"
#import "MZTableViewSectionHeaderFooterView.h"

#import "MZRefreshHeaderView.h"
#import "MZRefreshHeaderViewPrivate.h"

@interface MZTableView ()

//! Maps reuse identifiers to cell class strings
@property (strong, nonatomic) NSMutableDictionary *cellClassForReuseIdentifier;
//! Maps reuse identifiers to sizing cells
@property (strong, nonatomic) NSMutableDictionary *sizingCellForReuseIdentifier;

//! Maps reuse identifiers to header/footer view class strings
@property (strong, nonatomic) NSMutableDictionary *headerFooterViewClassForReuseIdentifier;
//! Maps reuse identifiers to sizing header/footer views
@property (strong, nonatomic) NSMutableDictionary *sizingHeaderFooterViewsForReuseIdentifier;

@end

@implementation MZTableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if ((self = [super initWithFrame:frame style:style])) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.cellClassForReuseIdentifier = [NSMutableDictionary dictionary];
    self.sizingCellForReuseIdentifier = [NSMutableDictionary dictionary];
    
    self.headerFooterViewClassForReuseIdentifier = [NSMutableDictionary dictionary];
    self.sizingHeaderFooterViewsForReuseIdentifier = [NSMutableDictionary dictionary];
}

#pragma mark Sizing Views

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier != nil, @"Must have a reuse identifier.");
    NSAssert([cellClass isSubclassOfClass:[MZTableViewCell class]], @"You can only use subclasses of MZTableViewCell.");
    
    // The cell is registed based on the availability of a NIB Layout
    // When registering the cell, it is also registered a prototype version for auto sizing purposes.
    NSString *cellClassName = NSStringFromClass(cellClass);
    NSString *prototypeIdentifier = [identifier stringByAppendingString:@"Prototype"];
    
    UINib *availableNib = [UINib nibWithNibName:cellClassName bundle:[NSBundle mainBundle]];
    if (availableNib) {
        [super registerNib:availableNib forCellReuseIdentifier:identifier];
        [super registerNib:availableNib forCellReuseIdentifier:prototypeIdentifier];
    } else {
        [super registerClass:cellClass forCellReuseIdentifier:identifier];
        [super registerClass:cellClass forCellReuseIdentifier:prototypeIdentifier];
    }
    
    if (cellClass) {
        self.cellClassForReuseIdentifier[identifier] = cellClassName;
    } else {
        [self.cellClassForReuseIdentifier removeObjectForKey:identifier];
    }
}

- (void)registerClass:(Class)headerFooterViewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier != nil, @"Must have a reuse identifier.");
    NSAssert([headerFooterViewClass isSubclassOfClass:[MZTableViewSectionHeaderFooterView class]], @"You can only use subclasses of MZTableViewSectionHeaderFooterView.");
    
    // The headerFooterView is registed based on the availability of a NIB Layout
    // When registering the headerFooterView, it is also registered a prototype version for auto sizing purposes.
    NSString *headerFooterViewClassName = NSStringFromClass(headerFooterViewClass);
     NSString *prototypeIdentifier = [identifier stringByAppendingString:@"Prototype"];
    
    UINib *availableNib = [UINib nibWithNibName:headerFooterViewClassName bundle:[NSBundle mainBundle]];
    if (availableNib) {
        [super registerNib:availableNib forHeaderFooterViewReuseIdentifier:identifier];
        [super registerNib:availableNib forHeaderFooterViewReuseIdentifier:prototypeIdentifier];
    } else {
        [super registerClass:headerFooterViewClass forHeaderFooterViewReuseIdentifier:identifier];
        [super registerClass:headerFooterViewClass forHeaderFooterViewReuseIdentifier:prototypeIdentifier];
    }
    
    if (headerFooterViewClass) {
        self.headerFooterViewClassForReuseIdentifier[identifier] = NSStringFromClass(headerFooterViewClass);
    } else {
        [self.headerFooterViewClassForReuseIdentifier removeObjectForKey:identifier];
    }
}

- (MZTableViewCell *)sizingCellForReuseIdentifier:(NSString *)reuseIdentifier {
    NSAssert(reuseIdentifier != nil, @"Must have a reuse identifier.");
    NSAssert(self.cellClassForReuseIdentifier[reuseIdentifier], @"You must register a class for this reuse identifier.");
    
    NSString *prototypeIdentifier = [reuseIdentifier stringByAppendingString:@"Prototype"];
    
    if (!self.sizingCellForReuseIdentifier[prototypeIdentifier]) {
        
        MZTableViewCell *const sizingCell = [self dequeueReusableCellWithIdentifier:prototypeIdentifier];
        sizingCell.sizingCell = YES;
        self.sizingCellForReuseIdentifier[prototypeIdentifier] = sizingCell;
    }
    
    return self.sizingCellForReuseIdentifier[prototypeIdentifier];
}

- (MZTableViewSectionHeaderFooterView *)sizingHeaderFooterViewForReuseIdentifier:(NSString *)reuseIdentifier {
    NSAssert(reuseIdentifier != nil, @"Must have a reuse identifier.");
    NSAssert(self.headerFooterViewClassForReuseIdentifier[reuseIdentifier], @"You must register a class for this reuse identifier.");
    
    NSString *prototypeIdentifier = [reuseIdentifier stringByAppendingString:@"Prototype"];
    
    if (!self.sizingHeaderFooterViewsForReuseIdentifier[prototypeIdentifier]) {
        
        MZTableViewSectionHeaderFooterView *const sizingHeaderFooterView = [self dequeueReusableCellWithIdentifier:prototypeIdentifier];
        self.sizingHeaderFooterViewsForReuseIdentifier[prototypeIdentifier] = sizingHeaderFooterView;
    }
    
    return self.sizingHeaderFooterViewsForReuseIdentifier[prototypeIdentifier];
}

#pragma mark YLRefreshHeaderView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Put self.refreshHeaderView above the origin of self.frame. We set self.refreshHeaderView.frame.size to be equal to self.frame.size to guarantee that you won't be able to see beyond the top of the header view.
    // self.refreshHeaderView should draw it's content at the bottom of its frame.
    self.refreshHeaderView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setRefreshHeaderView:(MZRefreshHeaderView *)refreshHeaderView {
    if (refreshHeaderView) {
        [self addSubview:refreshHeaderView];
        [self sendSubviewToBack:refreshHeaderView];
        self.showsVerticalScrollIndicator = YES;
        refreshHeaderView.scrollView = self;
    } else {
        [self.refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = refreshHeaderView;
}

#pragma mark State

- (void)setState:(MZTableViewState)state {
    MZRefreshHeaderViewState newState = MZRefreshHeaderViewStateNormal;
    if (state == MZTableViewStateRefreshing) {
        newState = MZRefreshHeaderViewStateRefreshing;
    } else if (self.refreshHeaderView.refreshState == MZRefreshHeaderViewStateRefreshing) {
        newState = MZRefreshHeaderViewStateClosing;
    }
    self.refreshHeaderView.refreshState = newState;
    
    _state = state;
}
@end
