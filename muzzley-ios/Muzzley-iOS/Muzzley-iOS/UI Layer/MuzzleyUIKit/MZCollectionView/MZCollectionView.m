//
//  MZCollectionView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "MZCollectionView.h"

#import "MZCollectionViewCellPrivate.h"
#import "MZCollectionReusableViewPrivate.h"
#import "MZRefreshHeaderViewPrivate.h"

@interface MZCollectionView ()

//! Maps reuse identifiers to cell class strings
@property (strong, nonatomic) NSMutableDictionary *cellClassForReuseIdentifier;
//! Maps reuse identifiers to sizing cells
@property (strong, nonatomic) NSMutableDictionary *sizingCellForReuseIdentifier;

//! Maps reuse identifiers to reusable view class strings
@property (strong, nonatomic) NSMutableDictionary *reusableViewClassForReuseIdentifier;
//! Maps reuse identifiers to sizing reusable views
@property (strong, nonatomic) NSMutableDictionary *sizingReusableViewForReuseIdentifier;
@end


@implementation MZCollectionView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if ((self = [super initWithFrame:frame collectionViewLayout:layout])) {
        [self _init];
    }
    return self;
}

- (void)_init {
    
    self.cellClassForReuseIdentifier = [NSMutableDictionary dictionary];
    self.sizingCellForReuseIdentifier = [NSMutableDictionary dictionary];
    
    self.reusableViewClassForReuseIdentifier = [NSMutableDictionary dictionary];
    self.sizingReusableViewForReuseIdentifier = [NSMutableDictionary dictionary];
	
}

#pragma mark Sizing Views
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
//    NSAssert(identifier != nil, @"Must have a reuse identifier.");
//    NSAssert([cellClass isSubclassOfClass:[MZCollectionViewCell class]], @"You can only use subclasses of MZCollectionViewCell.");
//    
    // The cell is registed based on the availability of a NIB Layout
    // When registering the cell, it is also registered a prototype version for auto sizing purposes.
    NSString *cellClassName = NSStringFromClass(cellClass);
    NSString *prototypeIdentifier = [identifier stringByAppendingString:@"Prototype"];
    
    UINib *availableNib = [UINib nibWithNibName:cellClassName bundle:[NSBundle mainBundle]];
    if (availableNib) {
        [super registerNib:availableNib forCellWithReuseIdentifier:identifier];
        [super registerNib:availableNib forCellWithReuseIdentifier:prototypeIdentifier];
    } else {
        [super registerClass:cellClass forCellWithReuseIdentifier:identifier];
        [super registerClass:cellClass forCellWithReuseIdentifier:prototypeIdentifier];
    }
    
    if (cellClass) {
        self.cellClassForReuseIdentifier[identifier] = cellClassName;
    } else {
        [self.cellClassForReuseIdentifier removeObjectForKey:identifier];
    }
}

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier != nil, @"Must have a reuse identifier.");
    NSAssert([viewClass isSubclassOfClass:[MZCollectionReusableView class]], @"You can only use subclasses of MZCollectionReusableView.");
    
    // The cell is registed based on the availability of a NIB Layout
    // When registering the cell, it is also registered a prototype version for auto sizing purposes.
    NSString *cellClassName = NSStringFromClass(viewClass);
    NSString *prototypeIdentifier = [identifier stringByAppendingString:@"Prototype"];
    
    UINib *availableNib = [UINib nibWithNibName:cellClassName bundle:[NSBundle mainBundle]];
    if (availableNib) {
        [super registerNib:availableNib forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
        [super registerNib:availableNib forSupplementaryViewOfKind:elementKind withReuseIdentifier:prototypeIdentifier];
    } else {
        [super registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
        [super registerClass:viewClass forSupplementaryViewOfKind:elementKind withReuseIdentifier:prototypeIdentifier];
    }
    
    if (viewClass) {
        self.reusableViewClassForReuseIdentifier[identifier] = cellClassName;
    } else {
        [self.reusableViewClassForReuseIdentifier removeObjectForKey:identifier];
    }
}

- (MZCollectionViewCell *)sizingCellForReuseIdentifier:(NSString *)reuseIdentifier {
    NSAssert(reuseIdentifier != nil, @"Must have a reuse identifier.");
    NSAssert(self.cellClassForReuseIdentifier[reuseIdentifier], @"You must register a class for this reuse identifier.");
    
    NSString *prototypeIdentifier = [reuseIdentifier stringByAppendingString:@"Prototype"];
    
    if (!self.sizingCellForReuseIdentifier[prototypeIdentifier]) {
        
        MZCollectionViewCell *const sizingCell = [[NSClassFromString(reuseIdentifier) alloc] init];
        sizingCell.sizingCell = YES;
        self.sizingCellForReuseIdentifier[prototypeIdentifier] = sizingCell;
    }
    return self.sizingCellForReuseIdentifier[prototypeIdentifier];
}

- (MZCollectionReusableView *)sizingReusableViewForReuseIdentifier:(NSString *)reuseIdentifier {
    NSAssert(reuseIdentifier != nil, @"Must have a reuse identifier.");
    NSAssert(self.reusableViewClassForReuseIdentifier[reuseIdentifier], @"You must register a class for this reuse identifier.");
    
    NSString *prototypeIdentifier = [reuseIdentifier stringByAppendingString:@"Prototype"];
    
    if (!self.sizingReusableViewForReuseIdentifier[prototypeIdentifier]) {
        
        MZCollectionReusableView *const sizingReusableView = [[NSClassFromString(reuseIdentifier) alloc] init];
        sizingReusableView.sizingView = YES;
        self.sizingReusableViewForReuseIdentifier[prototypeIdentifier] = sizingReusableView;
    }
    return self.sizingReusableViewForReuseIdentifier[prototypeIdentifier];
}

#pragma mark YLRefreshHeaderView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Put self.refreshHeaderView above the origin of self.frame. We set self.refreshHeaderView.frame.size to be equal to self.frame.size to guarantee that you won't be able to see beyond the top of the header view.
    // self.refreshHeaderView should draw it's content at the bottom of its frame.
    self.refreshHeaderView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
	
//	self.refreshHeaderView.frame = CGRectMake(0, 0, 1, 1);

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

- (void)setState:(MZCollectionViewState)state {
    MZRefreshHeaderViewState newState = MZRefreshHeaderViewStateNormal;
    if (state == MZCollectionViewStateRefreshing) {
        newState = MZRefreshHeaderViewStateRefreshing;
    } else if (self.refreshHeaderView.refreshState == MZRefreshHeaderViewStateRefreshing) {
        newState = MZRefreshHeaderViewStateClosing;
    }
    self.refreshHeaderView.refreshState = newState;
    
    _state = state;
}

@end
