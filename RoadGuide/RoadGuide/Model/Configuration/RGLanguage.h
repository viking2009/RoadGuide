//
//  RGLanguage.h
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const RGLanguageDidChangeNotification;
extern NSString *const RGSettingsLanguageKey;

@interface RGLanguage : NSObject

+ (NSString *)currentLanguage;
+ (void)setCurrentLanguage:(NSString *)aLanguage;
+ (NSArray *)supportedLanguages;

+ (NSString *)localizedStringForKey:(NSString *)key;

@end
