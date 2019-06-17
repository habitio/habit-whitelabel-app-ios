//
//  MZFoscamInteractorHelper.m
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 07/11/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

#import "MZFoscamInteractorHelper.h"
//#import "SSNetworkInfo+Additions.h"
#import "TPCircularBuffer.h"
#import "FCInputAudio.h"

//#include "libavutil/version.h"
//#include "libavutil/log.h"

//#include "libavcodec/avcodec.h"
//#include "libswscale/swscale.h"

//#define IJKVERSION_GET_MAJOR(x)     ((x >> 16) & 0xFF)
//#define IJKVERSION_GET_MINOR(x)     ((x >>  8) & 0xFF)
//#define IJKVERSION_GET_MICRO(x)     ((x      ) & 0xFF)

#define kOutputBus 0
#define kInputBus 1


@interface MZFoscamInteractorHelper  ()
{
    FOSHANDLE _handle;
    FCInputAudio *_audioOperation;
    BOOL _isMicroOn;
    AudioStreamBasicDescription _audio_fmt;
}

@end

typedef void(^RunFun)(void* param);


@implementation MZFoscamInteractorHelper

//+ (void) getVersion
//{
//    av_log(NULL, AV_LOG_INFO, "%-*s: %s\n", 13, "FFmpeg", av_version_info());
//    av_log(NULL, AV_LOG_INFO, "%-*s: %u.%u.%u\n", 13, "libavutil",
//           (unsigned int)IJKVERSION_GET_MAJOR(avutil_version()),
//           (unsigned int)IJKVERSION_GET_MINOR(avutil_version()),
//           (unsigned int)IJKVERSION_GET_MICRO(avutil_version()));
//    av_log(NULL, AV_LOG_INFO, "%-*s: %u.%u.%u\n", 13, "libavcodec",
//           (unsigned int)IJKVERSION_GET_MAJOR(avcodec_version()),
//           (unsigned int)IJKVERSION_GET_MINOR(avcodec_version()),
//           (unsigned int)IJKVERSION_GET_MICRO(avcodec_version()));
//    av_log(NULL, AV_LOG_INFO, "%-*s: %u.%u.%u\n", 13, "libswscale",
//           (unsigned int)IJKVERSION_GET_MAJOR(swscale_version()),
//           (unsigned int)IJKVERSION_GET_MINOR(swscale_version()),
//           (unsigned int)IJKVERSION_GET_MICRO(swscale_version()));
//}



- (void)loginToId:(NSString*)identifier
         withUser:(NSString *)user
          andPass:(NSString *)pass
    andCompletion:(void (^)(NSError *))completion
{

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
//       /* ret = FOS_StartEZlink2([identifier UTF8String],
//                               "Vodafone-DA3E75",
//                               "0C0C019A55",//"calcada#portuguesa.",
//                               phoneAddr.s_addr,
//                               &getNode,
//                               12000,
//                               0);*/
//        
//        ret = FOS_StartEZlink([identifier UTF8String],
//                               "Vodafone-DA3E75",
//                               "0C0C019A55",//"calcada#portuguesa.",
//                               &getNode,
//                               12000);
//        
//        DLog(@"FOS_StartEZlink2 return is %d",ret);
//        
//        struct in_addr addr = {getNode.ip};
//        char ip[128] = {0};
//        strcpy(ip, inet_ntoa(addr));
//        
//        [self loginToIp:[NSString stringWithFormat:@"%s", ip] withUser:user andPass:pass andCompletion:completion];
//        
//    });
    
}


