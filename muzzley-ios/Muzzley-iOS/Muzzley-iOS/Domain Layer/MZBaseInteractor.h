//
//  MZBaseInteractor.h
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

#import "MZBaseInteractorIO.h"


@interface MZBaseInteractor : NSObject <MZBaseInteractorInput>

+ (BOOL) isArrayContainsAnyArray:(NSArray*)src lookFor:(NSArray*)lookFor;
+ (BOOL) isArrayContainsAllArray:(NSArray*)src lookFor:(NSArray*)lookFor;
+ (NSArray*) arrayOfCommonElements:(NSArray*)src lookFor:(NSArray*)lookFor;

@end
