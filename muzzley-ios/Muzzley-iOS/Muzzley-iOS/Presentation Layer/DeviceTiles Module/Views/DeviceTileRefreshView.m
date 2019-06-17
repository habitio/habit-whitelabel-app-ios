//
//  DeviceTileRefreshView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/10/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "DeviceTileRefreshView.h"

@interface DeviceTileRefreshView ()
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation DeviceTileRefreshView

- (void)awakeFromNib {
    [self _init];
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [super awakeAfterUsingCoder:aDecoder];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        
        [self _init];
    }
    return self;
}

- (void)_init {

}

- (void)renderWithModel:(TileRefreshViewModel *)model {
    NSAssert([model isKindOfClass:[TileRefreshViewModel class]], @"Must use %@ with %@", NSStringFromClass([TileRefreshViewModel class]), NSStringFromClass([self class]));
    
    model.animating ?
        [self.activityIndicator startAnimating] :
        [self.activityIndicator stopAnimating];
}

@end
