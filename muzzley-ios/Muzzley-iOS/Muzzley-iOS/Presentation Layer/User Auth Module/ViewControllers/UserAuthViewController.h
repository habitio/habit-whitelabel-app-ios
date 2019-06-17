//
//  MZViewControllerLogIn.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 22/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "BaseViewController.h"

#import "UserAuthInteractor.h"
#import "UserAuthWireframe.h"
#import "UserAuthDelegate.h"


//@class MZScrollGalleryView;

@interface UserAuthViewController : BaseViewController < UserAuthInteractorOutput >

@property (nonatomic, weak) id<UserAuthDelegate> delegate;
@property (nonatomic, readonly) UserAuthInteractor *interactor;
@property (nonatomic, readonly) UserAuthWireframe *wireframe;


- (instancetype)initWithWireframe:(UserAuthWireframe *)wireframe
                       interactor:(UserAuthInteractor *)interactor;

//- (void)beginFacebookLoginAuthentication;
//- (void)beginGooglePlusLoginAuthentication;
- (void)beginSignInAuthentication;
- (void)beginSignUp;
- (void)fadeInUI;
- (void)fadeOutUI;
@end
