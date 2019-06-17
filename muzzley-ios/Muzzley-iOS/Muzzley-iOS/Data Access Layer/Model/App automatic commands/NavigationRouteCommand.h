//
//  MuzCommand.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 3/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

@interface NavigationRouteCommand : NSObject

@property (nonatomic, readonly) NSURL *url;

- (instancetype)initWithUrl:(NSURL *)url;

@end
