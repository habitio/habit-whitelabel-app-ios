//
//  MZGoogleAuthenticationWebService.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

@class MZGoogleAuthenticationWebService;
@protocol MZGoogleAuthenticationWebServiceDelegate <NSObject>

- (void)googleAuthenticationWebService:(MZGoogleAuthenticationWebService*)googleAuthenticationWebService
               didFinishedAuthWithUser:(NSDictionary *)user error:(NSError *)error;


- (void)googleAuthenticationWebService:(MZGoogleAuthenticationWebService*)googleAuthenticationWebService
               didDisconnectWithError:(NSError *)error;

@end

@interface MZGoogleAuthenticationWebService : NSObject <GPPSignInDelegate>

@property (nonatomic,weak) id<MZGoogleAuthenticationWebServiceDelegate> delegate;

- (void)authenticateWithClientId:(NSString *)clientId;
- (void)disconnect;

@end
