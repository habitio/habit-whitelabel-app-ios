//
//  MZFoscamViewController.m
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 25/08/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

#import "MZFoscamViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MZFoscamViewController  ()
{
    MZFoscamInteractor * _foscamInteractor;
    MZTileViewModel* _tileVM;
}

@end

@implementation MZFoscamViewController



- (id)initWithFrame:(CGRect)frame andTileVM:(MZTileViewModel*)tileVM
{
    self = [super initWithFrame:frame];
    if (self) {
        _foscamInteractor = [MZFoscamInteractor new];
        _tileVM = tileVM;
    }
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [_foscamInteractor getCameraVideoPath:_tileVM];
    
    [_foscamInteractor loginToId:@"13HY18ANWTZG12YV111AAZZZ" withUser:@"appviewer" andPass:@"appviewer181" andCompletion:^(NSError * error) {
        if (!error)
        {
//            [foscamInteractorHelper openAudioWithCompletion:^(NSError *error) {
//                <#code#>
//            }];
        }
    }];

//    [self loginAndOpenAudio];
}


//- (void) loginAndOpenAudio
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        FOSCMD_RESULT ret = 0;
//        FOSDISCOVERY_NODE getNode;
//        
//        NSString *phoneIP = [SSNetworkInfo currentIPAddress];
//        DLog(@"phoneIP:%@",phoneIP);
//        struct in_addr phoneAddr;
//        inet_aton([phoneIP UTF8String], &phoneAddr);
//        DLog(@"phoneAddr:%d",phoneAddr.s_addr);
//        
//        NSString * ssidStr = [UIDevice currentDevice].SSID;
//        DLog(@"SSID:%@",ssidStr);
//        char* ssid = [ssidStr UTF8String];
//
//        ret = FOS_StartEZlink2("13HY18ANWTZG12YV111AAZZZ",
//                               ssid,"calcada#portuguesa.",
//                               phoneAddr.s_addr,
//                               &getNode,
//                               12000,
//                               0);
//        
//        DLog(@"FOS_StartEZlink2 return is %d",ret);
//        
//        struct in_addr addr = {getNode.ip};
//        char ip[128] = {0};
//        strcpy(ip, inet_ntoa(addr));
//        
//        
//        int port = 88;
//        char usr[64] = "developer";
//        char pwd[64] = "Power181!";
//        
//        _handle = FosSdk_Create(ip, "", usr, pwd, port, port, FOSIPC_H264, FOSCNTYPE_IP);
//        if (_handle == FOSHANDLE_INVALID)
//            return;
//        
//        int usrPrivilege = 0;
//        ret = FosSdk_Login(_handle, &usrPrivilege, 500);
//        if (ret != FOSCMDRET_OK)
//            return;
//        
//        ret = FosSdk_OpenAudio(_handle, FOSSTREAM_MAIN, 500);
//        if (ret != FOSCMDRET_OK)
//            return;
//        
////        dispatch_async(dispatch_get_main_queue(), ^(){
////            [self playAudio];
////        });
//        
//    });
//}





//- (void) playAudio
//{
//    if (_handle == FOSHANDLE_INVALID)
//        return;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        FOSCMD_RESULT ret = FosSdk_OpenAudio(_handle, FOSSTREAM_SUB, 500);
//        if (ret != FOSCMDRET_OK)
//            return;
//        
//        FOSDEC_DATA* data = NULL;
//        
//        int outlen = 0;
//        while (_handle) {
//            if ( FOSCMDRET_OK == FosSdk_GetAudioData(_handle, (char**)&data, &outlen) && outlen>0)
//            {
//                if (data->type == FOSMEDIATYPE_AUDIO)
//                {
//                    AudioBufferList *theDataBuffer = (AudioBufferList*) malloc(sizeof(AudioBufferList) *1);
//                    theDataBuffer->mNumberBuffers = 1;
//                    theDataBuffer->mBuffers[0].mDataByteSize = outlen;
//                    theDataBuffer->mBuffers[0].mNumberChannels = data->media.audio.channel;
//                    theDataBuffer->mBuffers[0].mData = (SInt16*)data->data;
//                    
//                    [_audioProcessor appendDataToStreamCircularBufferFromAudioBufferList:theDataBuffer];
//                }
//            }
//            usleep(20*1000);
//        }
//    });
//}
//
//


- (void) microphone_on
{
    [foscamInteractor microphone_on];
}

- (void) microphone_off
{
    [foscamInteractor microphone_off];
}

@end
