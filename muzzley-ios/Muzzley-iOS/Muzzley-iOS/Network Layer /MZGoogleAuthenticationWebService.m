//
//  MZGoogleAuthenticationWebService.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 23/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZGoogleAuthenticationWebService.h"

@interface MZGoogleAuthenticationWebService ()

@property (nonatomic, assign) BOOL connecting;
@end

@implementation MZGoogleAuthenticationWebService
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.connecting = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UIApplicationDidBecomeActiveNotification:)
                                                     name:@"AbortGoogleAuthNotification"
                                                   object:nil];
    }
    return self;
}

- (void)authenticateWithClientId:(NSString *)clientId;
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = clientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusUserinfoEmail, kGTLAuthScopePlusUserinfoProfile ];
    
    signIn.delegate = self;
    
    self.connecting = YES;
    [signIn authenticate];
}

- (void)disconnect
{
    self.connecting = NO;
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
        GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
        
        NSString *email = auth.parameters[@"email"];
        if (!email) email = @"";
        
        NSString *accessToken = auth.parameters[@"access_token"];
        if (!accessToken) accessToken = @"";
        
        NSString *displayName = person.displayName;
        if (!displayName) displayName = @"";
        // append the query string ?sz=x
        NSString *imageUrl = person.image.url;
        if (!imageUrl) imageUrl = @"";
        
        NSString *identifier = person.identifier;
        if (!identifier) identifier = @"";
        
        NSDictionary *user = @{
                                @"email": email,
                                @"accessToken":accessToken,
                                @"name":displayName,
                                @"imageUrl":imageUrl,
                                @"identifier":identifier
                             };
    
        self.connecting = NO;
    
        if (error.code == -1) {
            error = [NSError errorWithDomain:@"MuzzleyDomain" code:0 userInfo:
                     @{
                       NSLocalizedDescriptionKey: NSLocalizedString(@"mobile_google_login_cancel_title", @""),
                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"mobile_google_login_error_text", @"")
                       }];
        }
    
    
        if ([self.delegate respondsToSelector:@selector(googleAuthenticationWebService:didFinishedAuthWithUser:error:)]) {
            [self.delegate googleAuthenticationWebService:self didFinishedAuthWithUser:user error:error];
        }
}

- (void)didDisconnectWithError:(NSError *)error
{
    self.connecting = NO;
    
    if ([self.delegate respondsToSelector:@selector(googleAuthenticationWebService:didDisconnectWithError:)]) {
        [self.delegate googleAuthenticationWebService:self didDisconnectWithError:error];
    }
}

- (void)UIApplicationDidBecomeActiveNotification:(id)notification
{
    if (self.connecting) {
        
        [self didDisconnectWithError:
            [NSError errorWithDomain:@"MuzzleyDomain" code:0 userInfo:
             @{
               @"Aborted": @"true",
               NSLocalizedDescriptionKey: NSLocalizedString(@"mobile_google_login_cancel_title", @""),
               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"mobile_google_login_error_text", @"")
               }]];
    }
}

@end
