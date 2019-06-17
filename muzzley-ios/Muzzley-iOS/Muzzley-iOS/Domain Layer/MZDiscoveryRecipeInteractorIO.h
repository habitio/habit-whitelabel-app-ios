//
//  MZDiscoveryRecipeInteractorIO.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

@class MZDiscoveryProcess;
@class MZDiscoveryProcessStep;
@class MZDiscoveryProcessAction;


typedef void (^MZDiscoveryRequestActivationCallback) (NSArray * actionResult);


@protocol MZDiscoveryRecipeInteractorInput <NSObject>

- (void)requestDiscoveryProcessInfo;
- (void)startCustomAuthentication;
- (NSArray *) createActionResultsArrayWithArray:(NSArray *)array actionId:(NSString *)actionId;


@end


@protocol MZDiscoveryRecipeInteractorOutput <NSObject>

- (void)foundDiscoveryProcessInfo:(MZDiscoveryProcess *)discoveryProcess;
- (void)foundDiscoveryProcessStepInfo:(MZDiscoveryProcessStep *)discoveryProcessStep;
- (void)requestActivationAction:(MZDiscoveryProcessAction *)action callback:(void (^)(NSArray * actionResult))callback;


- (void)authenticationFailedWithError:(NSError *)error;
- (void)authenticationDidEndedWithSuccess;
- (void)authenticationDidEndedWithSuccessAndData:(NSDictionary*)data;


@end
