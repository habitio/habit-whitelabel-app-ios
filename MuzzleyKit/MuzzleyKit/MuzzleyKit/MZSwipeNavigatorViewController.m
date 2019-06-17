//
//  MZSwipeNavigatorViewController.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 18/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZSwipeNavigatorViewController.h"
#import <CoreGraphics/CoreGraphics.h>

#import "MZUserClient.h"

CGFloat const kArrowAlpha = 0.03;
CGFloat const kCircleTapUpScale = 0.6;
CGFloat const kCircleTapDownScale = 0.4;
CGFloat const kAnimationWaitDuration = 2.5;
CGFloat const kWaitingDuration = 5;
NSUInteger const kArrowsNumberByDirection = 3;

typedef NS_ENUM(NSUInteger, MZSwipeNavigatorOption) {
    MZSwipeNavigatorOptionOk = 1,
    MZSwipeNavigatorOptionBack = 2,
};

typedef NS_ENUM(NSUInteger, MZSwipeDirection) {
    MZSwipeDirectionUp,
    MZSwipeDirectionDown,
    MZSwipeDirectionRight,
    MZSwipeDirectionLeft
};

#pragma mark - Arrow Model Class
@interface SwipeArrow : NSObject

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SwipeArrow
@end

#pragma mark - MZSwipeNavigatorViewController Class
@interface MZSwipeNavigatorViewController ()

@property (nonatomic, strong, readwrite) IBOutlet UIButton *buttonOK;
@property (nonatomic, strong, readwrite) IBOutlet UIButton *buttonBack;

@property (nonatomic, strong) NSMutableArray *queueDirections;

@property (nonatomic, copy) NSString *arrowImageName;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *tapCenter;

@property (nonatomic, strong, readwrite) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (nonatomic, strong, readwrite) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (nonatomic, strong, readwrite) IBOutlet UISwipeGestureRecognizer *upSwipeGesture;
@property (nonatomic, strong, readwrite) IBOutlet UISwipeGestureRecognizer *downSwipeGesture;
@property (nonatomic, strong, readwrite) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong, readwrite) IBOutlet UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, assign) CGFloat pinchScale;

/// private signaling mzmessage for communication with activity
@property (nonatomic, strong) MZMessage *messageSignaling;

@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSTimer *waitingTimer;

@property (nonatomic, assign) NSInteger animatingDirection;

@end

@implementation MZSwipeNavigatorViewController

@synthesize buttonOK;
@synthesize buttonBack;

@synthesize tapCenter;

@synthesize rightSwipeGesture;
@synthesize leftSwipeGesture;
@synthesize upSwipeGesture;
@synthesize downSwipeGesture;
@synthesize tapGesture;
@synthesize pinchGesture;

-(void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
    
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    
    [self.waitingTimer invalidate];
    self.waitingTimer = nil;
    
}

#pragma mark Initializers
-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZSwipeNavigatorViewController *swipeNavigatorViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZSwipeNavigatorViewController"];
    self = swipeNavigatorViewController;
    
    if (self) {
        // Custom initialization
        self.parameters = parameters;
        
        self.animatingDirection = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tapCenter.transform = CGAffineTransformMakeScale(kCircleTapUpScale, kCircleTapUpScale);
    self.tapCenter.alpha = 0.75;
    
    self.arrowImageName = @"swipe-arrow";
    [self configureSwipeArrows];
    
    [self performSelector:@selector(waitingTimerFired:) withObject:nil afterDelay:1];
}

#pragma mark View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark Private methods
#pragma mark - Quit Activity flow

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)])
            [self.delegate widgetNeedsToDismiss:self];

    }
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    // Reset the animation timeout
    if ([_animationTimer isValid]) [_animationTimer invalidate];
    if ([_waitingTimer isValid]) [_waitingTimer invalidate];
    
    MZSwipeDirection direction;
    
    if (recognizer == self.rightSwipeGesture) {
        direction = MZSwipeDirectionRight;
        
    } else if (recognizer == self.leftSwipeGesture) {
        direction = MZSwipeDirectionLeft;
        
    } else if (recognizer == self.upSwipeGesture) {
        direction = MZSwipeDirectionUp;
        
    } else {
       direction = MZSwipeDirectionDown;
    }
    
    [self animateArrowsWithDirection:direction];
    
    self.waitingTimer =
    [NSTimer scheduledTimerWithTimeInterval:kWaitingDuration
                                     target:self
                                   selector:@selector(waitingTimerFired:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self _didSwipeToDirection:direction];
    
}

