//
//  MZStreamPlayerViewController.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 07/02/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZVideoPlayerViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "MZAdViewController.h"
#import "MZProgressView.h"

NSString *const MZVideoPlayerActionKey =    @"a";
NSString *const MZVideoPlayerDataKey =      @"d";

NSString *const MZVideoPlayerURLKey =               @"url";
NSString *const MZVideoPlayerGravityKey =           @"gravity";
NSString *const MZVideoPlayerOverlayDurationKey =   @"timeout";
NSString *const MZVideoPlayerDimensionKey =         @"dimension";
NSString *const MZVideoPlayerDimensionHeightKey =   @"h";
NSString *const MZVideoPlayerDimensionWidthKey =    @"w";
NSString *const MZVideoPlayerHTMLKey =              @"html";

NSString *const kMZVideoPlayerActionOverlay =  @"overlay";
NSString *const kMZVideoPlayerGravityTop =     @"top";
NSString *const kMZVideoPlayerGravityCenter =  @"center";
NSString *const kMZVideoPlayerGravityBottom =  @"bottom";

NSUInteger const kMediaControlsBarHeight = 44;
CGFloat const kMediaControlsVisibilityTimerDuration = 2.5;

@interface MZVideoPlayerViewController () <UIWebViewDelegate>

@property (nonatomic, strong) MZAdViewController *ad;

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) MPMoviePlayerController *mediaPlayer;
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UIView *mediaControlsView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) NSTimer *visibilityMediaControlsTimer;
@end

@implementation MZVideoPlayerViewController

#pragma mark - Dealloc
- (void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.visibilityMediaControlsTimer invalidate];
    self.visibilityMediaControlsTimer = nil;
}

#pragma mark - Initializers
- (id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone"
                                                                   bundle:[NSBundle mainBundle]];
    
    MZVideoPlayerViewController *streamPlayerViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZVideoPlayerViewController"];
    self = streamPlayerViewController;
    
    if (self) {
        self.parameters = parameters;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	 
    // Create video player
    NSString *urlString = self.parameters[MZVideoPlayerURLKey];
    //NSString *urlString = @"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8";
    if ( urlString && [urlString isKindOfClass:[NSString class]]) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        self.mediaPlayer = [MPMoviePlayerController new];
        [_mediaPlayer setMovieSourceType:MPMovieSourceTypeStreaming];
        [_mediaPlayer setControlStyle:MPMovieControlStyleNone];
        [_mediaPlayer.view setFrame: self.view.bounds];
        [self.view insertSubview:_mediaPlayer.view atIndex:0];
        
        [_mediaPlayer setContentURL:url];
        [_mediaPlayer play];
        
        // Register that the did finish notification (movie stopped)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaPlayerFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaPlayerPlaybackStateDidChangeCallback:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                object:nil];
    }
    
    
    // Create the tap gesture layer recognizer
    self.tapView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_tapView aboveSubview:_mediaPlayer.view];
    
    // Create tap gesture recognizer
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    // Set required taps and number of touches
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    // Add the gesture to the Media Controls View
    [_tapView addGestureRecognizer:tapGesture];
    
    // Create the media controls
    self.mediaControlsView = [[UIView alloc] initWithFrame:
                              CGRectMake(5, self.view.bounds.size.height - kMediaControlsBarHeight - 5,
                                         kMediaControlsBarHeight, kMediaControlsBarHeight)];
    self.mediaControlsView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75];
    self.mediaControlsView.layer.cornerRadius = 6;
    [self.view insertSubview:_mediaControlsView aboveSubview:_tapView];
    
    // Create Play Button
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mediaControlsView addSubview:_playButton];
    _playButton.frame = CGRectMake(0, 0, 44, 44);
    _playButton.center = CGPointMake(_playButton.frame.size.width * 0.5,
                                     _playButton.superview.bounds.size.height - _playButton.frame.size.height * 0.5);
    [_playButton addTarget:self
                     action:@selector(handlePlayButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    
    // Create Progress View
    //UIImage *minImage = [UIImage imageNamed: @"min.png"];
    //UIImage *maxImage = [UIImage imageNamed: @"max.png"];
    //UIImage *center = [UIImage imageNamed: @"center.png"];
    
    /*minImage = [minImage stretchableImageWithLeftCapWidth: 10.0
                                             topCapHeight: 0.0];
    
    maxImage = [maxImage stretchableImageWithLeftCapWidth: 10.0
                                             topCapHeight: 0.0];
    */
    
    //self.progressSlider = [[UISlider alloc] init];
    //_progressSlider.frame = CGRectMake(kMediaControlsBarHeight, 0, 300, kMediaControlsBarHeight);
    //[_progressSlider setMinimumTrackImage: minImage forState: UIControlStateNormal];
    //[_progressSlider setMaximumTrackImage: maxImage forState: UIControlStateNormal];
    //[_progressSlider setThumbImage: center forState: UIControlStateNormal];
    //[_progressSlider setMinimumTrackTintColor:[UIColor greenColor]];
    //[_progressSlider setMaximumTrackTintColor:[UIColor darkGrayColor]];
    //[_progressSlider setThumbTintColor:[UIColor whiteColor]];
    
    //[_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_mediaControlsView addSubview:_progressSlider];
    
    // Create the ad
    self.ad = [MZAdViewController new];
    [self.view insertSubview:_ad.view aboveSubview:_mediaControlsView];
}

#pragma mark - View Rotation
// iOS6
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _mediaPlayer.view.frame = self.view.bounds;
    _tapView.frame = self.view.bounds;
    _mediaControlsView.frame = CGRectMake(5, self.view.bounds.size.height - kMediaControlsBarHeight -5,
                                          kMediaControlsBarHeight, kMediaControlsBarHeight);
    _playButton.center = CGPointMake(_playButton.frame.size.width * 0.5,
                                     _playButton.superview.bounds.size.height - _playButton.frame.size.height * 0.5);
}

