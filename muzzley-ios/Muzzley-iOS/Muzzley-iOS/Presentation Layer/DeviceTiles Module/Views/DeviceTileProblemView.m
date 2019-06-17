//
//  DeviceTileProblemView.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/10/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

#import "DeviceTileProblemView.h"

@interface DeviceTileProblemView ()
@property (nonatomic, weak) IBOutlet UIView *imageBorderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *retryButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@end

@implementation DeviceTileProblemView

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
    self.imageBorderView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.imageBorderView.layer.shouldRasterize = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.preferredMaxLayoutWidth = self.label.frame.size.width;
    self.imageBorderView.layer.cornerRadius = self.imageBorderView.frame.size.width * 0.5;
    
    [super layoutSubviews];
}

- (void)renderWithModel:(TileProblemViewModel *)model {
    NSAssert([model isKindOfClass:[TileProblemViewModel class]], @"Must use %@ with %@", NSStringFromClass([TileProblemViewModel class]), NSStringFromClass([self class]));
    
    self.imageView.image = [[UIImage imageNamed:model.iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.tintColor = [UIColor whiteColor];
    
    self.label.text = model.message;
    [self.retryButton setTitle:model.retryTitle forState:UIControlStateNormal];
    [self.cancelButton setTitle:model.cancelTitle forState:UIControlStateNormal];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (IBAction)tryAgainAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deviceTileProblemViewDidPressTryAgainAction:)]) {
        [self.delegate deviceTileProblemViewDidPressTryAgainAction:self];
    }
}

- (IBAction)cancelAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deviceTileProblemViewDidPressCancelAction:)]) {
        [self.delegate deviceTileProblemViewDidPressCancelAction:self];
    }
}

@end
