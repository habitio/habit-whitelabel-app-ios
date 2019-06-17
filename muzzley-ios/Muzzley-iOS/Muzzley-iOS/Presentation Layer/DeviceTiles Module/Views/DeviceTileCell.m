//
//  DeviceCardCollectionViewCell.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 11/9/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "DeviceTileCell.h"

#import "DeviceTileRefreshView.h"
#import "DeviceTileProblemView.h"


@interface DeviceTileCell () <MZTriStateToggleDelegate>
{
    MZTileViewModel* _viewModel;
}

@property(nonatomic, weak) IBOutlet UIView *cardContentView;
@property(nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *uiOverlayImage;

@property (nonatomic, weak) IBOutlet DeviceTileRefreshView *refreshView;
@property (nonatomic, weak) IBOutlet DeviceTileProblemView *problemView;
@property (nonatomic, weak) IBOutlet UILabel *iconLabel;
@property (nonatomic, weak) IBOutlet UIView *iconView;

@end

@implementation DeviceTileCell
@dynamic delegate;

- (void)awakeFromNib {
    
    CALayer *cardLayer = self.cardContentView.layer;
    cardLayer.cornerRadius = CORNER_RADIUS;
    cardLayer.masksToBounds = YES;
    
    self.deviceNameLabel.font = [UIFont lightFontOfSize:13.0];

	[self.toggle setIsAccessibilityElement:true];
	[self.toggle setAccessibilityIdentifier:@"toggle"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CALayer *selfLayer = self.layer;
    selfLayer.shadowOffset = CGSizeMake(0, 0.5);
    selfLayer.shadowOpacity = 0.2;
    selfLayer.shadowColor = [[UIColor blackColor] CGColor];
    selfLayer.shadowRadius = 1;
    selfLayer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cardContentView.layer.cornerRadius] CGPath];
    
    [super layoutSubviews];
}

- (void)prepareForReuse {
    self.deviceNameLabel.text =
    self.iconLabel.text = @"";
    for (int i = 0;i < 2; i++)
    {
        UILabel *label = (UILabel *)[self viewWithTag:(i+1)*100];
        label.text = @"";
        label = (UILabel *)[self viewWithTag:((i+1)*100)+1];
        label.text = @"";
        label = (UILabel *)[self viewWithTag:((i+1)*100)+2];
        label.text = @"";
    }
    
    [self.toggle setState:MZTriStateToggleStateUnknown animated:NO];
	[self.backgroundImageView cancelImageDownloadTask];
    self.backgroundImageView.image = nil;
    
    //TODO improve this
    CGRect frame = self.iconView.frame;
    frame.size.height = 30;
    frame.origin.x = self.bounds.size.width - self.iconView.frame.size.width - 8;
    self.iconView.frame = frame;
    self.iconView.translatesAutoresizingMaskIntoConstraints = true;
    
}

