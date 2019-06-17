//
//  MZAudioProcessor.m
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 25/08/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

#import "MZAudioProcessor.h"
#import <AudioToolbox/AudioToolbox.h>

#define kOutputBus 0
#define kInputBus 1


@interface MZAudioProcessor ()
{
    AudioComponentInstance _audioUnit;
    TPCircularBuffer _circularBufferSpeakers;
    TPCircularBuffer _circularBufferMicro;
}

@end

@implementation MZAudioProcessor


static OSStatus MicroRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData)
{
    MZAudioProcessor *processor = (__bridge MZAudioProcessor *)inRefCon;
    
    // Render audio into buffer
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mNumberChannels = 1;
    bufferList.mBuffers[0].mData = malloc( inNumberFrames * 2 );
    bufferList.mBuffers[0].mDataByteSize = inNumberFrames * sizeof(SInt16) * 2;
    OSStatus status = AudioUnitRender(processor->_audioUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      kInputBus,
                                      inNumberFrames,
                                      &bufferList);
    
    [processor hasError:status:__FILE__:__LINE__];
    
    TPCircularBuffer *circularBuffer = [processor microShouldUseCircularBuffer];
    
    [processor appendDataToCircularBuffer:circularBuffer fromAudioBufferList:&bufferList];
    
    [processor.delegate didRenderMicro:&bufferList];
    
    // clean up the buffer
    free(bufferList.mBuffers[0].mData);
    
    return noErr;
}



static OSStatus SpeakersRenderCallback(void                        *inRefCon,
                                     AudioUnitRenderActionFlags  *ioActionFlags,
                                     const AudioTimeStamp        *inTimeStamp,
                                     UInt32                      inBusNumber,
                                     UInt32                      inNumberFrames,
                                     AudioBufferList             *ioData){
    
    
    MZAudioProcessor *processor = (__bridge MZAudioProcessor*)inRefCon;
    
    TPCircularBuffer *circularBuffer = [processor microShouldUseCircularBuffer];
    if( !circularBuffer ){
        AudioUnitSampleType *left  = (AudioUnitSampleType*)ioData->mBuffers[0].mData;
        for(int i = 0; i < inNumberFrames; i++ ){
            left[  i ] = 0.0f;
        }
        return noErr;
    };
    
    int32_t bytesToCopy = ioData->mBuffers[0].mDataByteSize;
    SInt16* outputBuffer = ioData->mBuffers[0].mData;
    
    int32_t availableBytes;
    SInt16 *sourceBuffer = TPCircularBufferTail(circularBuffer, &availableBytes);
    
    int32_t amount = MIN(bytesToCopy,availableBytes);
    
    memcpy(outputBuffer, sourceBuffer, amount);
    TPCircularBufferConsume(circularBuffer,amount);
    
    return noErr;
}

- (MZAudioProcessor*)init
{
    self = [super init];
    if (self) {
        
        [self circularBuffer:[self speakersShouldUseCircularBuffer] withSize:24576*5];
        [self circularBuffer:[self microShouldUseCircularBuffer] withSize:24576*5];
       
        [self initializeAudio];
    }
    return self;
}

- (void)initializeAudio
{
    OSStatus status;
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output; // we want to ouput
    desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(NULL, &desc);
    
    status = AudioComponentInstanceNew(component, &_audioUnit);
    [self hasError:status:__FILE__:__LINE__];
    
    UInt32 flag = 1;
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO, // use io
                                  kAudioUnitScope_Output, // scope to output
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    [self hasError:status:__FILE__:__LINE__];
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO, // use io
                                  kAudioUnitScope_Input, // scope to input
                                  kInputBus, // select input bus (1)
                                  &flag, // set flag
                                  sizeof(flag));
    [self hasError:status:__FILE__:__LINE__];
    
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate        = 8000 ;
    audioFormat.mFormatID          = kAudioFormatLinearPCM;
    //    audioFormat.mFormatID          = kAudioFormatAppleIMA4;
    audioFormat.mFormatFlags       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    //    audioFormat.mFormatFlags       = kCAFLinearPCMFormatFlagIsLittleEndian;
    //    audioFormat.mFormatFlags       = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    //    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kAudioFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    //    audioFormat.mFormatFlags = 0;
    //    audioFormat.mBitsPerChannel    = 8 * sizeof(SInt16);
    //    audioFormat.mBitsPerChannel    = 16 * sizeof(SInt16);
    audioFormat.mBitsPerChannel    = 16;
    audioFormat.mFramesPerPacket   = 1;
    audioFormat.mChannelsPerFrame  = 1;
    //    audioFormat.mBytesPerFrame     = audioFormat.mBytesPerPacket = sizeof(SInt16)*audioFormat.mChannelsPerFrame;
    audioFormat.mBytesPerPacket    = audioFormat.mBytesPerFrame = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame;
    //    audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = 1 * audioFormat.mChannelsPerFrame;
    
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    [self hasError:status:__FILE__:__LINE__];
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    [self hasError:status:__FILE__:__LINE__];

    
    AURenderCallbackStruct callbackStruct;