#pragma mark - Quit Activity flow
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)])
            [self.delegate widgetNeedsToDismiss:self];
    }
}

#pragma mark - Handle Protocol Signal
- (void)handleProtocolData:(NSDictionary *)protocolData responseCallback:(MZResponseBlock)response
{
    if (!protocolData && response) {
        response(nil,nil,NO);
        return;
    }
    
    if ([protocolData[MZVideoPlayerActionKey] isEqualToString:kMZVideoPlayerActionOverlay]) {
        [self showAdwithOptions:protocolData[MZVideoPlayerDataKey]];
    }
}

- (void)showAdwithOptions:(NSDictionary *)options
{
    NSUInteger w = 100;
    NSUInteger h = 100;
    
    // Dimension
    if (options[MZVideoPlayerDimensionKey] &&
        [options[MZVideoPlayerDimensionKey] isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dimension = options[MZVideoPlayerDimensionKey];
        if (dimension[MZVideoPlayerDimensionWidthKey]) {
            w = [dimension[MZVideoPlayerDimensionWidthKey] unsignedIntegerValue];
            if (w < 1 || w > 100) w = 100;
        }
        
        if (dimension[MZVideoPlayerDimensionHeightKey]) {
            h = [dimension[MZVideoPlayerDimensionHeightKey] unsignedIntegerValue];
            if (h < 1 || h > 100) h = 100;
        }
    }
    CGSize ratio = CGSizeMake(w, h);
    
    // Position in the screen
    MZAdViewGravity gravity = MZAdViewGravityCenter;
    if (options[MZVideoPlayerGravityKey] &&
        [options[MZVideoPlayerGravityKey] isKindOfClass:[NSString class]]) {
        
        if ([options[MZVideoPlayerGravityKey] isEqualToString:kMZVideoPlayerGravityTop]) {
            gravity = MZAdViewGravityTop;
        } else if ([options[MZVideoPlayerGravityKey] isEqualToString:kMZVideoPlayerGravityCenter]) {
            gravity = MZAdViewGravityCenter;
        } else if ([options[MZVideoPlayerGravityKey] isEqualToString:kMZVideoPlayerGravityBottom]) {
            gravity = MZAdViewGravityBottom;
        }
    }
    
    // Get timeout
    NSTimeInterval duration = 0;
    if (options[MZVideoPlayerOverlayDurationKey] &&
        [options[MZVideoPlayerOverlayDurationKey] isKindOfClass:[NSNumber class]]) {
        duration = [options[MZVideoPlayerOverlayDurationKey] unsignedIntegerValue];
    }
    
    // Get the source content to show as ad.
    // It can be a url or a html string.
    // Html string parameter has precedence over a url parameter.
    NSString *htmlString = nil;
    if (options[MZVideoPlayerHTMLKey] &&
        [options[MZVideoPlayerHTMLKey] isKindOfClass:[NSString class]]) {
        htmlString = options[MZVideoPlayerHTMLKey];
    }
    
    NSString *urlString;
    if (options[MZVideoPlayerURLKey] &&
        [options[MZVideoPlayerURLKey] isKindOfClass:[NSString class]]) {
        urlString = options[MZVideoPlayerURLKey];
        
        if (htmlString) {
            [_ad showAdWithHTMLString:htmlString ratioSize:ratio gravity:gravity duration:duration];
        } else if (urlString) {
            [_ad showAdWithURL:[NSURL URLWithString:urlString] ratioSize:ratio gravity:gravity duration:duration];
        }
    }
}

- (void)mediaPlayerFinishedCallback:(NSNotification*)notification {
    
    NSDictionary *notice = notification.userInfo;
    
    if (notice != nil) {
        NSError *errorInfo = notice[@"error"];
        
        if ( errorInfo != nil ) {
            UIAlertView *notice = [[UIAlertView alloc] initWithTitle:@"Error" message:[errorInfo localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notice show];
        }
    }
}

-(void)mediaPlayerPlaybackStateDidChangeCallback:(NSNotification*)notification
{
    MPMoviePlayerController *videoPlayer = notification.object;
    switch (videoPlayer.playbackState) {
            
        case MPMoviePlaybackStatePlaying:
            [_playButton setImage:[UIImage imageNamed:@"pauseButton"]
                         forState:UIControlStateNormal];
            
            [self scheduleVisibilityMediaControlsTimer];
            
            break;
            
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateInterrupted:
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward:
            
            [self.visibilityMediaControlsTimer invalidate];
            
            [_playButton setImage:[UIImage imageNamed:@"playButton"]
                         forState:UIControlStateNormal];
            
            _mediaControlsView.alpha = 1;
            break;
        default:
            break;
    }
}

- (void)handleTapGesture:(id)sender
{
    [self handlePlayButtonTouchUpInside:nil];
}

- (void)handlePlayButtonTouchUpInside:(UIButton *)playButton
{
    if (_mediaPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_mediaPlayer pause];
    } else if (_mediaPlayer.playbackState == MPMoviePlaybackStatePaused ||
               _mediaPlayer.playbackState == MPMoviePlaybackStateStopped ||
               _mediaPlayer.playbackState == MPMoviePlaybackStateInterrupted) {
        [_mediaPlayer play];
    }
}

/*
- (void)progressSliderValueChanged:(UISlider *)slider {
    NSLog(@"%f",_progressSlider.value);
}*/

- (void)scheduleVisibilityMediaControlsTimer
{
    [self.visibilityMediaControlsTimer invalidate];
    self.visibilityMediaControlsTimer = nil;
    
    self.visibilityMediaControlsTimer =
    [NSTimer scheduledTimerWithTimeInterval:kMediaControlsVisibilityTimerDuration
                                     target:self
                                   selector:@selector(handleVisibilityMediaControlsTimer:)
                                   userInfo:nil repeats:NO];
}

- (void)handleVisibilityMediaControlsTimer:sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _mediaControlsView.alpha = 0;
    }];
}

@end