- (IBAction)handleTap:(UITapGestureRecognizer*)recognizer
{
    // Reset the animation timeout
    if ([_animationTimer isValid]) [_animationTimer invalidate];
    if ([_waitingTimer isValid]) [_waitingTimer invalidate];
    
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.tapCenter.transform = CGAffineTransformMakeScale(kCircleTapDownScale,
                                                                               kCircleTapDownScale);
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                               self.tapCenter.transform = CGAffineTransformMakeScale(kCircleTapUpScale, kCircleTapUpScale);
                                              
                                          } completion:^(BOOL finished) {
                                              
                                          }];
    }];
    
    self.waitingTimer =
    [NSTimer scheduledTimerWithTimeInterval:kWaitingDuration
                                     target:self
                                   selector:@selector(waitingTimerFired:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self _didTap];

}

- (IBAction)handlePinch:(UIPinchGestureRecognizer*)recognizer
{
    CGFloat tempScale = [self roundToN:recognizer.scale decimals:1];
    
    if (tempScale == _pinchScale) return;
    
    self.pinchScale = tempScale;
  
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            self.pinchScale = 1;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            self.pinchScale = 1;
            break;
        }
        default:
            break;
    }
    
    [self _didPinch:self.pinchScale];

}

#pragma mark - Configure Swipe Arrows
- (void)configureSwipeArrows
{
    self.queueDirections = [NSMutableArray new];
    UIImage *image = [UIImage imageNamed: self.arrowImageName];
    
    for ( int direction = 0; direction < 4; direction++ ) {
        
        NSMutableArray *arrowsArray = [NSMutableArray new];
        for ( int i = 0; i < kArrowsNumberByDirection; i++ ) {
            
            SwipeArrow *arrow = [SwipeArrow new];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            arrow.imageView = imageView;
            arrow.imageView.autoresizingMask = UIViewAutoresizingNone;
            arrow.imageView.translatesAutoresizingMaskIntoConstraints = YES;
            [self.tapCenter.superview addSubview:arrow.imageView];
            [arrowsArray addObject:arrow];
        }
        [self.queueDirections addObject:arrowsArray];
        [self configureArrowsArray:arrowsArray direction:direction];
    }
}

- (void)configureArrowsArray:(NSMutableArray *)arrowsArray direction:(MZSwipeDirection)direction
{
    CGPoint translation;
    NSInteger offset = tapCenter.frame.size.width / 2 + 20;
    CGFloat rotateToAngle;
    CGFloat arrowScale;
    
    for ( int arrowIdx = 0; arrowIdx < arrowsArray.count; arrowIdx++ ) {
        
        SwipeArrow *arrow = (SwipeArrow *)arrowsArray[arrowIdx];
        arrowScale = 1 / ((arrowIdx * 0.4) + 1);
    
        CGFloat distance = offset + ( arrowIdx * 25 );
        
        switch (direction) {
            case MZSwipeDirectionUp:
                rotateToAngle = 0;
                translation = CGPointMake(0, -distance);
                break;
            case MZSwipeDirectionDown:
                rotateToAngle = M_PI;
                translation = CGPointMake(0, distance);
                break;
            case MZSwipeDirectionRight:
                rotateToAngle = M_PI_2;
                translation = CGPointMake(distance, 0);
                break;
            case MZSwipeDirectionLeft:
                rotateToAngle = -M_PI_2;
                translation = CGPointMake(-distance, 0);
                break;
            default:
                break;
        }
        
        CGPoint centerPoint =
            CGPointMake(self.tapCenter.center.x + translation.x,
                        self.tapCenter.center.y + translation.y);
        
        [self configureArrow:arrow centerPoint:centerPoint scale:arrowScale rotation:rotateToAngle];
    }
}

- (void)configureArrow:(SwipeArrow *)arrow centerPoint:(CGPoint)point scale:(CGFloat)scale rotation:(CGFloat)rotation
{
    arrow.imageView.alpha = kArrowAlpha;
    arrow.imageView.center = point;
    arrow.imageView.transform = CGAffineTransformScale(arrow.imageView.transform, scale, scale);
    arrow.imageView.transform = CGAffineTransformRotate(arrow.imageView.transform, rotation);
    
}

