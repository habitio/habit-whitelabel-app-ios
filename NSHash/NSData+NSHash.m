//
//  Copyright 2012 Christoph Jerolimov
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License
//

#import "NSData+NSHash.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSData (NSHash_AdditionalHashingAlgorithms)

- (NSData*) MD5 {
	unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
	CC_MD5(self.bytes, (unsigned int) self.length, output);
	return [NSMutableData dataWithBytes:output length:outputLength];
}

- (NSData*) SHA1 {
	unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
	CC_SHA1(self.bytes, (unsigned int) self.length, output);
	return [NSMutableData dataWithBytes:output length:outputLength];
}

- (NSData*) SHA256 {
	unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
	CC_SHA256(self.bytes, (unsigned int) self.length, output);
	return [NSMutableData dataWithBytes:output length:outputLength];
}

- (NSString *)HexRepresentationWithSpaces:(BOOL)spaces uppercase:(BOOL)uppercase {
    const unsigned char *bytes = (const unsigned char *)[self bytes];
    NSUInteger nbBytes = [self length];
    // If spaces is true, insert a space every this many input bytes (twice this many output characters).
    static const NSUInteger spaceEveryThisManyBytes = 4UL;
    // If spaces is true, insert a line-break instead of a space every this many spaces.
    static const NSUInteger lineBreakEveryThisManySpaces = 4UL;
    const NSUInteger lineBreakEveryThisManyBytes = spaceEveryThisManyBytes * lineBreakEveryThisManySpaces;
    NSUInteger strLen = 2 * nbBytes + (spaces ? nbBytes / spaceEveryThisManyBytes : 0);
    
    NSMutableString *hex = [[NSMutableString alloc] initWithCapacity:strLen];
    
    for (NSUInteger i = 0; i < nbBytes; ) {
        if (uppercase) {
            [hex appendFormat:@"%02X", bytes[i]];
        } else {
            [hex appendFormat:@"%02x", bytes[i]];
        }
        // We need to increment here so that the every-n-bytes computations are right.
        ++i;
        
        if (spaces) {
            if (i % lineBreakEveryThisManyBytes == 0) {
                [hex appendString:@"\n"];
            } else if (i % spaceEveryThisManyBytes == 0) {
                [hex appendString:@" "];
            }
        }
    }
    return hex;
}

@end
