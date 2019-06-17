//
//  MZDrawPadViewController.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 08/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZDrawPadViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MZBezierDrawView.h"

#import "MZUserClient.h"
/// Drawpad Touch State Configuration
typedef enum : NSUInteger {
    MZDrawpadTouchStateBegan     = 1,
    MZDrawpadTouchStateMoved     = 2,
    MZDrawpadTouchStateEnded     = 3,
    
} MZDrawpadTouchState;


@interface MZDrawPadViewController ()

@property (nonatomic, strong, readwrite) IBOutlet UIButton *buttonClean;
@property (nonatomic, strong) IBOutlet MZBezierDrawView *drawCanvasView;

@property (nonatomic, strong) NSTimer *samplingTimer;
@property (nonatomic, assign) float pathHistoryDecay;

@property (nonatomic, assign) CGPoint pointBegan;
@property (nonatomic, assign) CGPoint pointChanged;
@property (nonatomic, assign) CGPoint pointEnded;

/// private signaling mzmessage for communication with activity
@property (nonatomic, strong) MZMessage *messageSignaling;

@property (nonatomic, strong) UIAlertView *alertView;

- (void)setTouchInputSampling:(NSTimeInterval)samplingTimeInterval;
- (void)_handleTimer:(NSTimer*)timer;

@end

@implementation MZDrawPadViewController

@synthesize drawCanvasView;
@synthesize buttonClean;

#pragma mark Initializers

- (void)dealloc
{
    self.samplingTimer = nil;
    
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
}

-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZDrawPadViewController *drawPadViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZDrawPadViewController"];
    self = drawPadViewController;
    
    if (self) {
        
        // Custom initialization
        self.parameters = parameters;
    }
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    double touchInputSampling = 1/30;
    
    if ([self.parameters valueForKey:@"sampling"]) {
        touchInputSampling = [[self.parameters valueForKey:@"sampling"] doubleValue];
        if (touchInputSampling < 1/60) {
            touchInputSampling = 1/60;
        }
    }
    
    self.pathHistoryDecay = -1;
    if ([self.parameters valueForKey:@"decay"]) {
        self.pathHistoryDecay = [[self.parameters valueForKey:@"decay"] floatValue];
    }
    
    self.titleLabel.text = @"";
    if ([self.parameters objectForKey:@"title"]) {
        
        self.titleLabel.text = [self.parameters objectForKey:@"title"] ;
    }
    
    self.drawCanvasView.pathHistoryDecay = self.pathHistoryDecay;
    self.drawCanvasView.delegate = self;
    
    /*double inputSampling = 0.0;
     
     
     if ( touchInputSampling.doubleValue < (1/60) ) {
     inputSampling = 1/60;
     } else {
     inputSampling = touchInputSampling.doubleValue;
     }*/
    
    //NSLog(@"%f",touchInputSampling);
    
    [self setTouchInputSampling: touchInputSampling];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /// Disable the Timer.
    [self.samplingTimer invalidate];
    self.samplingTimer = nil;
}

#pragma mark View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark Private methods
#pragma mark - Quit Activity flow
- (IBAction)exitDrawPad:(id)sender
{
    self.alertView =
    [[UIAlertView alloc ]initWithTitle:@"Return to menu"
                               message:@"Are you sure?"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"OK", nil];
    
    [self.alertView show];
}


#pragma mark - alertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)]) {
            [self.delegate widgetNeedsToDismiss:self];
        }
    }
}

-(void)bezierDraw:(MZBezierDrawView *)drawpad touchBegan:(CGPoint)touch
{
    self.pointBegan = touch;
    
    self.pointChanged = CGPointZero;
    self.pointEnded = CGPointZero;
    /*[UIView animateWithDuration:0.3
                     animations:^{
                         self.buttonExit.alpha = 0;
                         self.buttonClean.alpha = 0;
                     }];*/
    
    [self _didCalculatePositionalRatioPoint:[self positionRatioFromPoint:self.pointBegan]
                                 touchState:MZDrawpadTouchStateBegan];
}

-(void)bezierDraw:(MZBezierDrawView *)drawpad touchMoved:(CGPoint)touch
{
    self.pointChanged = touch;
}

-(void)bezierDraw:(MZBezierDrawView *)drawpad touchEnded:(CGPoint)touch
{
    self.pointEnded = touch;
    self.pointChanged = CGPointZero;
    /*[UIView animateWithDuration:0.3
                     animations:^{
                         self.buttonExit.alpha = 1;
                         self.buttonClean.alpha = 1;
                     }];*/
    
    [self _didCalculatePositionalRatioPoint:[self positionRatioFromPoint:self.pointEnded]
                                 touchState:MZDrawpadTouchStateEnded];
}

-(CGPoint) positionRatioFromPoint:(CGPoint)point
{
    CGPoint ratioPoint = CGPointZero;
    //self.view.bounds.size.height
    ratioPoint.x = ( point.x/self.drawCanvasView.frame.size.width);
    ratioPoint.y = ( point.y/self.drawCanvasView.frame.size.height);
    
    return ratioPoint;
}

- (void)_handleTimer:(NSTimer*)timer
{
    if (self.pointChanged.x == 0 &&
        self.pointChanged.y == 0)
        return;
  
    [self _didCalculatePositionalRatioPoint:[self positionRatioFromPoint:self.pointChanged]
                                 touchState:MZDrawpadTouchStateMoved];
    self.pointChanged = CGPointZero;
}


-(void)setTouchInputSampling:(NSTimeInterval)samplingTimeInterval
{
    [self.samplingTimer invalidate];
    self.samplingTimer = nil;
    
    self.samplingTimer =
        [NSTimer scheduledTimerWithTimeInterval:samplingTimeInterval
                                         target:self
                                       selector:@selector(_handleTimer:)
                                       userInfo:nil
                                        repeats:YES];
}

- (IBAction)cleanDrawView:(id)sender{
    
    [self.drawCanvasView clean];
    
    [self _didCleanDrawView];
 
}

//////////////////////////////////////////////////////////////////////////
/// Drawpad Widget Communication Methods
//////////////////////////////////////////////////////////////////////////

- (void)_didCalculatePositionalRatioPoint:(CGPoint)point touchState:(MZDrawpadTouchState)state
{
    NSString *widget = @"drawpad";
    NSString *component = @"touch";
    NSDictionary *value =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:point.x],@"x",
     [NSNumber numberWithFloat:point.y],@"y", nil];
    
    NSString *event;
    switch (state) {
        case MZDrawpadTouchStateBegan:
            event = @"touchBegin";
            break;
        case MZDrawpadTouchStateMoved:
            event = @"touchMove";
            break;
        case MZDrawpadTouchStateEnded:
            event = @"touchEnd";
            break;
        default:
            event = @"touchEnd";
            break;
    }
    
    NSDictionary *dataProtocol = [NSDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

-(void)_didCleanDrawView
{
    NSString *widget = @"drawpad";
    NSString *component = @"clean";
    NSString *value = @"";
    NSString *event = @"press";
    
    NSMutableDictionary *dataProtocol = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    self.messageSignaling = [[MZMessage alloc] initWithAction:MZMessageActionSignal data:dataProtocol];

    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:dataProtocol completion:nil];
}

@end
