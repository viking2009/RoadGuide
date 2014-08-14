//
//  NSString+MD5.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/14/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)MD5 {
    const char *s = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(s, (CC_LONG)strlen(s), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:(CC_MD5_DIGEST_LENGTH * 2)];
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [digest appendFormat:@"%02x",result[i]];
    
    return [NSString stringWithString:digest];
}

@end
