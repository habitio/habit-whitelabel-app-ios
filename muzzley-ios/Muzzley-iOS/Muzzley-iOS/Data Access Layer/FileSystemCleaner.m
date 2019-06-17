//
//  FileSystemCleaner.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/6/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "FileSystemCleaner.h"

@interface FileSystemCleaner ()
@property(nonatomic, copy) NSString *temporaryFolderPath;
@end

@implementation FileSystemCleaner

- (instancetype)init
{
    if (self = [super init]) {
        
        NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *userDomainCacheFolderPath = [pathList objectAtIndex:0];
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        
        NSString *bundleFolderPath = [userDomainCacheFolderPath stringByAppendingPathComponent:bundleName];
        
        _temporaryFolderPath = [bundleFolderPath stringByAppendingPathComponent:@"tmp"];
    }
    return self;
}

- (BOOL)cleanTemporaryFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success = YES;
    NSError *error = nil;
    NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:_temporaryFolderPath error:&error];
    if (!contentsOfDirectory) { return YES; }
    
    for (NSString *file in contentsOfDirectory) {
        NSString *path = [_temporaryFolderPath stringByAppendingPathComponent:file];
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success || error) {
            success = NO;
        }
    }
    return success;
}
@end
