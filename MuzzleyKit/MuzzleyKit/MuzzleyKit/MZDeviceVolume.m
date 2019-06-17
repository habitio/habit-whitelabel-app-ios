//
//  MZDeviceVolume.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/04/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZDeviceVolume.h"

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MZMessage.h"
#import "MZUserClient.h"

@interface MZDeviceVolume()

@property (nonatomic,readwrite) BOOL active;

-(void)initializeVolumeButtonStealer;
-(void)volumeDown;
-(void)volumeUp;
-(void)applicationCameBack;
-(void)applicationWentAway;
@end

@implementation MZDeviceVolume

@synthesize active = _active;
@synthesize upBlock;
@synthesize downBlock;
@synthesize launchVolume;
@dynamic delegate;
void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             );

void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             ){
    const float *volumePointer = inData;
    float volume = *volumePointer;
    
    
    if( volume > [(__bridge MZDeviceVolume*)inClientData launchVolume] )
    {
        [(__bridge MZDeviceVolume*)inClientData volumeUp];
    }
    else if( volume < [(__bridge MZDeviceVolume*)inClientData launchVolume] )
    {
        [(__bridge MZDeviceVolume*)inClientData volumeDown];
    }
    
}

- (void)dealloc {
    
}

#pragma mark -
#pragma mark Singleton
+ (MZDeviceVolume *) sharedDeviceVolume
{
    static MZDeviceVolume *sharedDeviceVolume = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDeviceVolume = [MZDeviceVolume new];
    });
    
    return sharedDeviceVolume;
}

#pragma mark -
#pragma mark Initializers
- (id)init
{
    self = [super init];
    if (self) {
        
        //self.deviceVolumeViewController = [[MZDeviceVolumeViewController alloc] init];
    }
    return self;
}

- (void) configure:(NSDictionary *)parameters
{

}

-(void)volumeDown
{
    /*if (self.active) {
        
        AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void *)(self));
        
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:launchVolume];
        
        [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.1];
        
        if( self.downBlock )
        {
            self.downBlock();
        }
        
        [self.deviceVolumeViewController startVolumeDownAnimation];
        
        if ([self.delegate respondsToSelector:@selector(deviceVolume:didPressKey:)]) {
            [self.delegate deviceVolume:self didPressKey:MZDeviceVolumeKeyTypeDown];
        }
        [self _deviceVolume:self didPressKey:MZDeviceVolumeKeyTypeDown];
    }*/
}

-(void)volumeUp
{
    /*
    if (self.active) {
        
        AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void *)(self));
        
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:launchVolume];
        
        [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.1];
        
        if( self.upBlock )
        {
            self.upBlock();
        }
        
         [self.deviceVolumeViewController startVolumeUpAnimation];
        
        if ([self.delegate respondsToSelector:@selector(deviceVolume:didPressKey:)]) {
            [self.delegate deviceVolume:self didPressKey:MZDeviceVolumeKeyTypeUp];
        }
        [self _deviceVolume:self didPressKey:MZDeviceVolumeKeyTypeUp];
    }*/
}

-(void)applicationCameBack
{
    /*
    if (self.active) {
        
        [self cleanObservers];
        
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        
        SInt32  ambient = kAudioSessionCategory_AmbientSound;
        if (AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (ambient), &ambient)) {
            NSLog(@"*** Error *** could not set Session property to ambient.");
        }
        AudioSessionSetActive(YES);
        
        launchVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
        hadToLowerVolume = launchVolume == 1.0;
        hadToRaiseVolume = launchVolume == 0.0;
        justEnteredForeground = NO;
        
        if( hadToLowerVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.95];
            launchVolume = 0.95;
        }
        
        if( hadToRaiseVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.05];
            launchVolume = 0.05;
        }
        
        [self initializeVolumeButtonStealer];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
            [self applicationWentAway];
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
            if( ! justEnteredForeground )
            {
                [self applicationCameBack];
            }
            justEnteredForeground = NO;
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
           
            justEnteredForeground = YES;
            [self applicationCameBack];
            
        }];
    }*/
}

-(void)applicationWentAway
{
    /*
    if (self.active) {
       
        AudioSessionSetActive(NO);
        
        [self cleanObservers];
        
        if( hadToLowerVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        }
        
        if( hadToRaiseVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
        }
    }*/
}

-(void)initializeVolumeButtonStealer
{
    //AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void *)(self));
}

- (void)activate:(BOOL)yesOrNo
{
    /*
    self.active = yesOrNo;
    
    if (self.active) {
        
        [self cleanObservers];
        
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        
        SInt32  ambient = kAudioSessionCategory_AmbientSound;
        if (AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (ambient), &ambient)) {
            NSLog(@"*** Error *** could not set Session property to ambient.");
        }
        
        AudioSessionSetActive(YES);
        
        launchVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
        hadToLowerVolume = launchVolume == 1.0;
        hadToRaiseVolume = launchVolume == 0.0;
        justEnteredForeground = NO;
        
        if( hadToLowerVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.95];
            launchVolume = 0.95;
        }
        
        if( hadToRaiseVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.05];
            launchVolume = 0.05;
        }
        
        CGRect frame = CGRectMake(0, -100, 10, 0);
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:frame];
        [volumeView sizeToFit];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:volumeView];
        
        
        if (![[UIDevice currentDevice].systemVersion hasPrefix:@"7"]) {
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.deviceVolumeViewController.view];
        }
        
        [self initializeVolumeButtonStealer];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
            [self applicationWentAway];
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
            if( ! justEnteredForeground )
            {
                [self applicationCameBack];
            }
            justEnteredForeground = NO;
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
            
            //AudioSessionInitialize(NULL, NULL, NULL, NULL);
            //AudioSessionSetActive(YES);
            justEnteredForeground = YES;
            [self applicationCameBack];
            
        }];
        
    } else {
        
        AudioSessionSetActive(NO);
        [self.deviceVolumeViewController.view removeFromSuperview];
        
        [self cleanObservers];
        
        if( hadToLowerVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        }
        
        if( hadToRaiseVolume ) {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
        }
    }
    */
}

- (void)cleanObservers {
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification object:nil];
    
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void *)(self));
     */
}

//////////////////////////////////////////////////////////////////////////
/// DeviceVolume Component Delegate Methods
//////////////////////////////////////////////////////////////////////////
-(void)_deviceVolume:(MZDeviceVolume *)deviceVolume didPressKey:(MZDeviceVolumeKeyType)key
{
    /*
    NSString *widget = @"";
    NSString *component = @"remoteVolume";
    NSString *value = @"";
    
    if (key == MZDeviceVolumeKeyTypeDown) { value = @"down";
        NSLog(@"Down");
    } else if (key == MZDeviceVolumeKeyTypeUp) { value = @"up";
        NSLog(@"Up");
    }
    
    NSString *event = @"press";
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  widget,       @"w",
                                  component,    @"c",
                                  value,        @"v",
                                  event,        @"e", nil];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:nil];
     */
}

@end