- (void)setModel:(MZTileViewModel *)model {
    [self prepareForReuse];
    NSAssert([model isKindOfClass:[MZTileViewModel class]], @"Must use %@ with %@", NSStringFromClass([MZTileViewModel class]), NSStringFromClass([self class]));
    
    _viewModel = model;
    
    self.deviceNameLabel.text = _viewModel.title;
    //NSLog(@"self.deviceNameLabel.text %@",self.deviceNameLabel.text);
    
    if (_viewModel.iconViewModel && _viewModel.iconViewModel.color != nil) {
        self.iconLabel.font = [UIFont fontWithName:@"icomoon" size:17.0];
        NSString * symbol = [_viewModel.iconViewModel.char_ mutableCopy];
        CFStringTransform((__bridge CFMutableStringRef)symbol, NULL, CFSTR("Any-Hex/Java"), YES);
        self.iconLabel.text = symbol;
        self.iconLabel.textColor = _viewModel.iconViewModel.color;
    } else {
        CGRect frame = self.iconView.frame;
        frame.size.height = 1;
        self.iconView.frame = frame;
    }
    
    int j = 1;
    for (int i = 0; i < [_viewModel.tileInformations count] && i < 2; i++)
    {
        TileInfoViewModel * info = _viewModel.tileInformations[i];
       // NSLog(@"info.value %@ for %@",info.value, _viewModel.model.identifier);
        if (info.value) {
            UILabel *labelInfo = (UILabel *)[self viewWithTag:j*100];
            labelInfo.font = [UIFont regularFontOfSize:20.0];
            labelInfo.text = info.value;
           
                NSMutableAttributedString * unit = [[NSMutableAttributedString alloc] initWithString:info.label attributes:@{NSFontAttributeName: [UIFont lightFontOfSize:10.0], NSForegroundColorAttributeName: [UIColor muzzleyGrayColorWithAlpha:1.0]}];
            if (info.suffix != nil && ![info.suffix isEqualToString:@""])
            {
                [unit appendAttributedString:[[NSAttributedString alloc] initWithString:@"(" attributes:@{NSFontAttributeName: [UIFont lightFontOfSize:10.0], NSForegroundColorAttributeName: [UIColor muzzleyGrayColorWithAlpha:1.0]}]];
                [unit appendAttributedString:[[NSAttributedString alloc] initWithString:info.suffix attributes:@{NSFontAttributeName: [UIFont semiboldFontOfSize:10.0], NSForegroundColorAttributeName: [UIColor muzzleyGray2ColorWithAlpha:1.0]}]];
                [unit appendAttributedString:[[NSAttributedString alloc] initWithString:@")" attributes:@{NSFontAttributeName: [UIFont lightFontOfSize:10.0], NSForegroundColorAttributeName: [UIColor muzzleyGrayColorWithAlpha:1.0]}]];
            }
            
            UILabel *label = (UILabel *)[self viewWithTag:j*100+2];
            label.attributedText = unit.copy;
            j++;
        }
    }
    //TODO to similar to tilecell, use a base
    if (model.tileActionViewModel != nil)
    {
        self.toggle.hidden = NO;
        MZTriStateToggleState toggleState = MZTriStateToggleStateUnknown;
        if (_viewModel.tileActionViewModel.state == TileActionViewModelStateOn ) {
            toggleState = MZTriStateToggleStateOn;
        } else if (_viewModel.tileActionViewModel.state == TileActionViewModelStateOff) {
            toggleState = MZTriStateToggleStateOff;
        }
        [self.toggle setState:toggleState animated:NO];
        self.toggle.delegate = self;
        if (model.tileActionViewModel.onStateIconName != nil)
        {
            self.toggle.thumbImage = [UIImage imageNamed:model.tileActionViewModel.onStateIconName];
        }
    } else {
        self.toggle.hidden = YES;
    }
    
    [self.backgroundImageView cancelImageDownloadTask];
    if (_viewModel.imageURL) {
        [self.backgroundImageView setImageWithURL:_viewModel.imageURL];
    } else {
        self.backgroundImageView.image = nil;
    }
    
    if (_viewModel.overlayUrl) {
        [self.uiOverlayImage setImageWithURL:_viewModel.overlayUrl];
    } else {
        self.uiOverlayImage.image = nil;
    }
    self.refreshView.hidden = _viewModel.state != TileStateLoading;
    self.problemView.hidden = _viewModel.state != TileStateError;
    
    _viewModel.refreshViewModel.animating = _viewModel.state == TileStateLoading;
    
    [self.refreshView renderWithModel:_viewModel.refreshViewModel];
    [self.problemView renderWithModel:_viewModel.problemViewModel];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)toggle:(MZTriStateToggle *)toggle didChangetoState:(MZTriStateToggleState)state
{
    _viewModel.tileActionViewModel.state = (state == MZTriStateToggleStateOn)?TileActionViewModelStateOn:TileActionViewModelStateOff;
    if ([self.delegate respondsToSelector:@selector(deviceTileCellToggleDidChangeValue:)]) {
        [self.delegate deviceTileCellToggleDidChangeValue:self];
    }
}



@end
