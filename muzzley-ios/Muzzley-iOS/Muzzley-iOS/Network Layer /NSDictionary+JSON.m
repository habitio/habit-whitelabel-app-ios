//
//  NSDictionary+JSON.m
//  moved from muzzley-sdk-ios
//
//  Created by Hugo Sousa on 20/12/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (NSDictionary *)dictionaryFromContentsOfJSONString:(NSString *)jsonString
{
	//NSJSONReadingMutableContainers: The arrays and dictionaries created will be mutable. Good if you want to add things to the containers after parsing it.
	//NSJSONReadingMutableLeaves: The leaves (i.e. the values inside the arrays and dictionaries) will be mutable. Good if you want to modify the strings read in, etc.
	//NSJSONReadingAllowFragments: Parses out the top-level objects that are not arrays or dictionaries.
	
	//id jsonString1 = [NSNumber numberWithBool:YES];
	__autoreleasing NSError *error = nil;
	
	if (jsonString == nil) {
		return nil;
	}
	id result = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
												options:kNilOptions
												  error:&error];
	
	if (error != nil) {
		NSLog(@"NSJSONSerialization error: %@",error);
		return nil;
	}
	return result;
}

+ (NSDictionary *)dictionaryFromContentsOfJSONData: (NSData *)jsonData
{
	//NSJSONReadingMutableContainers: The arrays and dictionaries created will be mutable. Good if you want to add things to the containers after parsing it.
	//NSJSONReadingMutableLeaves: The leaves (i.e. the values inside the arrays and dictionaries) will be mutable. Good if you want to modify the strings read in, etc.
	//NSJSONReadingAllowFragments: Parses out the top-level objects that are not arrays or dictionaries.
	if (jsonData == nil) {
		return nil;
	}
	
	__autoreleasing NSError  *error = nil;
	id result = [NSJSONSerialization JSONObjectWithData: jsonData
												options: kNilOptions
												  error: &error];
	if (error != nil) {
		NSLog(@"NSJSONSerialization error: %@",error);
		return nil;
	}
	return result;
}


- (NSData *)toJSONData
{
	NSError *error = nil;
	id result = [NSJSONSerialization dataWithJSONObject: self
												options: kNilOptions
												  error: &error];
	if (error != nil) return nil;
	return result;
}
@end
