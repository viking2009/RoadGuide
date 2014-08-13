//
//  RGConfiguration.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/12/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGConfiguration.h"
#import "NSUserDefaults+GroundControl.h"
#import "AFURLResponseSerialization.h"
#import "RGLanguage.h"

static NSString * const RGConfigurationURL = @"https://docs.google.com/uc?export=download&id=0Bx0hFmhr9oPRQVpmdjZfNEpHcUE";

@implementation RGConfiguration

+ (instancetype)sharedConfiguration {
    static RGConfiguration *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[self alloc] init];
    });
    
    return _sharedConfiguration;
}

- (BOOL)fullscreenBannerEnabled {
    return [self[@"Ads.fullscreenBanner.enabled"] boolValue];
}

- (NSString *)fullscreenBannerImageURL {
    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
        return self[@"Ads.fullscreenBanner.tallImageURL"];
    } else {
        return self[@"Ads.fullscreenBanner.imageURL"];
    }
}

- (NSTimeInterval)fullscreenBannerFadeDuration {
    return [self[@"Ads.fullscreenBanner.fadeDuration"] doubleValue];
}

- (NSTimeInterval)fullscreenBannerShowTime {
    return [self[@"Ads.fullscreenBanner.showTime"] doubleValue];
}

- (BOOL)smallBannerEnabled {
    return [self[@"Ads.smallBanner.enabled"] boolValue];
}

- (NSString *)smallBannerImageURL {
    return @"http://docs.google.com/uc?export=download&id=0B4pWLbcPaUi6T2ttU0xfWUVLbEU";
    return self[@"Ads.smallBanner.imageURL"];
}

- (NSString *)smallBannerLinkURL {
    return @"http://google.com/";
    return self[@"Ads.smallBanner.linkURL"];
}

- (NSString *)defaultLanguage {
    return self[@"Language.default"];
}

- (NSString *)currentLanguage {
    return self[RGSettingsLanguageKey];
}

- (id)objectForKeyedSubscript:(id)key {
    return [[NSUserDefaults standardUserDefaults] valueForKeyPath:key];
}

- (void)updateWithCompletion:(void (^)(NSDictionary *defaults, NSError *error))completion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AFPropertyListResponseSerializer *serializer = [AFPropertyListResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", @"text/plain", nil];
        
        userDefaults.responseSerializer = serializer;
    });
    
    NSURL *configURL = [NSURL URLWithString:RGConfigurationURL];
    [userDefaults registerDefaultsWithURL:configURL success:^(NSDictionary *dDefaults) {
        if (completion) {
            completion(dDefaults, nil);
        }
    } failure:^(NSError *dError) {
        if (completion) {
            completion(nil, dError);
        }
    }];
}

@end