//    callbackStruct.inputProc = SpeakersRenderCallback;
//    callbackStruct.inputProcRefCon = (__bridge void *)(self);
//
//    status = AudioUnitSetProperty(_audioUnit,
//                               kAudioUnitProperty_SetRenderCallback,
//                               kAudioUnitScope_Global,
//                               kOutputBus,
//                               &callbackStruct,
//                               sizeof(callbackStruct));
//    [self hasError:status:__FILE__:__LINE__];
    
    callbackStruct.inputProc = MicroRenderCallback; // recordingCallback pointer
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    // set input callback to recording callback on the input bus
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    [self hasError:status:__FILE__:__LINE__];
    
    flag = 0;

    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    [self hasError:status:__FILE__:__LINE__];

    status = AudioUnitInitialize(_audioUnit);
    [self hasError:status:__FILE__:__LINE__];
}


#pragma mark controll stream

-(void)start
{
    PermissionBlock permissionBlock = ^(BOOL granted) {
        if (granted)
        {
            UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            OSStatus status = AudioOutputUnitStart(_audioUnit);
            [self hasError:status:__FILE__:__LINE__];
        }
    };
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
                                              withObject:permissionBlock];
    }
    else
    {
        OSStatus status = AudioOutputUnitStart(_audioUnit);
        [self hasError:status:__FILE__:__LINE__];
    }
}

-(void)stop
{
    // stop the audio unit
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    [self hasError:status:__FILE__:__LINE__];
}


-(void)circularBuffer:(TPCircularBuffer *)circularBuffer withSize:(int)size
{
    TPCircularBufferInit(circularBuffer,size);
}


-(void)appendDataToSpeakersCircularBufferFromAudioBufferList:(AudioBufferList*)audioBufferList
{
    [self appendDataToCircularBuffer:[self speakersShouldUseCircularBuffer] fromAudioBufferList:audioBufferList];
}


-(void)appendDataToMicroCircularBufferFromAudioBufferList:(AudioBufferList*)audioBufferList
{
    [self appendDataToCircularBuffer:[self microShouldUseCircularBuffer] fromAudioBufferList:audioBufferList];
}

- (void)appendDataToCircularBuffer:(TPCircularBuffer *)circularBuffer fromAudioBufferList:(AudioBufferList*)audioBufferList
{
    NSLog(@"data byte size %d", (unsigned int)audioBufferList->mBuffers[0].mDataByteSize);
    TPCircularBufferProduceBytes(circularBuffer,
                                 audioBufferList->mBuffers[0].mData,
                                 audioBufferList->mBuffers[0].mDataByteSize);
}


- (void)freeCircularBuffer:(TPCircularBuffer *)circularBuffer
{
    TPCircularBufferClear(circularBuffer);
    TPCircularBufferCleanup(circularBuffer);
}


- (TPCircularBuffer *) speakersShouldUseCircularBuffer
{
    return &_circularBufferSpeakers;
}


- (TPCircularBuffer *) microShouldUseCircularBuffer
{
    return &_circularBufferMicro;
}


#pragma mark Error handling

-(void)hasError:(int)statusCode:(char*)file:(int)line
{
    if (statusCode) {
        printf("Error Code responded %d in file %s on line %d\n", statusCode, file, line);
        exit(-1);
    }
}

@end
