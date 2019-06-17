//
//  MZAudioProcessor.h
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 25/08/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TPCircularBuffer.h"

@protocol MZAudioProcessorDelegate  <NSObject>

- (void) didRenderSpeakers;
- (void) didRenderMicro:(AudioBufferList*) audioBufferList;

@end

@interface MZAudioProcessor : NSObject

@property(nonatomic, weak) id<MZAudioProcessorDelegate> delegate;


-(MZAudioProcessor*)init;

-(void)initializeAudio;

- (TPCircularBuffer *) speakersShouldUseCircularBuffer;
- (TPCircularBuffer *) microShouldUseCircularBuffer;

// control object
-(void)start;
-(void)stop;

-(void)appendDataToSpeakersCircularBufferFromAudioBufferList:(AudioBufferList*)audioBufferList;
-(void)appendDataToMicroCircularBufferFromAudioBufferList:(AudioBufferList*)audioBufferList;


@end
