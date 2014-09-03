//
//  RGLanguage.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGLanguage.h"
#import "RGConfiguration.h"
#import "Flurry.h"

NSString *const RGLanguageDidChangeNotification = @"RGLanguageDidChangeNotification";
NSString *const RGSettingsLanguageKey = @"userDefinedLanguage";

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
        
        [userDefaults setValue:aLanguage forKey:RGSettingsLanguageKey];
        if ([userDefaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RGLanguageDidChangeNotification object:aLanguage];
            
            [Flurry logEvent:@"LanguageChanged" withParameters:@{RGSettingsLanguageKey: aLanguage}];
        }
    }
}

+ (NSArray *)supportedLanguages {
    return @[@"uk", @"en", @"ru"];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:self.currentLanguage ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:nil];
}

@end
