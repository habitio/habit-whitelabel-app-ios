//
//  MZAlertViewBar.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 04/06/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZAlertViewBar.h"

@interface MZAlertViewBar ()
    
@property(nonatomic, readwrite) BOOL alerting;
@property(nonatomic, readwrite) AlertBarType type;

@end

@implementation MZAlertViewBar

@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         [self _initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
         [self _initializer];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self _initializer];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) _initializer
{
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    
    self.label = [[UILabel alloc] initWithFrame: self.bounds];
    [self addSubview:self.label];
    
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1];
    self.label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.shadowColor = [UIColor blackColor];
    
    self.alerting = false;
}

- (void)animateWithAlert:(NSString*)message type:(AlertBarType)type
{
    if (self.isAlerting) {
        
        // Is showing blocking alert bar
        if (self.type == AlertBarTypeBlocking ) {
            return;
            
        } else {
            
            self.type = type;
            
            [UIView animateWithDuration:0.3 delay:0 options:0
                animations:^{
                    self.center = CGPointMake(self.center.x, - self.frame.size.height*0.5);
                }
                completion:^(BOOL finished) {
                    self.label.text = message;
                    [self _setAlertBarBackgroundColorForType:type];
                    [self _animateAlertBarWithDelay:3];
                }];
        }
        
    } else {
        
        self.type = type;
        self.label.text = message;
        
        [self _setAlertBarBackgroundColorForType:type];
        [self _animateAlertBarWithDelay:3];
    }
}

- (void)_animateAlertBarWithDelay:(NSTimeInterval)delay
{
    self.alerting = true;
    
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        self.center = CGPointMake(self.center.x, self.frame.size.height*0.5);
        
    } completion:^(BOOL finished) {
        
        if (self.type != AlertBarTypeBlocking) {
            [self _doDismissWithDelay:delay];
        }
        
    }];
}

- (void)_doDismissWithDelay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.3 delay:delay options:0 animations:^{
        self.center = CGPointMake(self.center.x, - self.frame.size.height*0.5);
        
    } completion:^(BOOL finished) {
        self.alerting = false;
    }];
}

- (void)dismiss
{
    [self _doDismissWithDelay:0];
}

- (void)_setAlertBarBackgroundColorForType:(AlertBarType)type
{
    if (type == AlertBarTypeInfo) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];
        self.label.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        self.label.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];
    } else if (type == AlertBarTypeWarning){
        
        self.backgroundColor = [UIColor colorWithRed:246/255.0 green:232/255.0 blue:94/255.0 alpha:1];
        self.label.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        self.label.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];

    } else {
        self.backgroundColor = [UIColor colorWithRed:229/255.0 green:27/255.0 blue:36/255.0 alpha:1];
        self.label.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        self.label.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
    }
}
@end
