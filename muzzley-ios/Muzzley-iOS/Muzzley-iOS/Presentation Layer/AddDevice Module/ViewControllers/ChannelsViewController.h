//
//  ChannelsViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

#define CURRENT_PASS 1000
#define NEW_PASS 2000


@class ChannelsViewController;
@protocol ChannelsDelegate <NSObject>

- (void)channelVC:(ChannelsViewController *)channelsVC didSelectChannels:(NSArray *)array;
- (NSString *)selectedProfileIdentifier;

@optional
- (void) didPassSetup:(NSString*)pass forChannelId:(NSString*)channelId andPassType:(int)passType;

@end

@interface ChannelsViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *datasourceArray;
@property (nonatomic, weak) id<ChannelsDelegate> delegate;

- (void) updateView;
- (void) setSelectChannelsButtonInteraction:(BOOL)enabled;
- (void) showPasswordRequest:(int)passType forChannelId:(NSString*)channeldId;
- (void) showError:(NSError*)error;
- (void) hideLoading;

@end
