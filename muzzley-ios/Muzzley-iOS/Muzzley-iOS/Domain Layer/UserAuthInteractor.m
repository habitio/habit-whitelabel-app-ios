//
//  MZLogInInteractor.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "UserAuthInteractor.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <GoogleSignIn/GoogleSignIn.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

//#import "MZGoogleAuthenticationWebService.h"

@interface UserAuthInteractor ()// <GIDSignInDelegate, PopupContentViewDelegate>//<MZGoogleAuthenticationWebServiceDelegate>
{
//	KLCPopup * _popupView;
}
//@property(nonatomic, strong) MZGoogleAuthenticationWebService *googleAuth;
@property(nonatomic, strong) FBSDKLoginManager *facebookAuth;
@end

@implementation UserAuthInteractor

- (id)init
{
    self = [super init];
    if (self) {
//        self.facebookAuth = [[FBSDKLoginManager alloc] init];
//        [GIDSignIn sharedInstance].delegate = self;
		
        //[self.facebookAuth setLoginBehavior:FBSDKLoginBehaviorWeb];
    }
    return self;
}

#pragma mark - Interactor Input
- (void)logIn
{

}



// Login via Facebook
- (void)logInWithFacebook {
    __typeof__(self) __weak welf = self;
//	
// 
//	Reachability *reachability = [Reachability reachabilityForInternetConnection];
//	NetworkStatus internetStatus = [reachability currentReachabilityStatus];
//	if (internetStatus == NotReachable)
//	{
//		[self.output logInOperationDidFailWithError:
//		 [self _errorWithTitle:NSLocalizedString(@"mobile_no_internet_title", @"") description:NSLocalizedString(@"mobile_no_internet_text", @"")]];
//		return;
//	}
//    
//    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
//    // Define extended user permissions from facebook ex:(email)
//    NSArray *permissions = @[@"public_profile", @"email"];
//    
//    [self.facebookAuth logInWithReadPermissions:permissions fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        
//        if (error || result.isCancelled) {
//            [welf closeMuzzleySession];
//            [welf.output logInOperationDidFailWithError:[welf _facebookErrorFromError:error]];
//            return;
//        }
//            
//        // check for  declined permission email
//        if (![result.grantedPermissions containsObject:@"email"]) {
//            [welf closeMuzzleySession];
//            [welf.output logInOperationDidFailWithError: [welf _errorWithTitle:NSLocalizedString(@"mobile_facebook_login_failed_title", @"") description:NSLocalizedString(@"mobile_facebook_login_permission_text", @"")]];
//            return;
//        }
//        
//        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
//        [parameters setValue:@"id,name,email" forKey:@"fields"];
//        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
//                                                                       parameters:parameters];
//        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//            if (error) {
//                [welf closeMuzzleySession];
//                [welf.output logInOperationDidFailWithError: [welf _errorWithTitle:NSLocalizedString(@"mobile_facebook_login_failed_title", @"") description:error.localizedDescription]];
//                return;
//            
//            } else {
//                
//                FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
//                FBSDKProfile *userProfile = [FBSDKProfile currentProfile];
//                NSString *email = [result isKindOfClass:[NSDictionary class]] ? result[@"email"] : @"";
//				//NSLog(email);
//                // Login if data is valid
//                NSDictionary *logInParameters = [welf _logInParametersFromUser:userProfile email:email accessToken:accessToken];
//                [welf _logInOnMuzzleyWithParameters:logInParameters];
//            }
//        }];
//    }];
}


@end
