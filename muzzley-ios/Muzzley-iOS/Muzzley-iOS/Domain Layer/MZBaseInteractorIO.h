//
//  MZBaseInteractorIO.h
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//


@protocol MZBaseInteractorOutput <NSObject>

@end




@protocol MZBaseInteractorInput <NSObject>

@property (nonatomic, weak) id<MZBaseInteractorOutput> output;

@end
