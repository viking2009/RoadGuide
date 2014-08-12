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

static NSString * const RGConfigurationURL = @"https://docs.google.com/uc?export=download&id=0Bx0hFmhr9oPRS3h2Z1d5Y3ZGVjQ";

@implementation RGConfiguration

+ (instancetype)sharedConfiguration {
    static RGConfiguration *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[self alloc] init];
    });
    
    return _sharedConfiguration;
}

- (void)updateWithCompletion:(void (^)(NSDictionary *defaults, NSError *error))completion {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AFPropertyListResponseSerializer *serializer = [AFPropertyListResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
        
        standardUserDefaults.responseSerializer = serializer;
    });
    
    NSURL *configURL = [NSURL URLWithString:RGConfigurationURL];
    [standardUserDefaults registerDefaultsWithURL:configURL success:^(NSDictionary *dDefaults) {
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