- (void) loginToIp:(NSString*)ip withPort:(int)port andUser:(NSString*)user andPass:(NSString*)pass andCompletion:(void (^)(NSError* error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FOSCMD_RESULT ret = 0;

        char* ipChar = [ip UTF8String];
        char* usr = [user UTF8String];
        char* pwd = [pass UTF8String];
        
  
        //FOSCNTYPE_P2P?
        _handle = FosSdk_Create(ipChar, "", usr, pwd, port, port, FOSIPC_H264, FOSCNTYPE_IP);
        if (_handle == FOSHANDLE_INVALID) {
            [self stopTalkMicro];
            return;
        }
        
        int usrPrivilege = 0;
        ret = FosSdk_Login(_handle, &usrPrivilege, 500);
        if (ret != FOSCMDRET_OK)
        {
            [self stopTalkMicro];

            if(ret == FOSCMDRET_EXCEEDMAXUSR)
            {
                DLog(@"FosSdk_OpenTalk FOSCMDRET_EXCEEDMAXUSR")
                
                UIAlertController * alertController = [UIAlertController
                                                       alertControllerWithTitle:NSLocalizedString(@"mobile_error_title", comment: @"")
                                                       message:NSLocalizedString(@"mobile_error_max_users", comment: @"")
                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               return;
                                           }];
                
                
                [alertController addAction:okAction];
                
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:NO completion:^{
                    completion([NSError errorWithDomain:MZFoscamInteractorErrorDomain code:FOSCMDRET_EXCEEDMAXUSR userInfo:nil]);
                    return;
                }];
            }

            
            UIAlertController * alertController = [UIAlertController
                                                   alertControllerWithTitle:NSLocalizedString(@"mobile_error_title", comment: @"")
                                                   message:NSLocalizedString(@"mobile_error_text", comment: @"")
                                                   preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           return;
                                       }];
            
            
            [alertController addAction:okAction];
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:NO completion:^{
                if (ret == FOSUSRRET_USRNAMEORPWD_ERR)
                    completion([NSError errorWithDomain:MZFoscamInteractorErrorDomain code:FOSUSRRET_USRNAMEORPWD_ERR userInfo:nil]);
                else
                    completion([NSError errorWithDomain:MZFoscamInteractorErrorDomain code:ret userInfo:nil]);
                return;
            }];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            completion(nil);
        });
    
    });
}

- (void) microphone_on
{
    [self audioInputInit];
    [self startTalkMicro];
}

- (void) microphone_off
{
    [self stopTalkMicro];
}


- (void)audioInputInit{
    _audioOperation = [[FCInputAudio alloc] init];
    
    bzero(&_audio_fmt, sizeof(AudioStreamBasicDescription));
    _audio_fmt.mSampleRate = 8000;
    _audio_fmt.mFormatID = kAudioFormatLinearPCM;
    _audio_fmt.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _audio_fmt.mBytesPerPacket = 2;
    _audio_fmt.mBytesPerFrame = 2;
    _audio_fmt.mFramesPerPacket = 1;
    _audio_fmt.mChannelsPerFrame = 1;
    _audio_fmt.mBitsPerChannel = 16;
}

- (void)RunInThread :(RunFun) fun {
    fun(NULL);
}

- (void) startTalkMicro
{
    if (_handle == FOSHANDLE_INVALID)
        return;
	
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    FOSCMD_RESULT ret = FosSdk_OpenTalk(_handle, 5000);
	
	if (ret != FOSCMDRET_OK){
        
        switch (ret) {
            case FOSCMDRET_FAILD:
                DLog(@"FosSdk_OpenTalk FOSCMDRET_FAILD")
                break;
			case FOSCMDRET_EXCEEDMAXUSR:
			{
                DLog(@"FosSdk_OpenTalk FOSCMDRET_EXCEEDMAXUSR")
                break;
			}
            case FOSUSRRET_USRNAMEORPWD_ERR:
                DLog(@"FosSdk_OpenTalk FOSUSRRET_USRNAMEORPWD_ERR")
                break;
            default:
                 DLog(@"FosSdk_OpenTalk ")
                break;
        }
        
        NSString * message = NSLocalizedString(@"mobile_error_text", comment: @"");
        if(ret == FOSCMDRET_EXCEEDMAXUSR)
        {
            message = NSLocalizedString(@"mobile_error_max_users", comment: @"");
        }
        UIAlertController * alertController = [UIAlertController
                                               alertControllerWithTitle:NSLocalizedString(@"mobile_error_title", comment: @"")
                                               message:message
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
        
        
        [alertController addAction:okAction];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:NO completion:^{
            return;
        }];
        
        
        
        _isMicroOn = NO;
        [self stopTalkMicro];
        return;
    }
     _isMicroOn = YES;
    [_audioOperation InitAudio:&_audio_fmt :120*8 :^(const void *frame, int size, int index, const AudioTimeStamp *time, void *userdata){

		if (_isMicroOn) {
            FOSCMD_RESULT res = FosSdk_SendTalkData(_handle, (char *)frame, size);
            if (FOSCMDRET_OK != res) {
                DLog(@"send talk error");
            } else {
                DLog(@"send talk ok");
            }
        }
        
    } :NULL];

//        dispatch_async(dispatch_get_main_queue(), ^(){
//        });
//    });
}


- (void) stopTalkMicro
{
    [_audioOperation ReleaseAudio];
    
    if (_handle == FOSHANDLE_INVALID)
        return;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FOSCMD_RESULT ret = FosSdk_CloseTalk(_handle, 500);
        if (ret != FOSCMDRET_OK) {
            _isMicroOn = NO;
            return;
        }
//    });
}


@end
