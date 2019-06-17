//
//  MZView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/10/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "MZView.h"

@interface MZView ()

@end

@implementation MZView

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    if (self.subviews.count == 0) {
        UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = [self.constraints copy];
        [self removeConstraints:self.constraints];
        [view addConstraints:constraints];
        return view;
    }
    return self;
}

- (void)renderWithModel:(NSObject *)model {

}
@end
