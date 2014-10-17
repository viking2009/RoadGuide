//
//  RGImageCache.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/14/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGImageCache.h"
#import "NSString+MD5.h"
#import "StandardPaths.h"

static inline NSString * RGImageCachePathFromURLRequest(NSURLRequest *request) {
    NSString *file = [[[[[[request URL] absoluteString] MD5] stringByAppendingDeviceHeightSuffix] stringByAppendingDeviceScaleSuffix] stringByAppendingPathExtension:@"png"];

    DLog(@"%@", [[NSFileManager defaultManager] normalizedPathForFile:file]);
    
    return [[NSFileManager defaultManager] pathForOfflineFile:file];
}

@implementation RGImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return [UIImage imageWithContentsOfFile:RGImageCachePathFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    if (image && request) {
        NSData *cacheImageData = UIImagePNGRepresentation(image);
        
        [cacheImageData writeToFile:RGImageCachePathFromURLRequest(request) atomically:YES];
    }
}

@end
