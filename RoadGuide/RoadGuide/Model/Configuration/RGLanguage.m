//
//  RGLanguage.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGLanguage.h"
#import "RGConfiguration.h"

NSString *const RGLanguageDidChangeNotification = @"RGLanguageDidChangeNotification";
NSString *const RGSettingsLanguageKey = @"Language.userDefined";

@implementation RGLanguage

+ (NSString *)currentLanguage {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    if (!configuration.currentLanguage) {
//        NSArray* languages = configuration[@"AppleLanguages"];
//        NSString *currentLanguage = languages.firstObject ? : configuration.defaultLanguage;
        NSString *currentLanguage = configuration.defaultLanguage ? : self.supportedLanguages.firstObject;
        [self setCurrentLanguage:currentLanguage];
    }
    
    return configuration.currentLanguage;
}

+ (void)setCurrentLanguage:(NSString *)aLanguage {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    if (![configuration.currentLanguage isEqualToString:aLanguage]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
        
        NSMutableDictionary *language = [configuration[@"Language"] mutableCopy];
        [language setValue:aLanguage forKey:@"userDefined"];
        [userDefaults setValue:language forKey:@"Language"];
        if ([userDefaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RGLanguageDidChangeNotification object:aLanguage];
        }
    }
}

+ (NSArray *)supportedLanguages {
    return @[@"ru", @"en", @"uk"];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:self.currentLanguage ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:nil];
}

@end