#pragma mark - Arrows Animation
- (void)animationTimerFired:(NSTimer *)timer
{
    self.animatingDirection =  _animatingDirection == MZSwipeDirectionLeft ? MZSwipeDirectionUp : ++_animatingDirection;
    [self animateArrowsWithDirection:_animatingDirection];
}

- (void)animateArrowsWithDirection:(MZSwipeDirection)direction
{
    NSInteger distance = 10;
    NSMutableArray *arrowsArray = self.queueDirections[direction];
    
    for (NSInteger i = 0; i < arrowsArray.count; i++) {
        SwipeArrow *arrow = arrowsArray[i];
        
        [UIView animateWithDuration:0.2 delay:i * 0.05 options:0
            animations:^{
                
                arrow.imageView.alpha = kArrowAlpha * 2;
                //arrow.imageView.transform = CGAffineTransformTranslate(arrow.imageView.transform, 0, -distance);
                arrow.imageView.center = CGPointMake(arrow.imageView.center.x, arrow.imageView.center.y - distance);
                
            } completion:^(BOOL finished) {
                            
                [UIView animateWithDuration:0.3 delay:0 options:0
                    animations:^{
                        
                        arrow.imageView.alpha = kArrowAlpha;
                        //arrow.imageView.transform = CGAffineTransformTranslate(arrow.imageView.transform, 0, distance);
                        arrow.imageView.center = CGPointMake(arrow.imageView.center.x, arrow.imageView.center.y + distance);
                        
                    } completion:^(BOOL finished) {
                                                  
                    }];
                             
                }];
    }
}

- (void)waitingTimerFired:(NSTimer *)timer
{
    [self.waitingTimer invalidate];
    self.waitingTimer = nil;
    
    self.animationTimer =
    [NSTimer scheduledTimerWithTimeInterval:kAnimationWaitDuration
                                     target:self
                                   selector:@selector(animationTimerFired:)
                                   userInfo:nil
                                    repeats:YES];
}

- (CGFloat)roundToN:(CGFloat)num decimals:(NSInteger)decimals
{
    NSInteger tenpow = 1;
    for (; decimals; tenpow *= 10, decimals--);
    return round(tenpow * num) / tenpow;
}


- (IBAction)buttonTouchUpInside:(id)sender
{    
    MZSwipeNavigatorOption option = 0;
    UIButton *button = (UIButton*)sender;
    
    if (button == self.buttonBack) {
        option = MZSwipeNavigatorOptionBack;
    } else if (button == self.buttonOK) {
        option = MZSwipeNavigatorOptionOk;
    }
    
    [self _didSelectOption:option];
}


//////////////////////////////////////////////////////////////////////////
/// Swipe Navigator Widget Communication Methods
//////////////////////////////////////////////////////////////////////////
- (void)_didSelectOption:(MZSwipeNavigatorOption)option
{
    NSString *widget = @"swipeNavigator";
    NSString *component = @"";
    NSString *value = @"";
    
    if (option == MZSwipeNavigatorOptionOk) {
        component = @"bOk";
        value = @"ok";
    } else if (option == MZSwipeNavigatorOptionBack) {
        component = @"bBack";
        value = @"back";
    }
    
    NSString *event = @"release";
    
    NSDictionary *dataProtocol = [NSDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

- (void)_didSwipeToDirection:(MZSwipeDirection)direction
{
    NSString *widget = @"swipeNavigator";
    NSString *component = @"swipe";
    
    NSString *value = @"";
    
    if (direction == MZSwipeDirectionRight) {
        value = @"r";
        
    } else if (direction == MZSwipeDirectionLeft) {
        value = @"l";
        
    } else if (direction == MZSwipeDirectionUp) {
        value = @"u";
        
    } else if (direction == MZSwipeDirectionDown) {
        value = @"d";
    }
    
    NSString *event = @"swipe";
    
    NSDictionary *dataProtocol = [NSDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

- (void)_didTap
{
    NSString *widget = @"swipeNavigator";
    NSString *component = @"tap";
    NSString *value = @"tap";
    NSString *event = @"tap";
    
    NSDictionary *dataProtocol = [NSDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

- (void)_didPinch:(float)scale
{
    NSString *widget = @"swipeNavigator";
    NSString *component = @"pinch";
    NSNumber *value = [NSNumber numberWithFloat:scale];
    NSString *event = @"change";
    
    NSDictionary *dataProtocol = [NSDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

@end



