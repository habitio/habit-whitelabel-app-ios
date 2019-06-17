//
//  MZLogInInteractorIO.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

@protocol UserAuthInteractorInput <NSObject>
- (void)logInWithFacebook;
- (void)logInWithGooglePlus;
- (void)logIn;
- (void)closeMuzzleySession;
@end


@protocol UserAuthInteractorOutput <NSObject>
- (void)logInOperationDidComplete;
- (void)logInOperationDidFailWithError:(NSError *)error;
@end