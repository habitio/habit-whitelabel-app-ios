//
//  ExecuteCommand.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 12/3/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

@interface ExecuteCommand : NSObject

@property (nonatomic, readonly) NSDictionary *payload;

- (instancetype)initWithUrl:(NSURL *)url;

@end
