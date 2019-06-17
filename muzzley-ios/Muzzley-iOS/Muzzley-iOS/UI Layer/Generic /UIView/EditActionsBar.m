//
//  ChannelActionsBar.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 7/5/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "EditActionsBar.h"

@interface EditActionsBar ()
@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *selectionCounterLabel;
@end

@implementation EditActionsBar

#pragma mark - Initializers Methods
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self _loadNib];
        return self;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _loadNib];
        return self;
    }
    return nil;
}

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 480)]) {
        [self _loadNib];
        return self;
    }
    return nil;
}

#pragma mark - Private Methods
- (void)_loadNib
{
    NSString *className = NSStringFromClass([self class]);
    self.view = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
    [self addSubview:self.view];
    
    // Add constraints to inner view to match self bounds
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(_view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_view]|" options:0 metrics:nil views:views]];
    
    // setup subviews
    [self _setupInterface];
}

- (void)_setupInterface
{
    [self setSelectedCount:0];
    [self setEditEnabled:YES];
    [self setDeleteEnabled:YES];
    
    self.deleteButton.hidden = !self.deleteEnabled;
    self.editButton.hidden = !self.editEnabled;
}

- (void)setSelectedCount:(NSUInteger)count
{
    self.deleteButton.enabled = (count > 0) ? YES : NO;
    self.editButton.enabled = (count == 1) ? YES : NO;
    
    NSString *countString = @"";
    if (count > 0) {
        countString = [NSString stringWithFormat:NSLocalizedString(@"mobile_selected", @""), [NSString stringWithFormat:@"%d", count]];
    }
    self.selectionCounterLabel.text = countString;
}

#pragma mark - IBACTIONS
- (IBAction)cancelButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(barDidSelectCancelAction:)]) {
        [self.delegate barDidSelectCancelAction:self];
    }
}

- (IBAction)deleteButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(barDidSelectDeleteAction:)]) {
        [self.delegate barDidSelectDeleteAction:self];
    }
}

- (IBAction)editButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(barDidSelectEditAction:)]) {
        [self.delegate barDidSelectEditAction:self];
    }
}

@end
