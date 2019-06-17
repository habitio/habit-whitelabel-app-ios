//
//  MZDiscoveryRecipeInteractor.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZDiscoveryRecipeInteractorIO.h"

@interface MZDiscoveryRecipeInteractor : NSObject <MZDiscoveryRecipeInteractorInput>

@property (nonatomic, weak) id<MZDiscoveryRecipeInteractorOutput> output;

- (instancetype)initWithURL:(NSURL *)url;

@end
