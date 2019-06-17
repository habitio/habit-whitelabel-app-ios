//
//  main.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 21/11/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZAppDelegate.h"

int main(int argc, char *argv[])
{
    int ret = 0;
    @autoreleasepool {
        ret = UIApplicationMain(argc, argv, nil, NSStringFromClass([MZAppDelegate class]));
    }
    return ret;
}
