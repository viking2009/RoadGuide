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
    NSString *file = [[[[[request URL] absoluteString] MD5] stringByAppendingRetinaSuffix] stringByAppendingPathExtension:@"png"];

    return [[NSFileManager defaultManager] pathForOfflineFile:file];
}

@implementation RGImageCache

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    NSString *cacheImagePath = RGImageCachePathFromURLRequest(request);
    
    // check cache first
    UIImage *cachedImage = [self objectForKey:cacheImagePath];
    if (!cachedImage) {
        // check preinstalled maps
        NSString *preinstalledFilePath = [@"PreinstalledMaps.bundle" stringByAppendingPathComponent:[cacheImagePath lastPathComponent]];
        preinstalledFilePath = [[NSFileManager defaultManager] pathForResource:preinstalledFilePath];

        if ([[NSFileManager defaultManager] fileExistsAtPath:preinstalledFilePath]) {
            // load preinstalled map
            cachedImage = [UIImage imageWithContentsOfFile:preinstalledFilePath];
        } else {
            // load Offline data map
            cachedImage = [UIImage imageWithContentsOfFile:cacheImagePath];
        }
        
        if (cachedImage && request) {
            [self setObject:cachedImage forKey:cacheImagePath];
        }
    }
    
    return cachedImage;
}

- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    if (image && request) {
        NSString *cachedImagePath = RGImageCachePathFromURLRequest(request);
        NSData *cachedImageData = UIImagePNGRepresentation(image);
        
        [self setObject:image forKey:cachedImagePath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachedImagePath]) {
            [cachedImageData writeToFile:cachedImagePath atomically:YES];
        }
    }
}

@end
